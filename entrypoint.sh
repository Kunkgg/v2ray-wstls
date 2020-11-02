#!/bin/sh

CF="/etc/v2ray/config.json"

v2ray_log() {
        type="$1"; shift
        printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-2822)" "$type" "$*"
}

v2ray_note() {
        v2ray_log Note "$@"
}
v2ray_warn() {
        v2ray_log Warn "$@" >&2
}
v2ray_error() {
        v2ray_log ERROR "$@" >&2
        exit 1
}

v2ray_set_uuid() {
    if [ -n "${V2RAY_UUID}" ]; then
        if sed -i "s/\"id\": \".*\",$/\"id\": \"${V2RAY_UUID}\",/" ${CF}; then
            v2ray_note "Updated: v2ray server UUID";
            v2ray_note "UUID: ${V2RAY_UUID}";
            v2ray_note "config file: ${CF}";
        else
            v2ray_error "Failed to update v2ray server UUID";
        fi
    else
        v2ray_error "You should specify v2ray server UUID by environment
        variable before running this docker";
    fi
}

v2ray_set_port() {
    if [ -n "${V2RAY_VIRTUAL_PORT}" ]; then
        if sed -i "s/\"port\": .*,$/\"port\": ${V2RAY_VIRTUAL_PORT},/" ${CF}; then
            v2ray_note "Updated: v2ray server local port";
            v2ray_note "port: ${V2RAY_VIRTUAL_PORT}";
            v2ray_note "config file: ${CF}";
        else
            v2ray_error "Failed to update v2ray server local port";
        fi
    else
        v2ray_error "You should specify v2ray server local port by environment
        variable before running this docker";
    fi
}

v2ray_runner(){
    /usr/bin/v2ray -config ${CF}
}

main() {
    v2ray_set_uuid
    v2ray_set_port
    v2ray_runner
}

main
