<h1 align="center">
    <a href="https://vpm.vlang.io">
        <img width='240' alt='V Package Manager' src='.github/assets/vpm.svg'>
    </a>
</h1>

<div align="center">

<!-- [Getting started][GettingStarted] -->
<!-- &ensp;|&ensp; -->
<!-- [Documentation][Docs] -->
<!-- &ensp;|&ensp; -->
<!-- [Contribute][Contribute] -->

[![Sponsor][SponsorBadge]][SponsorUrl]
[![Patreon][PatreonBadge]][PatreonUrl]
[![Discord][DiscordBadge]][DiscordUrl]
[![Twitter][TwitterBadge]][TwitterUrl]
</div>

Instantly publish your modules and install them. Use the API to interact and find out more information about available modules. Become a contributor and enhance V with your work. [vpm.vlang.io →][vpm]

To run it locally, just run

```bash
v install
v .
```

Don't forget to update `config.toml`: set your Postgres host, port, user, password, and dbname.

Make sure you have `libpq-dev` installed. Please refer to your OS or distribution documentation to install it.

In order to use GitHub authentication, add GitHub client id and secret as well.

## Tailwind Setup
Download and install Tailwinds [Standalone CLI][tailwindCli] in your local clone.

**Linux Example**:
```bash
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
mv tailwindcss-linux-x64 tailwindcss
```
You can edit the tailwind configuration in `tailwind.config.js` and add custom css to `static/css/index.css`.

### Watching CSS
Use the Standalone CLI to watch the css for changes
```bash
./tailwindcss -i static/css/index.css -o static/css/dist.css --watch --minify
```

### Intellisense
Use Tailwinds [CSS Intellisense][tailwindExtension] extension for VSCode to get code completion for
all tailwinds classes.

## Development database

Instance of locally installed Postgres 15 or docker container:

```bash
docker run -it \
  --name vpm-database \
  -e POSTGRES_DB=vpm \
  -e POSTGRES_USER=vpm \
  -e POSTGRES_PASSWORD=vpm \
  --mount source=vpm-data,target=/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15
```

```sql
CREATE DATABASE vpm;
CREATE USER vpm WITH PASSWORD 'vpm';
GRANT ALL PRIVILEGES ON DATABASE vpm TO vpm;
\c vpm postgres
GRANT ALL ON SCHEMA public TO vpm;
```







<!-- Reference links -->
[vpm]: https://vpm.vlang.io
<!-- [GettingStarted]: https://vpm.vlang.io/docs/getting-started -->
<!-- [Docs]: https://vpm.vlang.io/docs -->
<!-- [Contribute]: .github/CONTRIBUTING.md -->
[tailwindCli]: https://tailwindcss.com/blog/standalone-cli
[tailwindExtension]: https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss

<!-- Badges -->
[DiscordBadge]: https://img.shields.io/discord/592103645835821068?label=Discord&logo=discord&logoColor=white
[PatreonBadge]: https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.vercel.app%2Fapi%3Fusername%3Dvlang%26type%3Dpatrons&style=flat
[SponsorBadge]: https://camo.githubusercontent.com/da8bc40db5ed31e4b12660245535b5db67aa03ce/68747470733a2f2f696d672e736869656c64732e696f2f7374617469632f76313f6c6162656c3d53706f6e736f72266d6573736167653d254532253944254134266c6f676f3d476974487562
[TwitterBadge]: https://img.shields.io/badge/follow-%40v_language-1DA1F2?logo=twitter&style=flat&logoColor=white&color=1da1f2

<!-- Socials -->
[DiscordUrl]: https://discord.gg/vlang
[PatreonUrl]: https://patreon.com/vlang
[SponsorUrl]: https://github.com/sponsors/medvednikov
[TwitterUrl]: https://twitter.com/v_language
