taf-csvtk 0.38.0-r1

Purpose:
  Process CSV/TSV tables, convert XLSX, draw static plots, and export an
  offline HTML table. The default interface is the csvtk command-line tool.

Usage:
  taf-csvtk -- --help
  taf-csvtk csvtk SUBCOMMAND [OPTIONS] [FILES...]
  Always include csvtk before a subcommand: taf-csvtk cut is not csvtk cut.

Quick start:
  printf 'sample,group,count\ns1,A,2\ns2,A,3\ns3,B,5\n' > table.csv
  taf-csvtk csvtk cut -f sample,count table.csv > selected.csv
  taf-csvtk csvtk summary -g group -f count:sum table.csv > summary.csv

Common tasks:
  taf-csvtk csvtk headers table.csv
  taf-csvtk csvtk filter -f "'count>=3'" table.csv > filtered.csv
  taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
  taf-csvtk csvtk xlsx2csv table.xlsx > restored.csv
  taf-csvtk csvtk csv2tab table.csv > table.tsv
  taf-csvtk csvtk join -f id samples.csv values.csv > joined.csv
  taf-csvtk csvtk long2matrix -f row,col,value long.csv > matrix.csv
  taf-csvtk csvtk matrix2long matrix.csv > long.csv
  taf-csvtk csvtk plot hist -f count table.csv -o counts.png

HTML table:
  TAFFISH_CONTAINER_BACKEND=docker taf-csvtk csvtk csv2html table.csv -o table.html
  TAFFISH_CONTAINER_BACKEND=podman taf-csvtk csvtk csv2html table.csv -o table.html
  TAFFISH_CONTAINER_BACKEND=apptainer taf-csvtk csvtk csv2html table.csv -o table.html
  Choose one backend, then open table.html in your host browser.
  This is an offline static table, with no service, port or search/sort buttons.

Inputs and options:
  CSV headers are expected by default. Use -t for TSV, -H for no header,
  -T for TSV output, -f for fields, -o for output and -j for CPU threads.
  Run from the directory holding your inputs; keep outputs there too.
  gzip/xz/zstd/bzip2/LZ4 compression is selected by filename extension.

Key outputs:
  Tables normally go to stdout; use > result.csv or -o result.csv.
  XLSX, HTML and plot commands create the named file; split creates chunks.
  Existing output files may be overwritten. Never use the input as output.

Immediate notes:
  Apptainer needs Linux and a matching CPU architecture; on macOS use
  Docker or Podman. Table commands require no database, model or GPU.
  In 0.38, uniq -d means repeated keys; use --delimiter for its separator.
  corr writes correlations to stdout; --pass restores input forwarding.
  Use csvtk --version offline; csvtk version checks the network for updates.
  Preserve literal quotes for space-containing paths; see README for filter2:
    taf-csvtk csvtk csv2html --caption "'Sample table'" "'input table.csv'" -o "'output table.html'"

More help:
  taf-csvtk csvtk csv2html --help
  https://bioinf.shenwei.me/csvtk/usage/
  https://github.com/taffish/csvtk

Wrapper options:
  taf-csvtk --help       Show this usage help.
  taf-csvtk --version    Show the TAFFISH package version.
  taf-csvtk --compile    Print the generated runner.
  taf-csvtk -- --help    Show upstream csvtk help.
  taf-csvtk csvtk --version  Show the local upstream version.
