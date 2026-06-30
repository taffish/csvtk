# taf-csvtk

`taf-csvtk` packages csvtk `0.37.0-r1`, a fast command-line toolkit for reproducible CSV/TSV table processing.

Package identity:

- name: `csvtk`
- command: `taf-csvtk`
- kind: `tool`
- TAFFISH version: `0.37.0-r1`
- container image: `ghcr.io/taffish/csvtk:0.37.0-r1`
- upstream release: `v0.37.0`
- runtime version string: `csvtk v0.37.0`
- upstream license: MIT
- Linux amd64 archive SHA256: `f6d09493b7ad1ba8c5ee79e6904de9499f7411ca97fcfcd8cf6b816e9c967411`
- Linux arm64 archive SHA256: `7f481b8ee1948b14c3d7a1c9c6c8cdf36d3f537c5a51f07af7f243e4ee31b708`

## What Is Included

This app installs the official upstream static Linux binary for the target container architecture. csvtk itself is a single executable and does not require external databases, models, interpreters, or office suites for its ordinary command-line operation.

csvtk supports common table work including:

- inspecting headers and dimensions with `headers`, `dim`, `nrow`, and `ncol`
- summary statistics with `summary` and correlation with `corr`
- format conversion with `csv2tab`, `tab2csv`, `csv2json`, `csv2md`, `csv2rst`, `csv2xlsx`, and `xlsx2csv`
- row and field operations with `cut`, `grep`, `filter`, `filter2`, `uniq`, `freq`, `inter`, `join`, `sample`, and `concat`
- table editing with `fix`, `fix-quotes`, `add-header`, `rename`, `replace`, `round`, `mutate`, and related commands
- reshaping with `transpose`, `sep`, `gather`, `spread`, `unfold`, and `fold`
- sorting and shuffling with `sort` and `shuf`
- common upstream plot subcommands through `csvtk plot`
- compressed input/output including gzip, xz, zstd, bzip2, and LZ4 where supported by upstream csvtk

## Command Mode

`taf-csvtk --help` prints this TAFFISH app help. Use `--` only when passing option-leading arguments to the default upstream command:

```sh
taf-csvtk -- --help
```

csvtk is a subcommand-based CLI. Because this TAFFISH app keeps `command_mode = true`, use the upstream executable name when running csvtk subcommands:

```sh
taf-csvtk csvtk --version
taf-csvtk csvtk dim table.csv
taf-csvtk csvtk summary -f count:sum -g group table.csv
taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv
```

Avoid ambiguous forms such as `taf-csvtk cut -f sample table.csv`; TAFFISH may treat `cut` as a container command rather than as `csvtk cut`.

## Common Workflows

Inspect dimensions and headers:

```sh
taf-csvtk csvtk dim table.csv
taf-csvtk csvtk headers table.csv
```

Convert between CSV and TSV:

```sh
taf-csvtk csvtk csv2tab table.csv > table.tsv
taf-csvtk csvtk -t tab2csv table.tsv > table.csv
```

Select columns and filter rows:

```sh
taf-csvtk csvtk cut -f sample,count table.csv > selected.csv
taf-csvtk csvtk filter2 -f '$count >= 10' table.csv > filtered.csv
```

Summarize by group:

```sh
taf-csvtk csvtk summary -f count:sum,count:mean -g group table.csv > summary.csv
```

Join two tables:

```sh
taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv
```

Convert to and from XLSX:

```sh
taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
taf-csvtk csvtk xlsx2csv table.xlsx > table.csv
```

Use compressed streams:

```sh
taf-csvtk csvtk cat table.csv -o table.csv.lz4
taf-csvtk csvtk headers table.csv.lz4
```

## Boundaries

This app exposes the upstream csvtk executable and its built-in subcommands. It does not bundle spreadsheet GUI tools, office suites, database servers, R/Python notebook environments, or tutorial datasets.

The upstream `plot` command group is included because it is part of csvtk. The normal smoke tests focus on table inspection, filtering, summary, joining, conversion, XLSX, compression, help, and version paths; they do not exhaustively validate every plot style or every subcommand combination.

The upstream `version` subcommand is documented as checking for updates. For offline validation and smoke tests, this app uses the global `csvtk --version` output instead of invoking update-checking behavior.

## Platform

The image uses official upstream static Linux binaries and is intended for native `linux/amd64` and `linux/arm64` container platforms.

## License Boundary

The TAFFISH app packaging files are licensed under Apache-2.0. The packaged upstream csvtk software is covered by: MIT. Bundled third-party components, datasets, models, and external resources keep their own license terms.

## Upstream

- Upstream repository: <https://github.com/shenwei356/csvtk>
- Upstream documentation: <https://bioinf.shenwei.me/csvtk/>
- Upstream usage: <https://bioinf.shenwei.me/csvtk/usage/>
- Upstream release: <https://github.com/shenwei356/csvtk/releases/tag/v0.37.0>
- Upstream license: MIT

No dedicated csvtk paper was found in the upstream README at packaging time. Cite the upstream project, version, and documentation URL when reporting workflows that depend on csvtk.
