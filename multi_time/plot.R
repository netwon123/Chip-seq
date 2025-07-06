setwd('F:/project_lwj')
library(DESeq2)
library(ggplot2)
dds <- readRDS("dds_LRT.rds")
sig=read.csv('diff_peaks_LRT.csv',header=T)
peak_id <- "1:11209-11609"


# 提取 normalized count 数据
df <- plotCounts(dds, gene = peak_id, intgroup = "time", returnData = TRUE)

# 如果 time 是因子，转为数字方便画线
df$time <- as.numeric(as.character(df$time))

# 平滑绘图
ggplot(df, aes(x = time, y = count)) +
  geom_point(size = 2) +
  geom_line(aes(group = 1), color = "steelblue", linetype = "dashed") +
  geom_smooth(method = "loess", se = TRUE, color = "firebrick", fill = "pink", lwd = 1) +
  labs(title = paste("Time course of peak", peak_id),
       x = "Time point", y = "Normalized ChIP count") +
  theme_minimal(base_size = 14)
