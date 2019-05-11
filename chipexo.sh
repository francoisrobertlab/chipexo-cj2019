#!/bin/bash
# Stop on error.
set -e
# Directory of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Variables.
FASTQ_1=$1_R1.fastq.gz
FASTQ_2=$1_R2.fastq.gz
BAM=$1.bam
BAM_RAW=$1-raw.bam
BAM_MATE1=$1-mate1.bam
BAM_FILTERED=$1-filtered.bam
BAM_DEDUP=$1-dedup.bam
BAM_TEMP=$1-temp.bam
BED=$1.bed
BIGWIG=$1.bw
BED_MOVED=$1-moved.bed
BED_MATE1=$1-mate1.bed
BED_PLUS=$1-plus.bed
BIGWIG_PLUS=$1-plus.bw
BED_MINUS=$1-minus.bed
BIGWIG_MINUS=$1-minus.bw
BED_TEMP=$1-temp.bed
BASE_SCALE=1000000
FASTA=$DIR/$2.fa
CHROMOSOMES_SIZES=$DIR/$2.chrom.sizes
THREADS=1
if test "$3" != ""
then
THREADS=$3
fi
JAR=$PWD/bed-tools-j-2.1.jar
# Analysis.
echo "Running analysis pipeline for $1"
fastqc $FASTQ_1
if test -f $FASTQ_2
then
fastqc $FASTQ_2
fi
echo "Running BWA with $THREADS threads"
bwa index $FASTA
if test -f $FASTQ_2
then
echo "bwa mem -t $THREADS $FASTA $FASTQ_1 $FASTQ_2 | samtools view -b > $BAM_RAW"
bwa mem -t $THREADS $FASTA $FASTQ_1 $FASTQ_2 | samtools view -b > $BAM_RAW
else
bwa mem -t $THREADS $FASTA $FASTQ_1 | samtools view -b > $BAM_RAW
fi
cp $BAM_RAW $BAM
if test -f $FASTQ_2
then
echo "Removing reads not mapped in proper pair and supplementary alignments"
samtools view -f 2 -F 2048 $BAM -b > $BAM_FILTERED
else
echo "Removing unmapped and supplementary alignments"
samtools view -F 2048 -F 4 $BAM -b > $BAM_FILTERED
fi
cp $BAM_FILTERED $BAM
if test -f $FASTQ_2
then
echo "Removing duplicated reads"
samtools fixmate -m $BAM - | samtools sort - | samtools markdup -r - $BAM_DEDUP
cp $BAM_DEDUP $BAM
fi
echo "Sorting BAM"
cp $BAM $BAM_TEMP
samtools sort $BAM_TEMP > $BAM
rm $BAM_TEMP
samtools index $BAM
fastqc $BAM
cp $BAM $BAM_MATE1
if test -f $FASTQ_2
then
echo "Removing mate 2 from BAM"
samtools view -f 64 -b $BAM > $BAM_MATE1
fi
echo "Convert BAM to BED"
bedtools bamtobed -i $BAM_MATE1 > $BED_MATE1
echo "Move annotations 6 bases towards 3'"
java -jar $JAR moveannotations -d 6 -r -dn -i $BED_MATE1 -o $BED_MOVED
echo "Counting positive strand reads"
PLUS_READS=`samtools view -f 16 $BAM_MATE1 | wc -l`
PLUS_SCALE=`echo "scale=10;$BASE_SCALE/$PLUS_READS" | bc`
echo "Positive strand scale = $PLUS_SCALE"
echo "Genome coverage of positive strand"
bedtools genomecov -bg -5 -strand + -scale $PLUS_SCALE -i $BED_MOVED -g $CHROMOSOMES_SIZES | bedtools sort > $BED_TEMP
echo "track type=bedGraph name=\"$1 Plus\"" | cat - $BED_TEMP > $BED_PLUS
bedGraphToBigWig $BED_PLUS $CHROMOSOMES_SIZES $BIGWIG_PLUS
rm $BED_TEMP
echo "Counting negative strand reads"
MINUS_READS=`samtools view -F 16 $BAM_MATE1 | wc -l`
MINUS_SCALE=`echo "scale=10;$BASE_SCALE/$MINUS_READS" | bc`
echo "Negative strand scale = $MINUS_SCALE"
echo "Genome coverage of negative strand"
bedtools genomecov -bg -5 -strand - -scale $MINUS_SCALE -i $BED_MOVED -g $CHROMOSOMES_SIZES | bedtools sort > $BED_TEMP
echo "track type=bedGraph name=\"$1 Minus\"" | cat - $BED_TEMP > $BED_MINUS
bedGraphToBigWig $BED_MINUS $CHROMOSOMES_SIZES $BIGWIG_MINUS
rm $BED_TEMP
SCALE=`echo "scale=10;$BASE_SCALE/($PLUS_READS+$MINUS_READS)" | bc`
echo "Combined scale = $SCALE"
echo "Genome coverage of combined strands"
bedtools genomecov -bg -5 -scale $SCALE -i $BED_MOVED -g $CHROMOSOMES_SIZES | bedtools sort > $BED_TEMP
echo "track type=bedGraph name=\"$1\"" | cat - $BED_TEMP > $BED
bedGraphToBigWig $BED $CHROMOSOMES_SIZES $BIGWIG
rm $BED_TEMP
