# Git Server

Self-hosted Git server running over SSH in a Docker container.

## Features

- SSH key authentication only (no passwords)
- Custom repository management commands via git-shell
- Trash system so deleted repositories are recoverable
- Persistent data via bind mount
- SSH keys can be added at any time without restarting
- Auto-starts with the system

## Setup

1. **Add your SSH public key** to `authorized_keys` (optional, can be done later)

The key pair is generated on the **client** (the machine you will connect from), but the public key is added to `authorized_keys` on the **server** (the machine running the container). The private key never leaves the client.

On the client, generate a key if you don't have one and print the public key:

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

On the server, append that line to `authorized_keys`:

```bash
echo "ssh-ed25519 AAAA... user@client" >> authorized_keys
```

If the client and the server are the same machine, you can do it in one step:

```bash
cat ~/.ssh/id_ed25519.pub >> authorized_keys
```

> **Note:** `ssh-copy-id` does not work with this server, since password authentication is disabled and the `git` user is restricted to `git-shell`. Keys must be added to `authorized_keys` manually.
>
> When connecting from another machine, replace `localhost` with the server's IP or hostname (e.g. `ssh://git@192.168.1.50:2222/repos/my-repo.git`).

2. **Start the server:**

```bash
docker compose up -d
```

> **Important:** You can change the volume paths in `docker-compose.yml` to any location on the host. However, the `authorized_keys` file must already exist at that location **before** starting the container. If it doesn’t exist, Docker (as it does by default) will create a directory in its place, and SSH authentication will not work.
> To avoid this copy or create `authorized_keys` at your chosen path before launching the container.
> ```bash
> cp authorized_keys /host/bind-mount/location
> ```

## Connecting

The server runs on port `2222`. Use `git@localhost` as the remote:

```bash
git clone ssh://git@localhost:2222/repos/my-repo.git
```

Or, if you already have a local repo, add this server as its remote:

```bash
git remote add origin ssh://git@localhost:2222/repos/my-repo.git
```

## Commands

I added some git-shell custom commands to extend the repository management capabilities as creating, deleting, and restoring repos. They are written in Bash and are located in `git-shell-commands/`.

Commands are run over SSH:

```bash
ssh git@localhost -p 2222 <command>
```

Or you can access the git-shell and enter the commands interactively.

| Command | Description |
|---|---|
| `new <repo-name>` | Create a new bare repository |
| `list` | List all repositories |
| `delete <repo-name>` | Move a repository to trash |
| `list-trash` | List repositories in trash |
| `restore-repository <repo-name>` | Restore a repository from trash |
| `empty-trash` | Permanently delete all repositories in trash |

## Authentication

Password authentication is disabled. Only SSH key authentication is allowed. Therefore, it is necessary to add the client's public key to the `authorized_keys` file, as described in [Setup](#setup).

You can add keys at any time, before or after the container is running. Since `authorized_keys` is a bind mount, the server picks up changes instantly with no restart needed.
