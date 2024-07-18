# Author: Ling-Han Jiang
# Date: 2021-12-14
# E-mail: jianglinghan@hotmail.com

library(DiffBind)
args <- commandArgs(TRUE)                                                                                   
samplelist <- "diffbind_samplelist"
out_dir <- "./"
fold <- 0.58
samples <- read.csv(samplelist, sep="\t")
obj <- dba(sampleSheet=samples)
count <- dba.count(obj, summits=250)
norm <- dba.normalize(count, method=DBA_DESEQ2, library=DBA_LIBSIZE_FULL, normalize=DBA_NORM_LIB)
contrast <- dba.contrast(norm, contrast=c("Condition", "A", "C"))
analyze <- dba.analyze(contrast, method=DBA_DESEQ2)
res <- dba.report(analyze, method=DBA_DESEQ2, contrast = 1, th=1)
# table
gain <- res[(res$FDR < 0.05) & (res$Fold > fold) ,]
loss <- res[(res$FDR < 0.05) & (res$Fold < -fold) ,]
gain_out <- as.data.frame(gain)
loss_out <- as.data.frame(loss)
f_gain <- sprintf("%s/diffbind_gain.txt", out_dir)
f_loss <- sprintf("%s/diffbind_loss.txt", out_dir)
write.table(gain_out, file=f_gain, sep="\t", quote=FALSE, col.names=NA)
write.table(loss_out, file=f_loss, sep="\t", quote=FALSE, col.names=NA)
# figure
pdf("heat.pdf")
dba.plotHeatmap(norm)
dev.off()

