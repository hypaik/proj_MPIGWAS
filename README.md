# Abstract of proj MPI-GWAS
Supercomputing aided permutation approach for genome-wide association study

Hyojung Paik1,2,¶, Yongseong Cho1,¶, and Oh-Kyung. Kwon1,&

1 Division of Supercomputing, Center for supercomputing application and research, Korea Institute of Science and Technology Information (KISTI), Daejeon 34141, South Korea
2 Department of Data and HPC science, University of Science and Technology (UST), Daejeon, 34141, South Korea

¶ These authors are equally contributed for this work. 

& Correspondence should be addressed to okkwan@kisti.re.kr

Authors of souce code: Yongseong Cho (frodoys@gmail.com), Hyojung Paik (hyojungpaik@gmail.com)

Although permutation testing is a robust and popular approach for significance testing in genomic research, which has the advantage against inflated type I error rates, the computational efficiency is notorious in genome-wide association studies (GWAS). As an alternative way, researchers have been utilized an adaptive permutation strategy to make permutation approaches feasible. Here, we developed a supercomputing-aided approach to accelerate the permutation testing for GWAS based on the message passing interface (MPI) on parallel computing architecture. 

Our application, called MPI-GWAS, consists of input data generation from the PLINK, a whole genome association analysis toolset, and MPI based permutation testing under parallel computing approach using the supercomputing system, Nurion (8,305 compute nodes, 797.3TB of memory, 563,740 of CPU cores). We examined the real data set of GWAS results for hypertension and type 2 diabetes in the Korean Genome and Epidemiology Study (KoGES) and UK biobank (UKBB) covering 8,000 and 49,960 individuals respectively. MPI-GWAS elapsed about 600 seconds using 2,720 CPU cores for 107 permutations of 1 SNP, which is up to 7.2 times faster than 272 cores. A total expected computing time for 30,000 SNPs with 171,360 CPU cores is about 4 days. 

MPI-GWAS enables us to feasibly compute the permutation based GWAS within reasonable period to harness the power of supercomputing resources. 

**#<Usage of code>**
1. Data preparation
   - If your input files are from PLINK: *.tped, *.tfam
    Open_DataSetMakeFromPLINK.R (you will need to change the file name inside of the code)
     MyworkDir: working directory
     mytped: .tped file name
     mytfam: .tfam file name
   - If your input file is  *.raw
    Open_DataSetMakeFromPLINK_recodeAraw.R (you will need to change the file name inside of the code)
     raw: .raw file name
   - results of data preprocessing code -->  Allgx.dat.RData will generated
2. Data preparation
   - Open_DataSetMake_forRData_fromPLINKreshape.R --> re-shaping & splitting RData by each locus
     --> You will need to set the job directory inside of the code: setwd(“Your_working_directory”)
   - Open_DataSetMake_forRData_fromPLINKreshape.R--> will generate *.RData per each locus

3. Running usage of MPI_GWAS
mpirun -np [number of process] julia --depwarn=no --project mpi_gwas.jl -d data -n 10 -p 10000000 -o exp1

Execution Options 

-d: Directory where .RData files are located 

-p: Number of random permutations -n: Number of .RData files to process parallely 

-o: Specify the beginning part of the result file (.csv), saved as exp1_date_time.csv The variables ncores and opt_nnodes in mpi_gwas.jl file may need to be adjusted according to the system you are running on. \\

ncores refers to the number of processes(cores) per compute node, while opt_nnodes refers to the optimal number of nodes considering execution speed and the number of nodes used.


