# Git Server

A self-hosted Git server running over SSH in a Docker container, built on Alpine Linux.

## Features

- SSH key authentication only — no passwords
- Custom repository management commands via git-shell
- Trash system — deleted repositories are recoverable
- Persistent data via bind mounts — survives container rebuilds
- SSH keys can be added at any time without restarting
- Auto-starts with the system

## Requirements

- Docker
- Docker Compose

## Setup

1. **Add your SSH public key** to `authorized_keys` (optional, can be done later)

```bash
cat /home/user/.ssh/id_ed25519.pub >> authorized_keys
```

2. **Start the server:**

```bash
docker compose up -d
```

> **Note:** You can change the volume paths in `docker-compose.yml` to any location on your system. However, the `authorized_keys` file must already exist at that location **before** starting the container. If it doesn’t exist, Docker will create a directory in its place, and SSH authentication will not work.
> To avoid this, please copy or create `authorized_keys` at your chosen path before launching the container.
> ```bash
> cp authorized_keys /git/server/repo/host/location
> ```

## Project structure

```
git-server/
├── docker-compose.yml
├── Dockerfile
├── authorized_keys        # SSH public keys allowed to connect
├── repos/                 # Git repositories
├── trash/                 # Deleted repositories (recoverable)
└── ssh_host_keys/         # SSH host keys (persisted across rebuilds)
```

## Connecting

The server runs on port `2222`. Use `git@localhost` as the remote:

```bash
git clone ssh://git@localhost:2222/repos/my-repo.git
```

Or add a remote to an existing repo:

```bash
git remote add origin ssh://git@localhost:2222/repos/my-repo.git
```

## Commands

Git shell only allows git operations by default. Custom commands extend it with repository management capabilities like creating, deleting, and restoring repos. They are written in Bash and located in `git-shell-commands/`.

Commands are run over SSH:

```bash
ssh git@localhost -p 2222 <command>
```

| Command | Description |
|---|---|
| `new <repo-name>` | Create a new bare repository |
| `list` | List all repositories |
| `delete <repo-name>` | Move a repository to trash |
| `list-trash` | List repositories in trash |
| `restore-repository <repo-name>` | Restore a repository from trash |
| `empty-trash` | Permanently delete all repositories in trash |

### Examples

```bash
# Create a new repo
ssh git@localhost -p 2222 new my-repo

# List repos
ssh git@localhost -p 2222 list

# Delete a repo (moves to trash)
ssh git@localhost -p 2222 delete my-repo

# Restore it
ssh git@localhost -p 2222 restore-repository my-repo

# Permanently empty the trash
ssh git@localhost -p 2222 empty-trash
```

## Authentication

Password authentication is disabled. Only SSH key authentication is allowed.

Add a public key to the `authorized_keys` file:

```bash
cat /home/user/.ssh/id_ed25519.pub >> authorized_keys
```

You can add keys at any time, before or after the container is running. Since `authorized_keys` is a bind mount, the server will picks up changes instantly with no restart needed.
