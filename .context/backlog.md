# Backlog

## Details

### universal-installer
**Description**: Create universal installer for SSH Tunnel Manager
**Context**: 
- Relevant files: `~/.bin/ssh-tunnel-manager.sh`, `~/.config/ssh-tunnels/tunnels.conf`
- Requirements:
  - Check dependencies (walker, notify-send, ssh, pgrep, ss)
  - Offer to auto-install missing deps via detected package manager
  - Copy script to ~/.local/bin/
  - Create config dir, preserve existing tunnels.conf
  - Detect Hyprland config, offer to add keybind
  - Support --uninstall flag
- Technical notes: Single install.sh approach, no external deps beyond bash
- Related work: tunneler project setup

## High Priority
- [ ] [Create universal installer](#universal-installer)

## Low Priority / Nice to Have
- [ ] Add package manager integration (AUR, deb, rpm)

## Completed
- [x] SSH Tunnel Manager core implementation (2026-03-14)
