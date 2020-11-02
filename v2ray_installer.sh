#!/bin/sh

v2ray_log() {
        local type="$1"; shift
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

v2ray_installer() {
    # Prepare
    v2ray_note "Prepare to use"
    mkdir -p /tmp/v2ray
    mv v2ray*.zip /tmp/v2ray
    cd /tmp/v2ray
    unzip v2ray*.zip && chmod +x v2ray v2ctl
    mv v2ray v2ctl /usr/bin/
    mv geosite.dat geoip.dat /usr/local/share/v2ray/
    mv config.json /etc/v2ray/config.json.bak
    cd /root
    mv config.json /etc/v2ray/config.json

    # Clean
    rm -rf -v /tmp/v2ray
    apk del curl
    v2ray_note "v2ray installed"
}

v2ray_installer "$@"
