# taf-csvtk

Use [csvtk](https://github.com/shenwei356/csvtk) to inspect, select, join and reshape CSV/TSV tables, convert workbooks, and produce static plots or an offline HTML table. This TAFFISH tool packages unmodified [csvtk v0.39.0](https://github.com/shenwei356/csvtk/releases/tag/v0.39.0) as `0.39.0-r1` for Linux amd64 and arm64. Image: `ghcr.io/taffish/csvtk:0.39.0-r1`.

## Installation

After this version appears in the TAFFISH index, run `taf update` and `taf install csvtk 0.39.0-r1`. Use `taf-csvtk-v0.39.0-r1` for the exact version or `taf-csvtk` for the installed alias. Docker, Podman or Linux Apptainer must be available on the host.

## Quick start

Run from your working directory; relative input and output paths are shared with the container.

```sh
printf 'sample,group,count\ns1,A,2\ns2,A,3\ns3,B,5\n' > table.csv
taf-csvtk csvtk cut -f sample,count table.csv -o selected.csv
taf-csvtk csvtk summary -g group -f count:sum table.csv -o summary.csv
taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
taf-csvtk csvtk xlsx2csv table.xlsx -o restored.csv
taf-csvtk csvtk plot hist -f count table.csv -o counts.png
taf-csvtk csvtk csv2html table.csv -o table.html
```

Use `taf-csvtk --help` for package help, `taf-csvtk -- --help` for upstream help, and `taf-csvtk csvtk SUBCOMMAND --help` for specific flags. Include the literal command name: `taf-csvtk cut` may select the system `cut`, not `csvtk cut`. The two-line wrapper adds no output transformation. `csvtk --version` and plain `csvtk version` are offline; only `csvtk version --check-update` requests the latest version from GitHub.

## Files, pipes and quoting

Input is normally a headered CSV; `-t` selects TSV, `-H` means no header, `-T` writes TSV. Use `-f` to select fields, `-j` to set threads, and `-` for stdin. gzip, xz, zstd, bzip2 and LZ4 streams use filename extensions. For example:

```sh
taf-csvtk csvtk filter -f "'count>=3'" table.csv > filtered.csv
taf-csvtk csvtk csv2html --caption "'Sample table'" "'input table.csv'" -o "'output table.html'"
```

For spaces or shell operators the inner quotes must survive the calling shell and TAFFISH command mode. The second example assumes a file named `input table.csv`. Do not interpolate untrusted filenames or expressions into shell code.

For `filter2` expressions containing both `$` and shell metacharacters,
the generated here-document adds another expansion layer. This exact tested
form preserves the dollar sign as well as the space-containing expression:

```sh
taf-csvtk csvtk filter2 -f "'\\\$count >= 3'" table.csv > filtered.csv
```

This escaping is a TAFFISH 0.11 runtime boundary, not a csvtk syntax change.

Use different input/output names. Version 0.39 rejects `-o` pointing to the primary or an auxiliary input, including filesystem aliases. This **cannot** protect `cmd input.csv > input.csv`: the shell truncates the file before csvtk runs. Other pre-existing outputs can be replaced; use a new directory for `split`.

## Backends, shared inputs and reports

Set `TAFFISH_CONTAINER_BACKEND` to `docker`, `podman`, or `apptainer` and use the same commands above. On macOS, use a Docker or Podman Linux VM. Linux Apptainer uses the corresponding SIF. No GPU, network access, browser service, display or port is needed for table processing. The native `csv2html` output is a self-contained table with inline CSS: open the file on the host, zoom or scroll to read it. There is no in-page filtering or sorting. Chart exports are static PNG/PDF/SVG; `watch` is an upstream terminal command.

There is no installable database, model or shared catalog. Tables, workbooks and lookup lists are user inputs, not versioned app resources. Fonts, compression, Excelize and plotting libraries are built into the Go binary. A site can share read-only input files without a helper; set the appropriate extra bind and write results to the current directory:

```sh
TAFFISH_CONTAINER_BACKEND=docker TAFFISH_DOCKER_RUN_ARGS='-v /srv/tables:/input:ro' taf-csvtk csvtk headers /input/table.csv
TAFFISH_CONTAINER_BACKEND=podman TAFFISH_PODMAN_RUN_ARGS='-v /srv/tables:/input:ro' taf-csvtk csvtk headers /input/table.csv
TAFFISH_CONTAINER_BACKEND=apptainer TAFFISH_APPTAINER_RUN_ARGS='--bind /srv/tables:/input:ro' taf-csvtk csvtk headers /input/table.csv
```

Prepare /srv/tables and grant users read/traverse access first. Use an absolute host path that is visible to the container engine. No shell, daemon or port is kept open after an export.

## Changes, provenance and licenses

0.39.0 fixes input/output collisions, column selection, Markdown pipes and multiline cells, wide XLSX conversion, and several plotting and numeric edge cases. Option meanings from 0.38 still apply: `uniq -d` selects repeated keys; `corr --pass` forwards the input and reports correlation on stderr. See the [upstream changes](https://github.com/shenwei356/csvtk/releases/tag/v0.39.0) and [command reference](https://bioinf.shenwei.me/csvtk/usage/).

The Linux release artifacts embed clean Git revision `d837219d660af8f874100b385fcfc181e44c777b` and Go 1.27.3. The Dockerfile pins both archive checksums and the Debian base digest. It downloads from upstream at build time; availability of external archives and Debian mirrors is not guaranteed indefinitely. The final stage retains the tool, its notices, runtime smoke, a CA bundle and the minimal Debian userland, not a Go toolchain or module cache.

| Official archive | SHA256 |
| --- | --- |
| linux/amd64 | `8d7a4fa97f847098715431c9a3cb265b7ba0f0a74f154f4ec9abc4ec8ef751a9` |
| linux/arm64 | `d9d0ea8b822c565b634dbb240e686e653ebea0c7f4d92bc3588156f71957c3ba` |

TAFFISH packaging: [Apache-2.0](LICENSE). csvtk: [MIT](https://github.com/shenwei356/csvtk/blob/v0.39.0/LICENSE). The Go runtime, modules and fonts retain their own licenses; see `/opt/csvtk/share/licenses` and `modules.json` in the image. Debian package notices are under `/usr/share/doc`. Cite csvtk and the version used; no database or model license is imposed by this app.

## Candidate validation

Native builds used the app root and `docker/Dockerfile` on both platforms. The pre-publication test environments were:

| Native platform | Final runtime checks | Docker-reported image size |
| --- | --- | ---: |
| Linux amd64 (xjp) | Docker, Podman and a read-only Apptainer SIF made from that same image | 98.91 MiB |
| Linux arm64 | Docker and Podman | 118.05 MiB |

The final wrapper was run in each environment with actual host files as an ordinary user. Checks covered a 703-column XLSX round trip, escaped Markdown/HTML cells, input and lookup-file overwrite rejection (including aliases), compression and static plots. Offline table viewing was confirmed by opening the generated file directly. Docker/Podman used separate offline per-command runs on normal and read-only filesystems and with a non-root UID; the SIF ran without writable installation paths. These are candidate validation results, not a claim that the public release or index build has finished.
