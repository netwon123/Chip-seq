ls *narrowPeak|while  read id;
do
echo $id
bed=$(basename $id "_peaks.narrowPeak").rmdup.rmM.bed
#ls -lh $bed
Reads=$(bedtools intersect -a $bed -b $id |wc -l|awk '{print $1}')
totalReads=$(wc -l $bed|awk '{print $1}')
echo $Reads  $totalReads
echo '==> FRiP value:' $(bc <<< "scale=2;100*$Reads/$totalReads")'%'
done
