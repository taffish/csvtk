# taf-csvtk

csvtk packages a fast CSV/TSV command-line toolkit for reproducible table
inspection, conversion, joins, reshaping, statistics and static plots.

Package identity:

- name: `csvtk`; command: `taf-csvtk`; kind: `tool`
- TAFFISH version: `0.38.0-r1`; packaging license: Apache-2.0
- image: `ghcr.io/taffish/csvtk:0.38.0-r1`
- upstream: [csvtk v0.38.0](https://github.com/shenwei356/csvtk/releases/tag/v0.38.0)
- upstream tag commit: `7f2e233e5381c5c51799d6e17e4c2ce2d2426db3`
- runtime: `csvtk v0.38.0`; upstream license: MIT
- native platforms: `linux/amd64,linux/arm64`

## What This App Packages

The unchanged official static Linux executable, with all upstream subcommands,
runs through the two-line TAFFISH wrapper. No forwarding entrypoint is added.
Version 0.38.0 adds `csv2html`, `long2matrix`, `matrix2long`, `paste`,
`--quote-all`, Unicode-length sorting, parallel multi-field fold/unfold,
named summary columns and record-count/chunk-count splitting.

Migration notes:

- `corr` now writes correlations to stdout or `-o`. Use `--pass` to forward
  input to stdout and write correlations to stderr.
- `uniq -d` now means repeated keys; use `--delimiter` for its input delimiter.
- Upstream also fixes missing-value handling, composite-key collisions,
  joins involving empty keys/header-only files, and Unicode `mutate2 len`.
  The binary is not patched to emulate the previous version.

## Scope and Container Contents

Included: inspection, filtering, sorting, joins/set operations, statistics,
reshaping, CSV/TSV/JSON/Markdown/reStructuredText/XLSX conversion, compressed
streams, PNG/PDF/SVG plots and standalone HTML tables. XLSX uses embedded
Excelize; compression uses embedded Go libraries; plots use Gonum and bundled
fonts. An office suite, Python/R, browser server or X11 is not required.

The official installation instructions, Go module graph, command registry and
release documentation were checked for optional GUI/plugin/companion paths.
The browser surface is `csv2html`, included in the same binary. Plot examples
pipe to an external image viewer; that is a separate host viewing step, not a
hidden executable launched by csvtk. No separate official desktop companion
was identified. Web browsers and spreadsheet editors are not bundled.

The Debian 12 slim runtime includes POSIX shell/text utilities for validation
and a CA certificate bundle for the explicit online update checker. Fetch/build
tools and archives remain in the builder stage. Source identity is recorded at
`/opt/csvtk/share/source.txt`; original upstream, Go, module and font license
notices plus module inventory are under `/opt/csvtk/share/licenses`.

## Install and Usage

After this candidate is published:

```sh
taf update
taf install csvtk
taf-csvtk --help
taf-csvtk -- --help
taf-csvtk csvtk --version
```

Run from a directory containing your input files. A complete tiny example:

```sh
printf 'sample,group,count\ns1,A,2\ns2,A,3\ns3,B,5\n' > table.csv
taf-csvtk csvtk cut -f sample,count table.csv > selected.csv
taf-csvtk csvtk summary -g group -f count:sum table.csv > summary.csv
taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
taf-csvtk csvtk xlsx2csv table.xlsx > roundtrip.csv
taf-csvtk csvtk csv2html table.csv -o table.html
```

Open `table.html` in your host browser; the HTML embeds its CSS, escapes input
cell text, uses system fonts, and needs no network, service, port or container
after generation. It is a read-only table, not an interactive spreadsheet:
there are no sort/search/download buttons. Browser zoom, text selection and
horizontal scrolling are ordinary browser actions. Treat exported tables as
data-bearing files; do not share sensitive sample metadata unintentionally.

## Command Mode and Quoting

Use `taf-csvtk csvtk SUBCOMMAND ...`. For example, bare
`taf-csvtk cut ...` can select the system `cut` executable, not `csvtk cut`.
`taf-csvtk -- --help` passes option-leading arguments to the default command.

Current TAFFISH command mode reassembles a shell command. Preserve literal
quotes around a space-containing argument or expression (ordinary shell
quoting alone is insufficient at this boundary):

```sh
taf-csvtk csvtk filter -f "'count>=3'" table.csv > filtered.csv
taf-csvtk csvtk csv2html --caption "'Sample table'" \
  "'input table.csv'" -o "'output table.html'"
```

Use simple project-relative paths where possible. Do not interpolate untrusted
text into shell expressions; review free-text/filename quoting before running.

For `filter2` expressions containing both `$` and shell metacharacters,
the generated here-document adds another expansion layer. This exact tested
form preserves the dollar sign as well as the space-containing expression:

```sh
taf-csvtk csvtk filter2 -f "'\\\$count >= 3'" table.csv > filtered.csv
```

This escaping is a TAFFISH 0.11 runtime boundary, not a csvtk syntax change.

## Common Tasks

```sh
taf-csvtk csvtk headers table.csv
taf-csvtk csvtk csv2tab table.csv > table.tsv
taf-csvtk csvtk -t tab2csv table.tsv > restored.csv
taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv
taf-csvtk csvtk uniq -f id --repeated table.csv > duplicates.csv
taf-csvtk csvtk long2matrix -f row,col,value long.csv > matrix.csv
taf-csvtk csvtk matrix2long matrix.csv > long.csv
taf-csvtk csvtk paste left.csv right.csv > combined.csv
taf-csvtk csvtk plot hist -f count table.csv -o counts.png
taf-csvtk csvtk cat table.csv -o table.csv.lz4
```

## Inputs and Output Notes

CSV with a header row is the default; `-t` selects TSV and `-H` indicates
no input header. Use `-T` for tab-delimited output and `-j` to bound CPUs.
Files or stdin are accepted by the relevant subcommand. Output is normally
stdout; `-o` selects a file, while `split -o` selects an output directory.
Compression follows the filename extension: gzip, xz, zstd, bzip2 and LZ4.

Text and plot outputs may overwrite the named file; shell `>` truncates it.
Keep output separate from input, inspect existing paths, and use a fresh
directory for `split`. HTML reruns replace the file rather than update it
incrementally. XLSX handles its own workbook format; no Excel installation is
needed. Large joins/sorts/matrix conversion may use memory proportional to the
input; small smoke tests do not establish large-data memory/performance limits.

## Resources and Runtime Write Map

Resource classification: CSV/TSV/XLSX files are user/project-specific inputs.
The fixed fonts and rendering libraries are small bundled runtime resources.
No database, model, taxonomy/reference catalog, setup/downloader command or
implicit analysis-time resource download was found in this release.
Therefore a shared-resource installer, site discovery, model override and
administrator-once database installation are N/A, not deferred work.

Normal table conversion and plotting work offline. `csvtk --version` is local;
the separate `csvtk version` subcommand deliberately checks GitHub for updates
and is excluded from offline smoke. Completion generation writes the requested
shell-completion path; it does not configure the host shell automatically.

| Write class | Location / contract |
| --- | --- |
| Explicit results | stdout, current working directory or explicit output path on the host bind |
| Temporary XLSX/validation work | OS temporary directory; smoke uses unique private `/tmp/taf-csvtk.*` |
| Persistent database/model/cache | None required |
| Binary, notices, embedded fonts | Immutable image content; no runtime writes |

## Backends and Platforms

Select the backend without changing the table-processing command:

```sh
TAFFISH_CONTAINER_BACKEND=docker taf-csvtk csvtk csv2html table.csv -o table.html
TAFFISH_CONTAINER_BACKEND=podman taf-csvtk csvtk csv2html table.csv -o table.html
TAFFISH_CONTAINER_BACKEND=apptainer taf-csvtk csvtk csv2html table.csv -o table.html
```

All three use the wrapper's current-directory bind for input/output.
No app-specific mount, GPU/device, port, service or emulation flags are needed.
Apptainer requires Linux and an architecture-matched image/SIF; it is not a
native macOS backend. On macOS use Docker/Podman's Linux VM.

Candidate validation (2026-09-25):

| Native platform | Docker | Podman | Apptainer |
| --- | --- | --- | --- |
| linux/amd64 on xjp | 46 exact normal/read-only probes; 23 wrapper checks PASS | 46 exact normal/read-only probes; 23 wrapper checks PASS | 23 actual read-only SIF probes; 23 wrapper checks PASS |
| linux/arm64 in local Linux VMs | Native build and 46 exact probes PASS; full wrapper run interrupted by Docker Desktop failure | 46 exact probes and 23 wrapper checks PASS | Not separately validated |

The 207 direct probes use fresh offline execution, no repository/production
bind, and only explicit temporary scratch. Wrapper checks separately verify
ordinary-user host outputs, read-only inputs, overwrite behavior, quoting and
all three plot formats. The amd64 SIF was built from the same candidate Docker
archive used by Podman, not a previously published image.

Platform and backend coverage are separate axes: there is no app-specific
GPU/device/network/service coupling here. ARM Apptainer and the interrupted
ARM Docker wrapper are not claimed as combination passes. Docker's complete
backend evidence is from xjp; the local Docker Desktop failure was not hidden
by changing app code or restarting the user's daemon.

The four completed wrapper paths emitted identical standalone HTML bytes.
Caption, three data rows, Unicode, escaped cell text and absence of external
resources passed static checks. On 2026-09-25 the maintainer confirmed that the
HTML displayed correctly in their browser. This is manual visual/functional
acceptance, not an automated browser trace: the automation browser denied
local file access under its security policy, and that restriction was not
bypassed. No browser console/network trace is claimed; the artifact contains
no scripts or external runtime resources.

## Testing and Build Provenance

The manifest runs nine independent offline modes: identity/help, basic tables,
text conversions/compressed roundtrips, joins, XLSX/stdin, reshaping, 0.38
behavior changes, PNG/PDF/SVG output and HTML/escaping/negative paths. Each test
creates its own scratch input. Build-time checks are restricted to exact
version, ordinary help and tiny column extraction; rendering stays at runtime.

Official release archive SHA256:

- amd64: `43eac0a8e3da02158184737298fad461d1af075f78f049aae9902d868c8846a5`
- arm64: `2f9fc0fb763df5bc83a12d9916f72d16461e70589fb20b190e72a544d5ab5d6f`

Both stages pin the Debian multi-platform manifest. The checked license bundle
preserves notices from the fixed Go module graph; every module archive was
verified against upstream `go.sum`. This is not a rebuild of the official binary.
The official assets report Go 1.27.0, embedded VCS revision
`eba3d1511b253d2d01c2253932db916537383c5c` and `vcs.modified=true`, distinct from
the final release tag commit above. Both assets match the official release
checksums and report `csvtk v0.38.0`; this upstream build-provenance difference
is preserved, not represented as a clean build from the tag. All 50 embedded
dependency identities match the collected notices; the bundled Go license
was also compared with Go 1.27.0's original license.

Final uncompressed image sizes are 95.49 MiB (amd64) and 118.32 MiB (arm64).
The final stage contains the runtime binary, notices, CA bundle and Debian
runtime, with no fetch tools, source archive or package-download cache copied
from the builder. Directory and layer profiles found no further obvious
safe bulk cleanup that justified removing runtime functionality.

The old standard image Action was replaced as one whole file from a fresh
`taf new --tool --docker` scaffold. Final SHA256 is
`c1f2fa9d87561bb49447ce346dcb2d4d246fa0b1196d02eca10df6afbe5f12ca`;
byte comparison passed. It uses native amd64/arm64 runners and repository-root
context without app-specific workflow edits. Both native candidate builds used
that root context. Local builds and dry-run do not establish that GitHub Actions,
GHCR publication or Hub Index have completed.

Maintainer validation uses repository-root context:

```sh
taf check
docker build -f docker/Dockerfile .
taf build
taf run -b podman csvtk csv2html table.csv -o table.html
taf publish --build --release --dry-run
```

Then clear local validation target artifacts before handoff; the maintainer's
actual `taf publish --build --release` regenerates the formal wrapper.
Passing smoke does not exhaustively validate all commands, arbitrary malformed
files, scientific correctness or large production datasets.

## Troubleshooting

- Wrong command: retain the second `csvtk` before subcommands.
- Split arguments or empty filter expression: use the literal-quote syntax above.
- Wrong columns: check header names and CSV versus TSV flags.
- Permission/read-only error: write to the current host working directory,
  not the image's `/opt` tree; ensure the host directory is writable.
- HTML does not offer filtering: it is a static table; filter via csvtk first.

## License and Citation

TAFFISH packaging is Apache-2.0; csvtk is MIT. Embedded Go dependencies and
Liberation fonts retain their original notices/terms (including the font OFL)
in the image. User data is not relicensed by this app.
No dedicated csvtk paper was found in the target release README; cite the
[upstream project](https://github.com/shenwei356/csvtk), version and
[usage manual](https://bioinf.shenwei.me/csvtk/usage/).
