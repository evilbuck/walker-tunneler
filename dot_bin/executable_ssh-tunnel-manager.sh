#!/usr/bin/env bash

CONFIG_FILE="${HOME}/.config/ssh-tunnels/tunnels.conf"

show_notification() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message" -u normal
}

is_port_in_use() {
    local port="$1"
    ss -tlnp 2>/dev/null | grep -q ":${port} " 
}

get_tunnel_pid() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="$3"
    local ssh_host="$4"
    
    local port_mapping="${local_port}:${remote_host}:${remote_port}"
    pgrep -f "ssh.*${port_mapping}.*${ssh_host}" 2>/dev/null | head -1
}

is_pid_alive() {
    local pid="$1"
    kill -0 "$pid" 2>/dev/null
}

parse_config() {
    local line="$1"
    echo "$line" | awk -F'|' '{print $1"|"$2"|"$3"|"$4}'
}

build_menu() {
    local menu_items=()
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        local id label port_mapping ssh_host
        IFS='|' read -r id label port_mapping ssh_host <<< "$line"
        
        local local_port remote_host remote_port
        IFS=':' read -r local_port remote_host remote_port <<< "$port_mapping"
        
        local pid
        pid=$(get_tunnel_pid "$local_port" "$remote_host" "$remote_port" "$ssh_host")
        
        if [[ -n "$pid" ]] && is_pid_alive "$pid"; then
            menu_items+=("[ON] ${label} (${local_port})")
        else
            menu_items+=("[OFF] ${label} (${local_port})")
        fi
    done < "$CONFIG_FILE"
    
    menu_items+=("⚙ Configure New Tunnel...")
    
    printf '%s\n' "${menu_items[@]}"
}

start_tunnel() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="$3"
    local ssh_host="$4"
    
    if is_port_in_use "$local_port"; then
        show_notification "SSH Tunnel" "Port ${local_port} is already in use"
        return 1
    fi
    
    ssh -fNL "${local_port}:${remote_host}:${remote_port}" "$ssh_host" 2>/dev/null
    
    sleep 0.5
    
    local pid
    pid=$(get_tunnel_pid "$local_port" "$remote_host" "$remote_port" "$ssh_host")
    
    if [[ -n "$pid" ]] && is_pid_alive "$pid"; then
        show_notification "SSH Tunnel" "Started: ${local_port} -> ${remote_host}:${remote_port}"
    else
        show_notification "SSH Tunnel" "Failed to start tunnel to ${ssh_host}"
        return 1
    fi
}

stop_tunnel() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="$3"
    local ssh_host="$4"
    
    local pid
    pid=$(get_tunnel_pid "$local_port" "$remote_host" "$remote_port" "$ssh_host")
    
    if [[ -n "$pid" ]] && is_pid_alive "$pid"; then
        kill "$pid" 2>/dev/null
        sleep 0.3
        if ! is_pid_alive "$pid"; then
            show_notification "SSH Tunnel" "Stopped: ${local_port}"
        else
            show_notification "SSH Tunnel" "Failed to stop tunnel"
            return 1
        fi
    fi
}

main() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        show_notification "SSH Tunnel" "Config file not found: ${CONFIG_FILE}"
        exit 1
    fi
    
    local menu_output
    menu_output=$(build_menu)
    
    local selected
    selected=$(echo "$menu_output" | walker --dmenu --placeholder "SSH Tunnels")
    
    [[ -z "$selected" ]] && exit 0
    
    if [[ "$selected" == "⚙ Configure New Tunnel..." ]]; then
        ${TERMINAL:-xdg-terminal-exec} ${EDITOR:-nano} "$CONFIG_FILE"
        exit 0
    fi
    
    local status label_with_port
    status=$(echo "$selected" | awk '{print $1}')
    label_with_port=$(echo "$selected" | sed 's/^\[ON\] \[OFF\] //')
    local label="${label_with_port% (*}"
    local local_port="${label_with_port##*(}"
    local_port="${local_port%)}"
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        local id conf_label port_mapping ssh_host
        IFS='|' read -r id conf_label port_mapping ssh_host <<< "$line"
        
        [[ "$conf_label" != "$label" ]] && continue
        
        local remote_host remote_port
        IFS=':' read -r remote_host remote_port <<< "$port_mapping"
        
        if [[ "$status" == "[ON]" ]]; then
            stop_tunnel "$local_port" "$remote_host" "$remote_port" "$ssh_host"
        else
            start_tunnel "$local_port" "$remote_host" "$remote_port" "$ssh_host"
        fi
        break
    done < "$CONFIG_FILE"
}

main "$@"
