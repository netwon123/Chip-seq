
# process preseq output file to obtain NRF, PCB1 PCB2
cmd=commandArgs(trailingOnly=TRUE)
if(length(cmd)!=3)
stop("need preseq data file, Log file and output name for figure\n")

DAT=cmd[1]
LOG=cmd[2]
name=cmd[3]

if(!file.exists(DAT))
stop(paste("file not found: "),DAT)

if(!file.exists(LOG))
stop(paste("file not found: "),LOG)

library(ggplot2)

d=read.table(DAT,header=TRUE)
d=d/1000000

log1=read.table(pipe(paste0("grep -A 1 'TOTAL READS' ", LOG)),sep="=")
log2=read.table(pipe(paste0("grep -A 2 'OBSERVED COUNTS' ", LOG)),skip=1)

totalRead=log1[1,2]
distinctRead=log1[2,2]
onePairRead=log2[1,2]
twoPairRead=log2[2,2]

NRF=format(distinctRead/totalRead,digits=3)
PCB1=format(onePairRead/distinctRead,digits=3)
PCB2=format(onePairRead/twoPairRead,digits=3)

res=paste0("NRF=",NRF,"\n","PCB1=",PCB1,"\n","PCB2=",PCB2,"\n")
write(res,file="preseq.res.txt")

#NRF=log1[2,2]/log1[1,2]
#PCB1=log2[1,2]/log1[2,2]
#PCB2=log2[1,2]/log2[2,2]

p=ggplot(data=d,aes(x=TOTAL_READS,y=EXPECTED_DISTINCT))+geom_line()+geom_ribbon(aes(ymin=LOWER_0.95CI,ymax=UPPER_0.95CI),alpha=0.3)+ylab("Expected Distinct Reads (in million)")+xlab("Total Reads Sequenced in Theory (in million)")+theme_minimal()+geom_vline(xintercept = totalRead/1000000,colour="red",linetype="dashed")+theme(axis.text=element_text(size=14))
q=p+annotate(geom="text",x=0.8*max(d$TOTAL_READS),y=0.1*max(d$EXPECTED_DISTINCT),label=paste0("NRF=",NRF,"\nPCB1=",PCB1,"\nPCB2=",PCB2,digits=3))

#FIG2=sub(pattern=".png$",replacement=".pdf",x=FIG)
pdf(file=paste0(name,".preseq.pdf"))
print(q)
dev.off()

png(file=paste0(name,".preseq.png"),width=1200, height=1200, res=150)
print(q)
dev.off()
