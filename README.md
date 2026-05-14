# Git Server

A self-hosted Git server running over SSH in a Docker container, built on Alpine Linux.

## Requirements

- Docker
- Docker Compose

## Setup

1. **Add your SSH public key** to `authorized_keys`:

```bash
cat ~/.ssh/id_ed25519.pub >> authorized_keys
```

2. **Start the server:**

```bash
docker compose up -d
```

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
git clone ssh://git@localhost:2222/home/git/repos/my-repo.git
```

Or add a remote to an existing repo:

```bash
git remote add origin ssh://git@localhost:2222/home/git/repos/my-repo.git
```

## Commands

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

Password authentication is disabled. Only SSH key authentication is allowed. Add authorized public keys to the `authorized_keys` file before starting the container.

## Docker Compose commands

```bash
docker compose up -d          # Start in background
docker compose down           # Stop and remove containers
docker compose up --build -d  # Rebuild image and start
docker compose logs -f        # Follow live logs
docker compose ps             # Check container status
```
