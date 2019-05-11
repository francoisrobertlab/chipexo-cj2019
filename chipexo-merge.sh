#!/bin/bash
# Stop on error.
set -e
# Directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Variables.
BED_MOVED_R1=$1-moved.bed
BED_MOVED_R2=$2-moved.bed
BED_MERGED=$3-merged.bed
BED=$3.bed
BIGWIG=$3.bw
BED_TEMP=$3-temp.bed
BASE_SCALE=1000000
CHROMOSOMES_SIZES=$DIR/$4.chrom.sizes
JAR=$PWD/bed-tools-j-2.1.jar
# Analyse.
echo "Combining replicates $1 and $2 into $3"
echo "Counting reads in replicate $1"
READS_R1=`wc -l < $BED_MOVED_R1`
echo "Counting reads in replicate $2"
READS_R2=`wc -l < $BED_MOVED_R2`
SCALE=`echo "scale=10;$BASE_SCALE/($READS_R1+$READS_R2)" | bc`
echo "Combined scale = $SCALE"
echo "Genome coverage of combined replicates $3"
cat $BED_MOVED_R1 $BED_MOVED_R2 > $BED_TEMP
sort -k 1,1 $BED_TEMP > $BED_MERGED
bedtools genomecov -bg -5 -scale $SCALE -i $BED_MERGED -g $CHROMOSOMES_SIZES | bedtools sort > $BED_TEMP
echo "track type=bedGraph name=\"$3\"" | cat - $BED_TEMP > $BED
bedGraphToBigWig $BED $CHROMOSOMES_SIZES $BIGWIG
rm $BED_TEMP
