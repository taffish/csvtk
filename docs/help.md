taf-csvtk 0.37.0-r1

Purpose:
  csvtk v0.37.0 is a fast command-line toolkit for reproducible CSV/TSV
  inspection, conversion, filtering, joining, reshaping, summary statistics,
  XLSX conversion, simple plots, and compressed table streams.

Usage:
  taf-csvtk -- --help
  taf-csvtk csvtk --version
  taf-csvtk csvtk summary -f count:sum -g group table.csv
  taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv

Command mode:
  csvtk uses subcommands such as cut, filter2, summary, join, csv2xlsx,
  xlsx2csv, csv2json, plot, and genautocomplete. Because command_mode is
  enabled, include the executable name:

    taf-csvtk csvtk cut -f sample,count table.csv
    taf-csvtk csvtk filter2 -f '$count >= 10' table.csv
    taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx

  Avoid ambiguous forms such as:

    taf-csvtk cut -f sample table.csv

Common workflows:
  Version:
    taf-csvtk csvtk --version

  Inspect dimensions and headers:
    taf-csvtk csvtk dim table.csv
    taf-csvtk csvtk headers table.csv

  Convert CSV and TSV:
    taf-csvtk csvtk csv2tab table.csv > table.tsv
    taf-csvtk csvtk -t tab2csv table.tsv > table.csv

  Filter and select columns:
    taf-csvtk csvtk cut -f sample,count table.csv > selected.csv
    taf-csvtk csvtk filter2 -f '$count >= 10' table.csv > filtered.csv

  Summarize and join:
    taf-csvtk csvtk summary -f count:sum -g group table.csv > summary.csv
    taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv

  XLSX and JSON:
    taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
    taf-csvtk csvtk xlsx2csv table.xlsx > table.csv
    taf-csvtk csvtk csv2json table.csv > table.json

Packaged commands:
  csvtk    upstream csvtk executable.

Inputs:
  CSV/TSV text tables, stdin streams, and compressed table files supported
  by upstream csvtk, including gzip, xz, zstd, bzip2, and LZ4 where supported.
  XLSX input/output is available through csvtk xlsx2csv and csv2xlsx.

Key outputs:
  CSV, TSV, JSON, Markdown, reStructuredText, XLSX, text summaries, and plots
  depending on the selected upstream subcommand.

Platform and resources:
  Uses official upstream static Linux binaries for linux/amd64 and linux/arm64.
  No external database, model, interpreter, or server is required.

Boundaries:
  This app packages csvtk itself. It does not bundle spreadsheet GUI tools,
  office suites, database servers, R/Python notebook environments, or example
  datasets. Plot commands are provided by upstream csvtk, but smoke only checks
  CLI availability and table-processing paths, not every graphical style.

Detailed documentation:
  https://bioinf.shenwei.me/csvtk/
  https://bioinf.shenwei.me/csvtk/usage/

Wrapper options:
  taf-csvtk --help       Show this TAFFISH help.
  taf-csvtk --version    Show the TAFFISH package version.
  taf-csvtk --compile    Print the generated runner.
  taf-csvtk -- --help    Pass option-leading arguments to the default command.

License:
  TAFFISH app packaging: Apache-2.0.
  Upstream software: MIT.
