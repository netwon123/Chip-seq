# trim
# trim
java -jar /public/home/aczhzv5pmn/software/Trimmomatic-0.39/trimmomatic-0.39.jar PE\
     -threads 8\
     -summary /public/home/aczhzv5pmn/LESSON/lesson8/A1.trim.stats\
     -validatePairs\
     -baseout /public/home/aczhzv5pmn/LESSON/lesson8/A1.fq.gz\
     A1_R1.fq.gz A1_R2.fq.gz\
     ILLUMINACLIP:/public/home/aczhzv5pmn/software/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:8:true MINLEN:8  
# fastqc
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/fastqc/opt/fastqc-0.11.9/fastqc -t 10 A1_1P.fq.gz A1_2P.fq.gz
# mapping
/public/home/aczhzv5pmn/software/bowtie2/bowtie2-2.3.5/bowtie2 -p 8 -q -I 10 -X 1000 --dovetail --no-unal --very-sensitive-local --no-mixed --no-discordant -x ref/speciesx -1 A1_1P.fq.gz -2 A1_2P.fq.gz 2>A1.alignment.summary | /public/home/aczhzv5pmn/software/samtools/samtools-1.9/samtools view -F 4 -u - | /public/home/aczhzv5pmn/software/samtools/samtools-1.9/samtools sort -@ 6 -o A1.bam -  
# filt alignment
/public/home/aczhzv5pmn/software/samtools/samtools-1.9/samtools view -b -f 2 -q 30 -o A1.f2.q30.bam A1.bam
# preseq
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/preseq/bin/preseq lc_extrap -e 1e+8 -P -B -D -v -o A1.dat A1.f2.q30.bam 2>A1.log 
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/R/bin/Rscript preseq.R A1.dat A1.log A1
# picard
java -jar /public/home/aczhzv5pmn/software/picard/picard-2.25.6/picard.jar MarkDuplicates\
    PG=null \
    VERBOSITY=ERROR \
    QUIET=true \
    CREATE_INDEX=false \
    REMOVE_DUPLICATES=true \
    INPUT=A1.f2.q30.bam \
    OUTPUT=A1.f2.q30.dedup.bam \
    M=A1.pe.markduplicates.log 
# insertion size
java -jar /public/home/aczhzv5pmn/software/picard/picard-2.25.6/picard.jar CollectInsertSizeMetrics\
    I=A1.f2.q30.bam\
    O=cut_tag.insert_size.txt\
    H=cut_tag.insert_size_histogram.png\                                                                    
    M=0.5
# call peak
GSIZE=$(/public/home/aczhzv5pmn/software/bowtie2/bowtie2-2.3.5/bowtie2-inspect ref/speciesx  | perl -ne 'BEGIN{$n=0} next if(/^>/);s/[^ATGC]//gi; $n+=length($_); END{print int($n*0.85);}') # 计算基因组大小
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/macs/bin/macs3 callpeak\
    -t A1.f2.q30.dedup.bam\
    -f BAMPE\
    -n A1
    -g ${GSIZE}\
    -B\
    -SPMR\
    --keep-dup all
# annot
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/R/bin/Rscript PeakAnnotation.R ref/speciesx.gtf A1_peaks.narrowPeak A1
# tss enrichment
# 1. chrom size
/public/home/aczhzv5pmn/software/samtools/samtools-1.9/samtools view -H A1.f2.q30.dedup.bam|perl -ne 'if(/SN:(\S+)\s+LN:(\d+)/){print "$1\t$2\n"}' > A1.chromSize
# 2. bdg to bw
/public/home/aczhzv5pmn/software/UCSCTOOLS/bedSort A1_treat_pileup.bdg stdout|/public/home/aczhzv5pmn/software/UCSCTOOLS/bedClip -truncate stdin A1.chromSize stdout|perl -ane 'print if($F[1]<$F[2])' > tmp.bdg
/public/home/aczhzv5pmn/software/UCSCTOOLS/bedGraphToBigWig tmp.bdg A1.chromSize A1_treat_pileup.bw
# 3. matrix
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/deeptools/bin/computeMatrix reference-point --referencePoint TSS\
    -p 6\
    -a 3000\
    -b 3000\
    -R ref/speciesx.tss.bed\
    -S A1_treat_pileup.bw\
    -o A1_matrix_TSS.gz\
    --missingDataAsZero
# 4. plot
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/deeptools/bin/plotHeatmap \
    --heatmapHeight 16 \
    --heatmapWidth 4  \
    --colorMap Reds \
    --legendLocation none \
    --samplesLabel A1 \
    -m A1_matrix.gz 
    -o A1_enrichment.png
# annot
/public/home/aczhzv5pmn/software/Anaconda/anaconda3-3d/envs/R/bin/Rscript clusterprofiler.R
# motif
# 1. get fa
/public/home/aczhzv5pmn/software/bedtools/bedtools-2.30.0/bin/bedtools getfasta  -name -fi ref/speciesx.fa -bed A1_peaks.bed -fo A1_peaks.fa
/public/home/aczhzv5pmn/software/bedtools/bedtools-2.30.0/bin/bedtools getfasta  -name -fi ref/speciesx.fa -bed C1_peaks.bed -fo C1_peaks.fa
# 2. motif
/public/home/aczhzv5pmn/software/meme/meme/bin/ame \
    -o ./ \
    # 所有 sample 的 peak fa 文件合成
    -control merge_peak.fa\
    A1_peaks.fa\
    JASPAR2018_CORE_insects_non-redundant.meme
    
     


~          


