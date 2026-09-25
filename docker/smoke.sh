#!/bin/sh
# 独立模式；所有输入和输出均位于本次私有 scratch，不访问网络或安装树。
set -eu
mode=${1:?expected smoke mode}
scratch=$(mktemp -d /tmp/taf-csvtk.XXXXXX)
finish() {
    code=$?
    trap - EXIT
    if [ "$code" -ne 0 ]; then
        printf 'csvtk-smoke stage=%s exit=%s\n' "$mode" "$code" >&2
        for log in "$scratch"/*.log; do
            [ ! -f "$log" ] || tail -n 40 "$log" >&2
        done
    fi
    rm -rf "$scratch"
    exit "$code"
}
trap finish EXIT
cd "$scratch"
case "$mode" in
  identity)
    csvtk --version > version.log
    grep -Fx 'csvtk v0.38.0' version.log
    csvtk --help > help.log
    grep -F 'CSV/TSV toolkit' help.log
    for sub in summary join csv2xlsx plot csv2html long2matrix matrix2long paste; do
        csvtk "$sub" --help > "$sub.log"
        grep -F 'Usage:' "$sub.log" >/dev/null
    done
    ldd /opt/csvtk/bin/csvtk > static.log 2>&1 || :
    grep -E 'not a dynamic executable|statically linked' static.log
    ;;
  tables)
    printf 'sample,group,count\ns1,A,2\ns2,A,3\ns3,B,5\n' > input.csv
    csvtk dim input.csv > dim.log; grep -F '3' dim.log >/dev/null
    csvtk cut -f sample,count input.csv > cut.log; grep -Fx 's2,3' cut.log
    csvtk filter2 -f '$count >= 3' input.csv > filter.log
    grep -Fx 's2,A,3' filter.log
    if grep -F 's1' filter.log; then exit 1; fi
    csvtk summary -g group -f count:sum,count:mean input.csv > summary.log
    grep -Fx 'A,5.00,2.50' summary.log
    ;;
  formats)
    printf 'id,value\na,2\nb,3\n' > input.csv
    csvtk csv2tab input.csv > input.tsv
    csvtk -t tab2csv input.tsv > roundtrip.csv; cmp input.csv roundtrip.csv
    csvtk csv2json input.csv > json.log; grep -F '"id"' json.log
    csvtk csv2md input.csv > markdown.log; grep -F 'id' markdown.log
    csvtk csv2rst input.csv > rst.log; grep -F 'id' rst.log
    for ext in gz xz zst bz2 lz4; do
        csvtk cat input.csv -o "table.csv.$ext"
        csvtk cut -f 1,2 "table.csv.$ext" > roundtrip.csv
        cmp input.csv roundtrip.csv
    done
    ;;
  joins)
    printf 'id,left\na,1\nb,2\n' > a.csv
    printf 'id,right\na,x\nb,y\n' > b.csv
    csvtk join -f id a.csv b.csv > joined.log; grep -Fx 'b,2,y' joined.log
    csvtk freq -f id a.csv > freq.log; grep -Fx 'a,1' freq.log
    csvtk pretty a.csv > pretty.log; grep -F 'left' pretty.log
    ;;
  xlsx)
    printf 'id,value\na,2\nb,3\n' > input.csv
    csvtk csv2xlsx input.csv -o table.xlsx
    csvtk xlsx2csv table.xlsx > roundtrip.csv; cmp input.csv roundtrip.csv
    printf 'id\tvalue\na\t2\nb\t3\n' | csvtk -t csv2xlsx - -o stdin.xlsx
    csvtk xlsx2csv stdin.xlsx > roundtrip.csv; cmp input.csv roundtrip.csv
    ;;
  reshape)
    printf 'row,col,value\na,x,1\na,y,2\nb,x,3\nb,y,4\n' > input.csv
    csvtk long2matrix input.csv > matrix.csv
    csvtk matrix2long -n row,col,value matrix.csv > result.log
    grep -Fx 'a,x,1' result.log; grep -Fx 'b,y,4' result.log
    printf 'left\n1\n2\n' > a.csv; printf 'right\nx\ny\n' > b.csv
    csvtk paste a.csv b.csv > paste.log; grep -Fx '2,y' paste.log
    printf 'key,a,b\nx,1,A\nx,2,B\n' > folded.csv
    csvtk fold -f key -v a,b folded.csv > fold.csv
    csvtk unfold -f a,b -s '; ' fold.csv > unfold.log
    grep -Fx 'x,1,A' unfold.log; grep -Fx 'x,2,B' unfold.log
    ;;
  changes)
    printf 'key,value\na,1\na,2\nb,3\n' > input.csv
    csvtk uniq -f key -d input.csv > repeated.log; grep -Fx 'a,1' repeated.log
    csvtk uniq -f key -u input.csv > unique.log; grep -Fx 'b,3' unique.log
    csvtk summary -g key -f value:sum -n total input.csv > summary.log
    grep -Fx 'key,total' summary.log
    csvtk --quote-all cut -f key input.csv > quote.log; grep -Fx '"key"' quote.log
    csvtk split -n 2 -o chunks input.csv
    test "$(find chunks -type f | wc -l)" -eq 2
    printf 'x,y\n1,2\n2,4\n3,6\n' > corr.csv
    csvtk corr -f x,y corr.csv > corr.log; test -s corr.log
    csvtk corr --pass -f x,y corr.csv > passthrough.csv 2> corr-pass.log
    cmp corr.csv passthrough.csv; test -s corr-pass.log
    printf 'word\n你好\na\nabc\n' > words.csv
    csvtk sort -k word:l words.csv > sorted.log
    printf 'word\na\n你好\nabc\n' > expected; cmp expected sorted.log
    ;;
  graphics)
    printf 'value\n1\n2\n3\n4\n5\n' > input.csv
    for ext in png pdf svg; do
        csvtk plot hist -f value --bins 3 input.csv -o "plot.$ext"
        test -s "plot.$ext"
    done
    test "$(od -An -tx1 -N8 plot.png | tr -d ' \n')" = 89504e470d0a1a0a
    head -c 5 plot.pdf > pdf.log; grep -F '%PDF-' pdf.log
    grep -F '<svg' plot.svg >/dev/null
    ;;
  html)
    printf 'sample,note\ns1,<script>alert(1)</script>\ns2,A&B\n' > input.csv
    csvtk csv2html --caption 'Sample table' input.csv -o report.html
    test -s report.html
    grep -F '<caption>Sample table</caption>' report.html
    grep -F '&lt;script&gt;alert(1)&lt;/script&gt;' report.html
    grep -F 'A&amp;B' report.html
    if grep -E '<script|<link|<iframe|<img|https?://' report.html; then exit 1; fi
    if csvtk csv2html --table-width invalid input.csv > invalid.log 2>&1; then exit 1; fi
    grep -F 'invalid table width' invalid.log
    if csvtk csv2html missing.csv > missing.log 2>&1; then exit 1; fi
    grep -F 'missing.csv' missing.log
    ;;
  *) printf 'unknown smoke mode: %s\n' "$mode" >&2; exit 2 ;;
esac
printf 'csvtk-smoke stage=%s PASS\n' "$mode"
