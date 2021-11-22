setwd("[Your working directory]")

load("Allgx.dat.RData") #load mygenoMat
load("pheno.list.RData")

givenSNPall=colnames(mygenoMat)
SNP_i=1

length(pheno.list)
head(pheno.list[[1]])

sty.df=data.frame(y=numeric(), a=numeric(), x1=numeric(), x2=numeric(),g=numeric())
re.data=list()
re.data
#head(ex[[1]])
#  y          a         x1         x2 g
#s1 0  1.0035059 -0.8208076 -0.6567509 1
#s2 0 -0.9955098 -0.0115038  0.9123383 2
#s3 0  1.0035059 -0.5641701 -0.2544740 1
#s4 0  1.0035059 -0.4187774 -0.4676247 2
#s5 0  1.0035059 -1.3408103 -0.5686378 0
#s6 0  1.0035059  0.2745499 -0.8170118 0

c=1
for(SNP_i in seq(1:length(givenSNPall))){
  print(givenSNPall[SNP_i])
  print(c)
  c=c+1
  for(i in seq(1:length(pheno.list))){
    #print(i)
    id= row.names(pheno.list[[i]])
    geno= mygenoMat[id, givenSNPall[SNP_i]]
    re.data[[i]]=data.frame(y=pheno.list[[i]]$y, a=pheno.list[[i]]$SEX, x1=pheno.list[[i]]$AGE, x2=pheno.list[[i]]$BMI,g=geno)
    #re.data[[i]]$id=id
    rownames(re.data[[i]])=id
  }
  fileName=paste(paste("", givenSNPall[SNP_i], sep=""), "RData", sep=".")
  print(fileName)
  save(re.data, file=fileName)
}

#load("NewData2/exm57530_A.RData")
  