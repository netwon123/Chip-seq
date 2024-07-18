# Author: Ling-Han Jiang
# Date: 2022-01-28
# E-mail: jianglinghan@hotmail.com

args <- commandArgs(trailingOnly=TRUE)

if(length(args)!=3){
  stop("\n need 3 arguments: gene.gff, peak.narrowPeak, sample_name\n")
}

suppressPackageStartupMessages(library(ChIPseeker))
suppressPackageStartupMessages(library(GenomicFeatures))

gff <- args[1]
peakFile <- args[2]
name <- args[3]

tx <- makeTxDbFromGFF(file=gff)

peak <- readPeakFile(peakfile=peakFile,header=FALSE,as="GRanges")
d <- mcols(peak)
if(ncol(d)==1){
	colnames(d)="peakName"
}else if (ncol(d)==7){
	colnames(d)=c("peakName","colorScore","strand","fold_enrichment","-log10(pvalue)","-log10(qvalue)","relative_summit_position")
	d=d[,-3]
}

mcols(peak) <- d

peakAnno <- annotatePeak(peak=peak, tssRegion = c(-3000, 0), TxDb=tx,assignGenomicAnnotation=TRUE)

pdf(file=paste0(name,".peakAnnotation.pdf"))
a <- dev.cur()
png(file=paste0(name,".peakAnnotation.png"),width=1200, height=1200, res=150)
dev.control("enable")

tmp <- unlist(strsplit(name, "/|\\."))
title <- tmp[length(tmp)]
plotAnnoPie(peakAnno, main=paste0(title,"\nDistribution of Features"),line=-8)
dev.copy(which=a)
dev.off()
dev.off()

peakAnno.result <- as.data.frame(peakAnno@anno)
write.table(peakAnno.result,
            file=paste0(name, ".peakAnno.tsv"),
            sep="\t",
            row.names=FALSE)



