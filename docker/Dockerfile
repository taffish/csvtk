ARG BASE_IMAGE=debian:12-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251
FROM ${BASE_IMAGE} AS fetch
ARG TARGETARCH
ARG CSVTK_VERSION=0.38.0
ARG CSVTK_AMD64_SHA256=43eac0a8e3da02158184737298fad461d1af075f78f049aae9902d868c8846a5
ARG CSVTK_ARM64_SHA256=2f9fc0fb763df5bc83a12d9916f72d16461e70589fb20b190e72a544d5ab5d6f
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl file \
    && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) checksum="$CSVTK_AMD64_SHA256" ;; \
      arm64) checksum="$CSVTK_ARM64_SHA256" ;; \
      *) echo "unsupported TARGETARCH=$TARGETARCH" >&2; exit 1 ;; \
    esac; \
    asset="csvtk_linux_${TARGETARCH}.tar.gz"; \
    url="https://github.com/shenwei356/csvtk/releases/download/v${CSVTK_VERSION}/${asset}"; \
    curl -fL --retry 3 "$url" -o /tmp/csvtk.tar.gz; \
    printf '%s  %s\n' "$checksum" /tmp/csvtk.tar.gz | sha256sum -c -; \
    mkdir -p /opt/csvtk/bin /opt/csvtk/share; \
    tar -xzf /tmp/csvtk.tar.gz -C /opt/csvtk/bin csvtk; \
    chmod 0755 /opt/csvtk/bin/csvtk; \
    file /opt/csvtk/bin/csvtk | grep -F 'statically linked'; \
    printf 'upstream=shenwei356/csvtk\ntag=v%s\ncommit=7f2e233e5381c5c51799d6e17e4c2ce2d2426db3\nasset=%s\nsha256=%s\narch=%s\n' \
      "$CSVTK_VERSION" "$asset" "$checksum" "$TARGETARCH" > /opt/csvtk/share/source.txt
COPY docker/licenses.tar.gz /tmp/licenses.tar.gz
RUN echo '8ba6d877eea09d70f0fee5f355047e3777f9d4cffc374845343e914c4098e5e7  /tmp/licenses.tar.gz' | sha256sum -c - \
    && tar -xzf /tmp/licenses.tar.gz -C /opt/csvtk/share

FROM ${BASE_IMAGE}
COPY --from=fetch /opt/csvtk /opt/csvtk
COPY --from=fetch /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY docker/smoke.sh /opt/csvtk/share/smoke.sh
ENV PATH=/opt/csvtk/bin:${PATH} \
    TAFFISH_ENV=TAFFISH \
    TAFFISH_NAME=csvtk
# Native multi-platform build gate: identity/help and tiny non-rendering work only.
# XLSX, compression, HTML and plots are exercised by independent runtime smoke.
RUN set -eu; \
    csvtk --version > /tmp/version; grep -Fx 'csvtk v0.38.0' /tmp/version; \
    csvtk --help > /tmp/help; grep -F 'CSV/TSV toolkit' /tmp/help; \
    printf 'id,value\na,2\n' | csvtk cut -f value > /tmp/tiny; \
    printf 'value\n2\n' > /tmp/expected; cmp /tmp/tiny /tmp/expected; \
    rm /tmp/version /tmp/help /tmp/tiny /tmp/expected
WORKDIR /root
