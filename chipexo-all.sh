#!/bin/bash
# Stop on error.
set -e
# Directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/chipexo.sh CJ-1_WT-spt16-rep1 sacCer3 4
$DIR/chipexo.sh CJ-2_WT-Rbp3-rep1 sacCer3 4
$DIR/chipexo.sh CJ-3_WT-Pob3-rep1 sacCer3 4
$DIR/chipexo.sh CJ-5_WT-spt16-rep2 sacCer3 4
$DIR/chipexo.sh CJ-6_WT-Rbp3-rep2 sacCer3 4
$DIR/chipexo.sh CJ-7_WT-Pob3-rep2 sacCer3 4
$DIR/chipexo.sh CJ-8_WT-IgG-rep2 sacCer3 4
$DIR/chipexo.sh CJ-9_chd1D-spt16-rep1 sacCer3 4
$DIR/chipexo.sh CJ-10_chd1D-Rbp3-rep1 sacCer3 4
$DIR/chipexo.sh CJ-11_chd1D-Pob3-rep1 sacCer3 4
$DIR/chipexo.sh CJ-12_chd1D-IgG-rep1 sacCer3 4
$DIR/chipexo.sh CJ-13_chd1D-spt16-rep2 sacCer3 4
$DIR/chipexo.sh CJ-14_chd1D-Rbp3-rep2 sacCer3 4
$DIR/chipexo.sh CJ-15_chd1D-Pob3-rep2 sacCer3 4

$DIR/chipexo-merge.sh CJ-1_WT-spt16-rep1 CJ-5_WT-spt16-rep2 CJ-WT-spt16 sacCer3
$DIR/chipexo-merge.sh CJ-2_WT-Rbp3-rep1 CJ-6_WT-Rbp3-rep2 CJ-WT-Rbp3 sacCer3
$DIR/chipexo-merge.sh CJ-3_WT-Pob3-rep1 CJ-7_WT-Pob3-rep2 CJ-WT-Pob3 sacCer3
$DIR/chipexo-merge.sh CJ-9_chd1D-spt16-rep1 CJ-13_chd1D-spt16-rep2 CJ-chd1D-spt16 sacCer3
$DIR/chipexo-merge.sh CJ-10_chd1D-Rbp3-rep1 CJ-14_chd1D-Rbp3-rep2 CJ-chd1D-Rbp3 sacCer3
$DIR/chipexo-merge.sh CJ-11_chd1D-Pob3-rep1 CJ-15_chd1D-Pob3-rep2 CJ-chd1D-Pob3 sacCer3
