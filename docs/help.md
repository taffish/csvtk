taf-csvtk 0.39.0-r1

Process CSV/TSV data, convert workbooks, and export static plots or HTML.

Quick start:
  printf 'sample,group,count\ns1,A,2\ns2,A,3\ns3,B,5\n' > table.csv
  taf-csvtk csvtk headers table.csv
  taf-csvtk csvtk cut -f sample,count table.csv -o selected.csv
  taf-csvtk csvtk summary -g group -f count:sum table.csv -o summary.csv

Usage:
  taf-csvtk csvtk SUBCOMMAND [OPTIONS] [FILES...]
  Include csvtk before a subcommand: bare cut may run the system cut instead.
  taf-csvtk --help shows this guide; taf-csvtk -- --help shows upstream help.
  taf-csvtk --version shows the package; taf-csvtk csvtk --version is offline.

Common tasks:
  taf-csvtk csvtk filter -f "'count>=3'" table.csv -o filtered.csv
  taf-csvtk csvtk csv2xlsx table.csv -o table.xlsx
  taf-csvtk csvtk xlsx2csv table.xlsx -o restored.csv
  taf-csvtk csvtk csv2tab table.csv -o table.tsv
  taf-csvtk csvtk plot hist -f count table.csv -o counts.png
  taf-csvtk csvtk join -f id left.csv right.csv -o joined.csv

Static HTML (choose one backend):
  TAFFISH_CONTAINER_BACKEND=docker taf-csvtk csvtk csv2html table.csv -o table.html
  TAFFISH_CONTAINER_BACKEND=podman taf-csvtk csvtk csv2html table.csv -o table.html
  TAFFISH_CONTAINER_BACKEND=apptainer taf-csvtk csvtk csv2html table.csv -o table.html
  Open table.html on the host. It is a single offline table with no server
  or search/sort controls. Use browser zoom or scroll to read wide tables.

Inputs and outputs:
  Run in your working directory. CSV headers are expected; -t reads TSV,
  -T writes TSV, -H reads without a header, and -f selects fields by name or
  position. Use - to read stdin; compression follows the filename extension.
  For a path or caption containing spaces, preserve literal inner quotes:
    taf-csvtk csvtk csv2html --caption "'Sample table'" "'input table.csv'" -o "'output table.html'"
  Tables default to stdout. Use a distinct output path: csvtk rejects -o
  pointing at an input, but the shell truncates '> input.csv' before csvtk
  can protect it. Existing unrelated outputs may be replaced.
  No database, model, GPU or display is required. To check for updates online
  use taf-csvtk csvtk version --check-update; without that flag it stays offline.

More help:
  taf-csvtk csvtk csv2html --help
  taf-csvtk csvtk split --help
  https://bioinf.shenwei.me/csvtk/usage/
