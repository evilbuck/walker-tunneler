---
date: 2026-03-14
domains: [infra, tooling]
topics: [ssh-tunnel-manager, hyprland, walker]
related: []
priority: medium
status: active
---

# Session: 2026-03-14 - SSH Tunnel Manager

## Context
- Goal: Create SSH tunnel management via walker dmenu

## Decisions Made
- Used chezmoi-style directory structure: `private_dot_config/ssh-tunnels/tunnels.conf`, `dot_bin/executable_ssh-tunnel-manager.sh`
- Script location: `~/.bin/ssh-tunnel-manager.sh` (not ~/.local/bin/ per user preference)
- Config format: pipe-delimited `id|label|local_port:remote_host:remote_port|ssh_host`

## Implementation Notes
- Key files created:
  - `private_dot_config/ssh-tunnels/tunnels.conf`
  - `dot_bin/executable_ssh-tunnel-manager.sh`
  - `private_dot_config/hypr/bindings.conf`
- Edge cases handled: stale pids (kill -0 validation), port conflicts (ss -tlnp check), escape/no-selection
- Copied directly to home since not in chezmoi directory
- Keybind added at line 58 of existing `~/.config/hypr/bindings.conf`

## Next Steps
- [ ] Create universal installer (see backlog)
