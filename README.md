# ILIAS 10 Docker Container

This Docker setup provides a local development environment for ILIAS.

## Quick Start

1. Create local environment file:

```bash
cp env.example .env
```

2. Set `MARIADB_ROOT_PASSWORD` in `.env`.

3. Start and install ILIAS:

```bash
./scripts/bootstrap.sh
```

The bootstrap script clones ILIAS into `./src`, generates `conf/ilias.json`, starts Docker Compose, waits for MariaDB, and runs the ILIAS installer.

Visit:

```text
http://localhost:28084
```

Default ILIAS login:

```text
Username: root
Password: homer
```

Change the password after first login.

## Keycloak Development Login

This repo is intended to use the sibling `1UpKeyCloak` development realm.
For the cross-repo overview, see `1UpKeyCloak/docs/local-apps.md`.

Planned local OIDC values:

```text
Issuer: http://1up-keycloak.localhost:28080/realms/university-dev
Client ID: ilias
Client secret: ilias-dev-secret
Redirect base: http://localhost:28084
Username claim: preferred_username
Scopes: openid profile email roles
```

The Keycloak realm already has ILIAS role hints in:

```text
resource_access.ilias.roles
```

The ILIAS app-side OIDC setup is not wired in this repo yet.
