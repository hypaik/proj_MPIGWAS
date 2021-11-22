#set wd

MyworkDir="[YourWorking directory]"
setwd(MyworkDir)
mytped='[PLINKfileName].tped' #row= snp, col=2column in 1 person
mytfam='[PLINKfileName].tfam' #row= famID, IID
tmp <- file(mytped, 'r', blocking=F)
s.names <- as.character(read.table(mytfam)[, 2])

tmp.dat<-read.table(tmp, sep=" ", header=FALSE)

#read test.tped
#tmp.dat=tmp.dat[1:10,] #row=SNPs, col=individual
#tpedColCount=length(unlist(strsplit(tmp.dat[1], ' ')))
#tmp.pedMat_geno=matrix(lapply(tmp.dat, function(x){as.numeric(unlist(strsplit(tmp.dat, " "))[5:tpedColCount])}), ncol = tpedColCount-4, byrow = TRUE)

ncol(tmp.dat)-5
(ncol(tmp.dat)-4)/2
(ncol(tmp.dat)-4)/2==length(s.names)

tmp.pedMat_geno=sapply(tmp.dat[,5:ncol(tmp.dat)], as.numeric)


tmp.pedLoci=as.vector(as.character((tmp.dat[,2])))

mygenoMat=matrix(apply(tmp.pedMat_geno, 1, function(x){x1 <- x[seq(1, length(x), 2)]
x2 <- x[seq(2, length(x), 2)] 
return(x1+x2-2)}), ncol=ncol(tmp.pedMat_geno)/2, byrow=TRUE)

colnames(mygenoMat)=s.names
rownames(mygenoMat)= tmp.pedLoci
mygenoMat_t=t(mygenoMat)
save(mygenoMat, file='Allgx.dat.RData')
save(mygenoMat_t, file='TransAllgx.dat.RData') #optional file out put

#mygenoMat['exm57530','NIH17G2000162'] for Test print

#rownames(tmp.pedMat_geno)=tmp.pedLoci
#colnames(tmp.pedMat_geno)=make.unique(rep(s.names,each=2))
#tmp.pedMat_geno[1:5, 1:10]
#tmp.pedMat_geno['exm57530',c('NIH17G2000162','NIH17G2000162.1')]

