# Author: Ling-Han Jiang
# Date: 2022-01-28
# E-mail: jianglinghan@hotmail.com 
library(clusterProfiler)

ACC2GO <- "/public/home/aczhzv5pmn/LESSON/lesson8/ref/speciesx.ACC2GO"
genelist <- "gene.txt"

gene2go <- read.table(
            ACC2GO,
            stringsAsFactor=FALSE,
            sep="\t",
            quote="")

GO_DB <- read.table(
          "GO_list.tsv",
          stringsAsFactor=FALSE,
          sep="\t", 
          quote="", 
          comment="")
genelist <- read.table(genelist, sep="\t", header=F)$V1 
res <- enricher(
        gene=genelist,
        pvalueCutoff=0.05,
        TERM2GENE=gene2go[,c(2,1)], 
        TERM2NAME=GO_DB, 
        pAdjustMethod="BH")     
pdf("GO.pdf")
dotplot(res, showCategory=20)
dev.off()



