#set wd

MyworkDir="[Your working directory]"
setwd(MyworkDir)
raw="exome1.sub7523.raw" # example name of your PLINK raw data file
mydataRaw=read.table(raw, header=T)


mygenoMat=sapply(mydataRaw[,7:ncol(mydataRaw)], as.numeric)

#tmp.dat[tmp.dat$V2=='exm57530',]

tmp.pedLoci=as.vector(as.character(colnames(mydataRaw)[7:ncol(mydataRaw)]))


colnames(mygenoMat)=tmp.pedLoci
rownames(mygenoMat)= mydataRaw$IID

save(mygenoMat, file='Allgx.dat.RData')
