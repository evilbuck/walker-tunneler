# Walker Tunneler

SSH tunnel manager for Walker (Hyprland launcher). Toggle SSH tunnels on/off via dmenu.

## Dependencies

- `walker` — Hyprland launcher
- `openssh` — SSH client
- `libnotify` — Desktop notifications (`notify-send`)
- Standard tools: `pgrep`, `ss`, `bash`

## Installation

```bash
# Copy script
mkdir -p ~/.bin ~/.config/ssh-tunnels
cp ssh-tunnel-manager.sh ~/.bin/ssh-tunnel-manager.sh
chmod +x ~/.bin/ssh-tunnel-manager.sh

# Create config
cp tunnels.conf ~/.config/ssh-tunnels/tunnels.conf
```

Add keybind to `~/.config/hypr/hyprland.conf` or `bindings.conf`:

```
bind = SUPER, T, exec, ~/.bin/ssh-tunnel-manager.sh
```

Reload Hyprland: `hyprctl reload`

## Configuration

Edit `~/.config/ssh-tunnels/tunnels.conf`:

```
# id|label|local_port:remote_host:remote_port|ssh_host
work-db|Work Database|5432:localhost:5432|work-server
redis|Redis Server|6379:localhost:6379|prod-server
api|Local API|3000:localhost:3000|dev-machine
```

**Fields:**
- `id` — Unique identifier
- `label` — Display name in menu
- `local_port:remote_host:remote_port` — Port mapping
- `ssh_host` — Host from `~/.ssh/config`

## Usage

1. Press `SUPER+T` to open menu
2. Select a tunnel to toggle on/off
3. Notification confirms action

## Troubleshooting

**Tunnel won't start:**
- Check port not already in use: `ss -tlnp | grep <port>`
- Verify SSH host exists in `~/.ssh/config`
- Test manually: `ssh -fNL 3000:localhost:3000 <host>`

**Menu always shows [OFF]:**
- Tunnel may have crashed; check: `pgrep -af ssh`
- Kill stale processes: `pkill -f "ssh.*<port>"`

**Host not found:**
- Add host to `~/.ssh/config`:
```
Host myserver
    HostName myserver.example.com
    User myuser
    IdentityFile ~/.ssh/mykey
```
