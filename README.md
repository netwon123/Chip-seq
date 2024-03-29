# Chip-seq
#@ using macs3
## ATAC-seq和ChIP-seq有啥区别？  
```
> ChIP-Seq是实验前明确有一个感兴趣的转录因子，根据目标转录因子设计抗体去做ChIP实验拉DNA，验证感兴趣的转录因子是否与DNA存在相互作用
> 而ATAC-Seq没有落脚到具体哪个转录因子，是在全基因组范围内检测染色质的开放程度，可以得到全基因组范围内的蛋白质可能结合的位点信息，用这个技术方法与其他方法结合是想去筛感兴趣的调控因子
> ATAC-seq可以帮助识别启动子区域、潜在的增强子或沉默子，也就是说，ATAC-seq中的peak，往往是启动子、增强子序列，以及一些反式调控因子结合的位点
```
![image](https://github.com/netwon123/Chip-seq/blob/main/img/chip.jpg)
图1 Chip-seq原理图

和MACS模型构建相关的参数。正如MACS的名字所示, Model-based Analysis of ChIP-seq, 它需要先建立模型然后分析。那么问题来了，建立什么模型？模型的目的是什么？这里的模型指的是双峰模型，建立双模模型的目的是为了更好的将原始reads朝3'偏移，更好的表示蛋白和DNA的作用位置。这里还要多问一句为什么要偏倚。
这就需要从实验建库说起。ChIP-seq目标是找到蛋白和DNA的作用位置，所以先要让蛋白和DNA进行交联，之后用超声打碎，再用抗体把与蛋白结合的DNA收集起来测序。在MACS发表的2008年，那个时候的测序大多都以单端50bp为主，而超声破碎的片段肯定大于50 bp（这可以通过电泳图来了解），也就是说最开始的SE50数据比对到参考基因组之后，得到的峰图并没有真实反映出原来的文库情况。但由于比对到基因组正负链的概率是相似的，那么就会形成两个峰（如下图），为了更好的还原出最来的文库片段，就先建立了双峰模型，以两峰距离d的一半作为偏倚长度。
如果你的数据是SE50或者SE100，为了更准确地找peak，你需要建立双峰模型，你可能要调整--bw, --mfold, --fix-bimodal, --shift, --extsize。 但是对于双端测序而言，它本身测的就是文库的两端，因此建立模型没有必要，偏倚也没有必要，你 只需要 设置参数--nomodel.
设置了--nomodel，关联参数--extsize和--shift。

--extsize： MACS使用这个参数将read以5'-> 3'衍生至等长片段。比如说你知道你的转录因子的结合区域是200bp，那么参数就是--extsize 200。当且仅当--nomodel和--fix-bimodal设置使用。
--shift: 这个参数是绝对的偏移值，会先于--extsize前对read进行整体移动。MACS会通过建模的方式自动计算出read需要偏移的距离，除非你对自己的数据非常了解，或者前期研究都表明结合中心在read后面的那个位置上，你才能比较放心的用这个这个参数了。正数表示从5'往3'偏移延长到片段中心，如果是负数则是3'往5'偏移延长到片段中心。作者给了几个例子：  

```
>如果是ChIP-seq数据，设置·--shift 0

>如果是DNase-Seq数据：read来自于两个核小体中间，你想把测序read往两边延长用来平滑pileup信号，并且希望用来平滑的窗口是200bp,那么使用--nomodel --shift -100 --extsize 200

>如果是nucleosome-seq数据：因为一个核小体大概有147bp DNA缠绕，于是就需要用半个核小体长度进行堆积(pipleup)用于小波分析。参数为--nomodel --shift 37 --extsize 73

#DNase-Seq是用MNase或DNase I内切酶识别开放染色质区域，把切割完的DNA测序，和已知的全基因组序列进行比对，就知道被切掉了哪里，哪里没有被切掉，从而检测出开放的染色质区域。但是实验费时费力，重复性差
```

https://zhuanlan.zhihu.com/p/512163334#:~:text=%E8%80%8CATAC-seq%E5%BB%BA%E6%A8%A1%E7%9A%84%E6%97%B6%E5%80%99%E4%B9%9F%E9%9C%80%E8%A6%81shift%EF%BC%8C%E4%BD%BF%E4%B8%A4%E4%B8%AA%E2%80%9C%E7%9B%B8%E9%82%BB%E2%80%9D%E7%9A%84%E5%B3%B0shift%E6%88%90%E4%B8%80%E4%B8%AA%E5%B3%B0%EF%BC%8C%E4%BD%86%E6%98%AF%E8%A6%81%E5%BE%80%E4%B8%A4%E8%BE%B9shift.%20%E4%BB%A5%E4%B8%8B%E5%9B%BECTCF%E4%B8%BA%E4%BE%8B%EF%BC%8CChIP-seq%E7%9A%84%E5%B3%B0%E5%B0%B1%E6%98%AFCTCF%E7%9A%84%E7%BB%93%E5%90%88%E5%8C%BA%E5%9F%9F%EF%BC%8C%E4%B8%AD%E9%83%A8%E4%BD%8D%E7%BD%AE%E4%B8%BACTCF%E7%9A%84motif%EF%BC%8C%20%E8%80%8C,ATAC-seq%E7%9A%84reads%E5%AF%8C%E9%9B%86%E5%9C%A8motif%E4%B8%A4%E7%AB%AF%EF%BC%8C%E6%A8%AA%E5%90%91%E4%BB%A3%E8%A1%A8%E5%9F%BA%E5%9B%A0%E7%BB%84%E5%9D%90%E6%A0%87%2C%20%E7%BA%B5%E5%90%91%E4%BB%A3%E8%A1%A8ATAC-seq%E7%9A%84%E4%BF%A1%E5%8F%B7%E5%BC%BA%E5%BA%A6%20%E3%80%82
https://blog.csdn.net/weixin_43569478/article/details/108079774
https://www.jianshu.com/p/6a975f0ea65a
https://blog.csdn.net/weixin_43569478/article/details/108079812
https://www.jianshu.com/p/96688fecd864
