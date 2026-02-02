<div align="center">
  <a href="https://dokploy.com">
    <img src=".github/sponsors/logo.png" alt="Dokploy - Open Source Alternative to Vercel, Heroku and Netlify." width="100%"  />
  </a>
  </br>
  </br>
  <p>Join us on Discord for help, feedback, and discussions!</p>
  <a href="https://discord.gg/2tBnJ3jDJc">
    <img src="https://discordapp.com/api/guilds/1234073262418563112/widget.png?style=banner2" alt="Discord Shield"/>
  </a>
</div>
<br />



<div align="center" markdown="1">
   <sup>Special thanks to:</sup>
   <br>
   <br>
   <a href="https://tuple.app/dokploy">
     <img src=".github/sponsors/tuple.png" alt="Tuple's sponsorship image" width="400"/>
   </a>

### [Tuple, the premier screen sharing app for developers](https://tuple.app/dokploy)
[Available for MacOS & Windows](https://tuple.app/dokploy)<br>

</div>


Dokploy is a free, self-hostable Platform as a Service (PaaS) that simplifies the deployment and management of applications and databases.


## ✨ Features

Dokploy includes multiple features to make your life easier.

- **Applications**: Deploy any type of application (Node.js, PHP, Python, Go, Ruby, etc.).
- **Databases**: Create and manage databases with support for MySQL, PostgreSQL, MongoDB, MariaDB, and Redis.
- **Backups**: Automate backups for databases to an external storage destination.
- **Docker Compose**: Native support for Docker Compose to manage complex applications.
- **Multi Node**: Scale applications to multiple nodes using Docker Swarm to manage the cluster.
- **Templates**: Deploy open-source templates (Plausible, Pocketbase, Calcom, etc.) with a single click.
- **Traefik Integration**: Automatically integrates with Traefik for routing and load balancing.
- **Real-time Monitoring**: Monitor CPU, memory, storage, and network usage for every resource.
- **Docker Management**: Easily deploy and manage Docker containers.
- **CLI/API**: Manage your applications and databases using the command line or through the API.
- **Notifications**: Get notified when your deployments succeed or fail (via Slack, Discord, Telegram, Email, etc.).
- **Multi Server**: Deploy and manage your applications remotely to external servers.
- **Self-Hosted**: Self-host Dokploy on your VPS.

## 🚀 Getting Started

To get started, run the following command on a VPS:

Want to skip the installation process? [Try the Dokploy Cloud](https://app.dokploy.com).

**Install from this repo (recommended — supports custom ports):**

```bash
curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh
```

**Port 80 already in use?** Use custom Traefik ports (e.g. 8080 for HTTP, 8443 for HTTPS):

```bash
export TRAEFIK_PORT=8080 TRAEFIK_SSL_PORT=8443 && curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh
```

Then access the dashboard on port 3000; your apps will be reachable via ports 8080 (HTTP) and 8443 (HTTPS).

**Alternative — official installer (requires ports 80, 443, 3000 free):**

```bash
curl -sSL https://dokploy.com/install.sh | sh
```

For detailed documentation, visit [docs.dokploy.com](https://docs.dokploy.com).

### Installation depuis ce dépôt (NAS / port 80 occupé)

1. **Pousser le code vers votre dépôt GitHub** (une seule fois, depuis votre machine) :

```bash
cd /chemin/vers/dokploy
git remote add sasharohee https://github.com/sasharohee/dokploy.git
git push sasharohee canary:main
```

(Si vous poussez uniquement `canary` avec `git push sasharohee canary`, utilisez `.../canary/install.sh` dans les commandes ci‑dessous au lieu de `.../main/install.sh`.)

2. **Sur le NAS**, lancer l’installation depuis votre dépôt :

**Ports 80/443 libres :**
```bash
curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh
```

**Port 80 déjà utilisé (ex. TNAS) :**
```bash
export TRAEFIK_PORT=8080 TRAEFIK_SSL_PORT=8443 && curl -sSL https://raw.githubusercontent.com/sasharohee/dokploy/main/install.sh | sh
```

Exécuter en root (`sudo` si besoin). Puis ouvrir le dashboard sur `http://<IP-du-NAS>:3000`.

**En cas d’erreur « 404 » :** le script n’est pas encore sur GitHub. Depuis votre machine, faites un commit et un push (étape 1) puis réessayez. Si vous avez poussé la branche `canary` (sans la renommer en `main`), utilisez `.../canary/install.sh` dans l’URL.

## ♥️ Sponsors

🙏 We're deeply grateful to all our sponsors who make Dokploy possible! Your support helps cover the costs of hosting, testing, and developing new features.

[Dokploy Open Collective](https://opencollective.com/dokploy)

[Github Sponsors](https://github.com/sponsors/Siumauricio)

## Sponsors

| Sponsor | Logo | Supporter Level |
|---------|:----:|----------------|
| [Hostinger](https://www.hostinger.com/vps-hosting?ref=dokploy) | <img src=".github/sponsors/hostinger.jpg" alt="Hostinger" width="200"/> | 🎖 Hero Sponsor |
| [LX Aer](https://www.lxaer.com/?ref=dokploy) | <img src=".github/sponsors/lxaer.png" alt="LX Aer" width="100"/> | 🎖 Hero Sponsor |
| [LinkDR](https://linkdr.com/?ref=dokploy) | <img src="https://dokploy.com/linkdr-logo.svg" alt="LinkDR" width="100"/> | 🎖 Hero Sponsor |
| [LambdaTest](https://www.lambdatest.com/?utm_source=dokploy&utm_medium=sponsor) | <img src="https://www.lambdatest.com/blue-logo.png" alt="LambdaTest" width="200"/> | 🎖 Hero Sponsor |
| [Awesome Tools](https://awesome.tools/) | <img src=".github/sponsors/awesome.png" alt="Awesome Tools" width="100"/> | 🎖 Hero Sponsor |
| [Supafort](https://supafort.com/?ref=dokploy) | <img src="https://supafort.com/build/q-4Ht4rBZR.webp" alt="Supafort.com" width="200"/> | 🥇 Premium Supporter |
| [Agentdock](https://agentdock.ai/?ref=dokploy) | <img src=".github/sponsors/agentdock.png" alt="agentdock.ai" width="100"/> | 🥇 Premium Supporter |
| [AmericanCloud](https://americancloud.com/?ref=dokploy) | <img src=".github/sponsors/american-cloud.png" alt="AmericanCloud" width="200"/> | 🥈 Elite Contributor |
| [Tolgee](https://tolgee.io/?utm_source=github_dokploy&utm_medium=banner&utm_campaign=dokploy) | <img src="https://dokploy.com/tolgee-logo.png" alt="Tolgee" width="100"/> | 🥈 Elite Contributor |
| [Cloudblast](https://cloudblast.io/?ref=dokploy) | <img src="https://cloudblast.io/img/logo-icon.193cf13e.svg" alt="Cloudblast.io" width="150"/> | 🥉 Supporting Member |
| [Synexa](https://synexa.ai/?ref=dokploy) | <img src=".github/sponsors/synexa.png" alt="Synexa" width="100"/> | 🥉 Supporting Member |

### Community Backers 🤝

#### Organizations:

[Sponsors on Open Collective](https://opencollective.com/dokploy)

#### Individuals:

[![Individual Contributors on Open Collective](https://opencollective.com/dokploy/individuals.svg?width=890)](https://opencollective.com/dokploy)

### Contributors 🤝

<a href="https://github.com/dokploy/dokploy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=dokploy/dokploy" alt="Contributors" />
</a>

## 📺 Video Tutorial

<a href="https://youtu.be/mznYKPvhcfw">
  <img src="https://dokploy.com/banner.png" alt="Watch the video" width="400"/>
</a>

## 🤝 Contributing

Check out the [Contributing Guide](CONTRIBUTING.md) for more information.
