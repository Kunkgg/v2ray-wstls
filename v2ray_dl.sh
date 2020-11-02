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

v2ray_download() {
    v2ray_note ${TARGETPLATFORM}
    v2ray_note ${HTTP_PROXY}

    # Set ARG
    if [[ -z ${TARGETPLATFORM} ]]; then
        PLATFORM="linux/amd64"
    else
        PLATFORM=${TARGETPLATFORM}
    fi

    if [ -z "$PLATFORM" ]; then
        ARCH="64"
    else
        case "$PLATFORM" in
            linux/386)
                ARCH="32"
                ;;
            linux/amd64)
                ARCH="64"
                ;;
            linux/arm/v6)
                ARCH="arm32-v6"
                ;;
            linux/arm/v7)
                ARCH="arm32-v7a"
                ;;
            linux/arm64|linux/arm64/v8)
                ARCH="arm64-v8a"
                ;;
            linux/ppc64le)
                ARCH="ppc64le"
                ;;
            linux/s390x)
                ARCH="s390x"
                ;;
            *)
                ARCH=""
                ;;
        esac
    fi

    [ -z "${ARCH}" ] && v2ray_error "Error: Not supported OS Architecture"

    # Download files
    V2RAY_FILE="v2ray-linux-${ARCH}.zip"
    DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
    v2ray_note "Downloading binary file: ${V2RAY_FILE}"
    v2ray_note "Downloading binary file: ${DGST_FILE}"

    TAG_URL="https://raw.githubusercontent.com/v2fly/docker/master/ReleaseTag"
    TAG=$(curl -fsSL ${TAG_URL} -x ${HTTP_PROXY})

    URL_BASE="https://github.com/v2fly/v2ray-core/releases/download"
    URL_V2RAY="${URL_BASE}/${TAG}/${V2RAY_FILE}"
    URL_V2RAY_DGST="${URL_BASE}/${TAG}/${DGST_FILE}"

    v2ray_note "tag: ${TAG}"
    v2ray_note "v2ray.zip url: ${URL_V2RAY}"
    v2ray_note "v2ray.zip.dgst url: ${URL_V2RAY_DGST}"
    curl -fsSL --remote-name ${URL_V2RAY} -x ${HTTP_PROXY}
    curl -fsSL --remote-name ${URL_V2RAY_DGST} -x ${HTTP_PROXY}

    if [ $? -ne 0 ]; then
        v2ray_error "Error: Failed to download binary file: ${V2RAY_FILE} ${DGST_FILE}"
    fi
    v2ray_note "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

    # Check SHA512
    LOCAL=$(openssl dgst -sha512 ${V2RAY_FILE} | sed 's/([^)]*)//g')
    STR=$(cat ${DGST_FILE} | grep 'SHA512' | head -n1)

    if [ "${LOCAL}" = "${STR}" ]; then
        v2ray_note " Check passed" && rm -fv ${DGST_FILE}
    else
        v2ray_error " Check have not passed yet "
    fi
}

v2ray_download "$@"
