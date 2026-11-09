ARG BASE_IMAGE=debian:12-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc
FROM ${BASE_IMAGE} AS fetch
ARG TARGETARCH
ARG CSVTK_VERSION=0.39.0
ARG CSVTK_AMD64_SHA256=8d7a4fa97f847098715431c9a3cb265b7ba0f0a74f154f4ec9abc4ec8ef751a9
ARG CSVTK_ARM64_SHA256=d9d0ea8b822c565b634dbb240e686e653ebea0c7f4d92bc3588156f71957c3ba
# The base and release archives are pinned. Debian mirror packages, CA updates and
# upstream asset availability may drift; a checksum mismatch must stop the build.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; umask 022; \
    case "$TARGETARCH" in amd64) sum="$CSVTK_AMD64_SHA256" ;; arm64) sum="$CSVTK_ARM64_SHA256" ;; \
      *) echo "unsupported TARGETARCH=$TARGETARCH" >&2; exit 1 ;; esac; \
    asset="csvtk_linux_${TARGETARCH}.tar.gz"; \
    curl -fsSL --retry 3 "https://github.com/shenwei356/csvtk/releases/download/v${CSVTK_VERSION}/${asset}" -o /tmp/csvtk.tar.gz; \
    printf '%s  %s\n' "$sum" /tmp/csvtk.tar.gz | sha256sum -c -; \
    install -d -m 0755 /opt/csvtk/bin /opt/csvtk/share; \
    tar -xOzf /tmp/csvtk.tar.gz csvtk > /opt/csvtk/bin/csvtk; chmod 0755 /opt/csvtk/bin/csvtk; \
    printf 'upstream=shenwei356/csvtk\ntag=v%s\ncommit=d837219d660af8f874100b385fcfc181e44c777b\nasset=%s\nsha256=%s\narch=%s\n' \
      "$CSVTK_VERSION" "$asset" "$sum" "$TARGETARCH" > /opt/csvtk/share/source.txt
COPY docker/licenses.tar.gz /tmp/licenses.tar.gz
RUN set -eu; umask 022; echo '6ba570fe6f74a3acf485469789289e70d48640342ff264b402f614615860c923  /tmp/licenses.tar.gz' | sha256sum -c -; \
    tar -xzf /tmp/licenses.tar.gz -C /opt/csvtk/share
FROM ${BASE_IMAGE}
COPY --from=fetch /opt/csvtk /opt/csvtk
COPY --from=fetch /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY docker/smoke.sh /opt/csvtk/share/smoke.sh
ENV PATH=/opt/csvtk/bin:${PATH} \
    TAFFISH_ENV=TAFFISH \
    TAFFISH_NAME=csvtk
# Keep the native builder gate small: no full-help matching, fonts, GUI or rendering.
RUN csvtk --version && test -s /opt/csvtk/share/licenses/modules.json
WORKDIR /work
