library(DiffBind)
library(DESeq2)


samples <- read.csv('sample.list.txt', sep='\t')


dbObj <- dba(sampleSheet = samples)


dbObj <- dba.count(dbObj, bUseSummarizeOverlaps=TRUE)


counts <- dbObj$binding[, -(1:3)]
rownames(counts) <- paste0(
  dbObj$binding[, "CHR"], ":",
  dbObj$binding[, "START"], "-",
  dbObj$binding[, "END"]
)

colData <- samples
rownames(colData) <- colData$SampleID
colData$time <- factor(colData$time)


dds <- DESeqDataSetFromMatrix(countData = round(counts),
                              colData = colData,
                              design = ~ time)

saveRDS(dds, file = "dds_LRT.rds")
dds <- DESeq(dds, test="LRT", reduced = ~1)


res <- results(dds)


sig <- res[which(res$padj < 0.05), ]


write.csv(as.data.frame(sig), file="diff_peaks_LRT.csv")
~
~
