ARG CSVTK_VERSION=0.37.0
ARG CSVTK_TAG=v0.37.0
ARG CSVTK_AMD64_SHA256=f6d09493b7ad1ba8c5ee79e6904de9499f7411ca97fcfcd8cf6b816e9c967411
ARG CSVTK_ARM64_SHA256=7f481b8ee1948b14c3d7a1c9c6c8cdf36d3f537c5a51f07af7f243e4ee31b708

FROM debian:12-slim AS fetch

ARG TARGETARCH
ARG CSVTK_VERSION
ARG CSVTK_TAG
ARG CSVTK_AMD64_SHA256
ARG CSVTK_ARM64_SHA256

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) csvtk_arch="amd64"; csvtk_sha="${CSVTK_AMD64_SHA256}" ;; \
      arm64) csvtk_arch="arm64"; csvtk_sha="${CSVTK_ARM64_SHA256}" ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      -o csvtk.tar.gz \
      "https://github.com/shenwei356/csvtk/releases/download/${CSVTK_TAG}/csvtk_linux_${csvtk_arch}.tar.gz"; \
    echo "${csvtk_sha}  csvtk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/csvtk/bin /opt/csvtk/share/doc/csvtk /opt/csvtk/share/licenses/csvtk; \
    tar -xzf csvtk.tar.gz -C /opt/csvtk/bin csvtk; \
    chmod 0755 /opt/csvtk/bin/csvtk; \
    curl --retry 5 --retry-delay 2 --retry-all-errors -fsSL \
      -o /opt/csvtk/share/licenses/csvtk/LICENSE \
      "https://raw.githubusercontent.com/shenwei356/csvtk/${CSVTK_TAG}/LICENSE"; \
    { \
      printf "upstream_repo=https://github.com/shenwei356/csvtk\n"; \
      printf "upstream_tag=%s\n" "${CSVTK_TAG}"; \
      printf "runtime_source=official GitHub release binary\n"; \
      printf "runtime_asset=csvtk_linux_%s.tar.gz\n" "${csvtk_arch}"; \
      printf "runtime_asset_sha256=%s\n" "${csvtk_sha}"; \
      printf "target_arch=%s\n" "${csvtk_arch}"; \
    } > /opt/csvtk/share/doc/csvtk/source.txt; \
    /opt/csvtk/bin/csvtk --version 2>&1 | grep -Fx "csvtk v${CSVTK_VERSION}" >/dev/null; \
    /opt/csvtk/bin/csvtk --help 2>&1 | grep -F "CSV/TSV toolkit" >/dev/null; \
    file /opt/csvtk/bin/csvtk | grep -E "(statically linked|static)" >/dev/null

FROM debian:12-slim

ARG CSVTK_VERSION

LABEL maintainer="taffish@163.com"

COPY --from=fetch /opt/csvtk /opt/csvtk

RUN set -eux; \
    ln -sf /opt/csvtk/bin/csvtk /usr/local/bin/csvtk; \
    command -v csvtk >/dev/null; \
    command -v ldd >/dev/null; \
    csvtk --version 2>&1 | grep -Fx "csvtk v${CSVTK_VERSION}" >/dev/null; \
    csvtk --help 2>&1 | grep -F "CSV/TSV toolkit" >/dev/null; \
    csvtk summary --help 2>&1 | grep -F "summary statistics" >/dev/null; \
    csvtk join --help 2>&1 | grep -F "join files by selected fields" >/dev/null; \
    csvtk csv2xlsx --help 2>&1 | grep -F "convert CSV/TSV files to XLSX file" >/dev/null; \
    csvtk plot --help 2>&1 | grep -F "plot common figures" >/dev/null; \
    mkdir -p /tmp/csvtk-check; \
    cd /tmp/csvtk-check; \
    printf 'sample,group,count\ns1,A,10\ns2,A,12\ns3,B,7\ns4,B,9\n' > table.csv; \
    csvtk dim table.csv > dim.txt; \
    grep -F "table.csv" dim.txt >/dev/null; \
    grep -F "num_rows" dim.txt >/dev/null; \
    csvtk cut -f sample,count table.csv > cut.csv; \
    grep -F "sample,count" cut.csv >/dev/null; \
    csvtk filter2 -f '$count >= 10' table.csv > filtered.csv; \
    grep -F "s2,A,12" filtered.csv >/dev/null; \
    csvtk summary -f count:sum -g group table.csv > summary.csv; \
    grep -F "A,22.00" summary.csv >/dev/null; \
    csvtk csv2tab table.csv > table.tsv; \
    grep -F "sample	group	count" table.tsv >/dev/null; \
    csvtk -t tab2csv table.tsv > round.csv; \
    grep -F "s4,B,9" round.csv >/dev/null; \
    csvtk csv2json table.csv > table.json; \
    grep -F '"sample": "s1"' table.json >/dev/null; \
    csvtk csv2xlsx table.csv -o table.xlsx; \
    test -s table.xlsx; \
    csvtk xlsx2csv table.xlsx > from_xlsx.csv; \
    grep -F "s3,B,7" from_xlsx.csv >/dev/null; \
    csvtk cat table.csv -o table.csv.lz4; \
    test -s table.csv.lz4; \
    csvtk headers table.csv.lz4 > headers.txt; \
    grep -F "count" headers.txt >/dev/null; \
    { ldd "$(command -v csvtk)" 2>&1 || true; } | grep -E "(not a dynamic executable|statically linked)" >/dev/null; \
    rm -rf /tmp/csvtk-check

ENV PATH=/opt/csvtk/bin:${PATH}

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=csvtk

WORKDIR /root
