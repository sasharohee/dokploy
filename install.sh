#!/bin/bash
# Dokploy installation script
# Auto-uses 8080/8443 when port 80 (or 443) is in use (e.g. nginx). Override with TRAEFIK_PORT / TRAEFIK_SSL_PORT.
# Install: curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh

set -e

# Customizable ports (default: 80 and 443). Auto-switch to 8080/8443 if 80/443 are in use.
TRAEFIK_PORT="${TRAEFIK_PORT:-80}"
TRAEFIK_SSL_PORT="${TRAEFIK_SSL_PORT:-443}"

port_in_use() {
	local port=$1
	(ss -tulnp 2>/dev/null || true) | grep -q ":${port} " && return 0
	(netstat -tulnp 2>/dev/null || true) | grep -q ":${port} " && return 0
	return 1
}

# Find first free port from the list
find_free_port() {
	for p in "$@"; do
		if ! port_in_use "$p"; then
			echo "$p"
			return 0
		fi
	done
	return 1
}

install_dokploy() {
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run as root" >&2
		exit 1
	fi

	if [ "$(uname)" = "Darwin" ]; then
		echo "This script must be run on Linux" >&2
		exit 1
	fi

	if [ -f /.dockerenv ]; then
		echo "This script must not be run inside a container" >&2
		exit 1
	fi

	# If default ports 80/443 are in use, auto-pick first free (incl. 3005, 3006, etc.)
	HTTP_PORTS="8080 8081 8082 8880 9080 3005 3006 3007 3008 10080 10081"
	HTTPS_PORTS="8443 8444 8445 9443 9444 3443 3444 3445 10443 10444"
	if [ "$TRAEFIK_PORT" = "80" ] && port_in_use "80"; then
		TRAEFIK_PORT=$(find_free_port $HTTP_PORTS)
		TRAEFIK_SSL_PORT=$(find_free_port $HTTPS_PORTS)
		[ -z "$TRAEFIK_PORT" ] && TRAEFIK_PORT=3005
		[ -z "$TRAEFIK_SSL_PORT" ] && TRAEFIK_SSL_PORT=3443
		echo "Port 80 (and/or 443) in use. Using Traefik HTTP port ${TRAEFIK_PORT}, HTTPS port ${TRAEFIK_SSL_PORT}."
	fi
	if [ "$TRAEFIK_SSL_PORT" = "443" ] && port_in_use "443"; then
		[ "$TRAEFIK_PORT" = "80" ] && TRAEFIK_PORT=$(find_free_port $HTTP_PORTS)
		TRAEFIK_SSL_PORT=$(find_free_port $HTTPS_PORTS)
		[ -z "$TRAEFIK_SSL_PORT" ] && TRAEFIK_SSL_PORT=3443
	fi
	# Ensure HTTP and HTTPS ports differ
	if [ "$TRAEFIK_PORT" = "$TRAEFIK_SSL_PORT" ]; then
		TRAEFIK_SSL_PORT=$(find_free_port $HTTPS_PORTS)
		[ -z "$TRAEFIK_SSL_PORT" ] && TRAEFIK_SSL_PORT=3443
	fi

	# Check that chosen ports are free
	if port_in_use "$TRAEFIK_PORT"; then
		echo "Error: something is already running on port ${TRAEFIK_PORT}" >&2
		echo "Try: export TRAEFIK_PORT=3005 TRAEFIK_SSL_PORT=3443 && curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh" >&2
		exit 1
	fi
	if port_in_use "$TRAEFIK_SSL_PORT"; then
		echo "Error: something is already running on port ${TRAEFIK_SSL_PORT}" >&2
		echo "Try: export TRAEFIK_PORT=3005 TRAEFIK_SSL_PORT=3443 && curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh" >&2
		exit 1
	fi
	if port_in_use "3000"; then
		echo "Error: something is already running on port 3000" >&2
		echo "Dokploy requires port 3000 to be available. Please stop any service using this port." >&2
		exit 1
	fi

	command_exists() {
		command -v "$@" >/dev/null 2>&1
	}

	if command_exists docker; then
		echo "Docker already installed"
	else
		curl -sSL https://get.docker.com | sh
	fi

	docker swarm leave --force 2>/dev/null || true

	get_ip() {
		local ip=""
		ip=$(curl -4s --connect-timeout 5 https://ifconfig.io 2>/dev/null || true)
		if [ -z "$ip" ]; then
			ip=$(curl -4s --connect-timeout 5 https://icanhazip.com 2>/dev/null || true)
		fi
		if [ -z "$ip" ]; then
			ip=$(curl -4s --connect-timeout 5 https://ipecho.net/plain 2>/dev/null || true)
		fi
		if [ -z "$ip" ]; then
			ip=$(curl -6s --connect-timeout 5 https://ifconfig.io 2>/dev/null || true)
		fi
		if [ -z "$ip" ]; then
			ip=$(curl -6s --connect-timeout 5 https://icanhazip.com 2>/dev/null || true)
		fi
		if [ -z "$ip" ]; then
			ip=$(curl -6s --connect-timeout 5 https://ipecho.net/plain 2>/dev/null || true)
		fi
		echo "$ip"
	}

	advertise_addr="${ADVERTISE_ADDR:-$(get_ip)}"
	if [ -z "$advertise_addr" ]; then
		echo "Error: Could not determine server IP address. Set ADVERTISE_ADDR manually." >&2
		echo "Example: export ADVERTISE_ADDR=192.168.1.100" >&2
		exit 1
	fi
	echo "Using advertise address: $advertise_addr"
	echo "Using Traefik HTTP port: ${TRAEFIK_PORT}, HTTPS port: ${TRAEFIK_SSL_PORT}"

	docker swarm init --advertise-addr "$advertise_addr" ${DOCKER_SWARM_INIT_ARGS:-}
	docker network rm dokploy-network 2>/dev/null || true
	docker network create --driver overlay --attachable dokploy-network
	echo "Network created"

	mkdir -p /etc/dokploy
	chmod 777 /etc/dokploy
	mkdir -p /etc/dokploy/traefik/dynamic
	touch /etc/dokploy/traefik/traefik.yml 2>/dev/null || true

	POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
	echo "$POSTGRES_PASSWORD" | docker secret create dokploy_postgres_password - 2>/dev/null || true
	echo "Generated secure database credentials"

	DOKPLOY_IMAGE="dokploy/dokploy:${DOKPLOY_VERSION:-latest}"
	if [ -z "${DOKPLOY_VERSION:-}" ]; then
		LATEST_VERSION=$(curl -sSfL https://api.github.com/repos/Dokploy/dokploy/releases/latest | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/"tag_name": *"\(.*\)"/\1/')
		if [ -n "$LATEST_VERSION" ]; then
			DOKPLOY_IMAGE="dokploy/dokploy:${LATEST_VERSION}"
			echo "Latest stable version detected: ${LATEST_VERSION}"
		fi
	fi
	echo "Installing Dokploy image: $DOKPLOY_IMAGE"

	docker service create \
		--name dokploy-postgres \
		--constraint 'node.role==manager' \
		--network dokploy-network \
		--env POSTGRES_USER=dokploy \
		--env POSTGRES_DB=dokploy \
		--secret source=dokploy_postgres_password,target=/run/secrets/postgres_password \
		--env POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
		--mount type=volume,source=dokploy-postgres,target=/var/lib/postgresql/data \
		postgres:16

	docker service create \
		--name dokploy-redis \
		--constraint 'node.role==manager' \
		--network dokploy-network \
		--mount type=volume,source=dokploy-redis,target=/data \
		redis:7

	docker service create \
		--name dokploy \
		--replicas 1 \
		--network dokploy-network \
		--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
		--mount type=bind,source=/etc/dokploy,target=/etc/dokploy \
		--mount type=volume,source=dokploy,target=/root/.docker \
		--secret source=dokploy_postgres_password,target=/run/secrets/postgres_password \
		--publish published=3000,target=3000,mode=host \
		--update-parallelism 1 \
		--update-order stop-first \
		--constraint 'node.role == manager' \
		-e ADVERTISE_ADDR="$advertise_addr" \
		-e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
		-e TRAEFIK_PORT="$TRAEFIK_PORT" \
		-e TRAEFIK_SSL_PORT="$TRAEFIK_SSL_PORT" \
		"$DOKPLOY_IMAGE"

	# Run Traefik with configurable host ports (publish TRAEFIK_PORT:80, TRAEFIK_SSL_PORT:443)
	docker run -d \
		--name dokploy-traefik \
		--restart always \
		-v /etc/dokploy/traefik/traefik.yml:/etc/traefik/traefik.yml \
		-v /etc/dokploy/traefik/dynamic:/etc/dokploy/traefik/dynamic \
		-v /var/run/docker.sock:/var/run/docker.sock:ro \
		-p "${TRAEFIK_PORT}:80/tcp" \
		-p "${TRAEFIK_SSL_PORT}:443/tcp" \
		-p "${TRAEFIK_SSL_PORT}:443/udp" \
		traefik:v3.6.7

	docker network connect dokploy-network dokploy-traefik

	GREEN="\033[0;32m"
	YELLOW="\033[1;33m"
	BLUE="\033[0;34m"
	NC="\033[0m"
	format_ip_for_url() {
		if echo "$1" | grep -q ':'; then
			echo "[${1}]"
		else
			echo "$1"
		fi
	}
	formatted_addr=$(format_ip_for_url "$advertise_addr")
	echo ""
	printf "${GREEN}Congratulations, Dokploy is installed!${NC}\n"
	printf "${BLUE}Wait 15 seconds for the server to start${NC}\n"
	printf "${YELLOW}Dashboard: http://${formatted_addr}:3000${NC}\n"
	if [ "$TRAEFIK_PORT" != "80" ] || [ "$TRAEFIK_SSL_PORT" != "443" ]; then
		printf "${YELLOW}Traefik HTTP: port ${TRAEFIK_PORT}, HTTPS: port ${TRAEFIK_SSL_PORT}${NC}\n"
	fi
	echo ""
}

update_dokploy() {
	echo "Updating Dokploy..."
	docker pull dokploy/dokploy:latest
	docker service update --image dokploy/dokploy:latest dokploy
	echo "Dokploy has been updated to the latest version."
}

if [ "${1:-}" = "update" ]; then
	update_dokploy
else
	install_dokploy
fi
