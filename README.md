# proj_MPIGWAS
Supercomputing aided permutation approach for genome-wide association study

Hyojung Paik1,2,¶, Yongseong Cho1,¶, and Oh-Kyung. Kwon1,&

1 Division of Supercomputing, Center for supercomputing application and research, Korea Institute of Science and Technology Information (KISTI), Daejeon 34141, South Korea
2 Department of Data and HPC science, University of Science and Technology (UST), Daejeon, 34141, South Korea

¶ These authors are equally contributed for this work. 
& Correspondence should be addressed to okkwan@kisti.re.kr

Authors of souce code: Yongseong Cho (frodoys@gmail.com), Hyojung Paik (hyojungpaik@gmail.com)

Abstract of project MPI-GWAS.
Although permutation testing is a robust and popular approach for significance testing in genomic research, which has the advantage against inflated type I error rates, the computational efficiency is notorious in genome-wide association studies (GWAS). As an alternative way, researchers have been utilized an adaptive permutation strategy to make permutation approaches feasible. Here, we developed a supercomputing-aided approach to accelerate the permutation testing for GWAS based on the message passing interface (MPI) on parallel computing architecture. 
Our application, called MPI-GWAS, consists of input data generation from the PLINK, a whole genome association analysis toolset, and MPI based permutation testing under parallel computing approach using the supercomputing system, Nurion (8,305 compute nodes, 797.3TB of memory, 563,740 of CPU cores). We examined the real data set of GWAS results for hypertension and type 2 diabetes in the Korean Genome and Epidemiology Study (KoGES) and UK biobank (UKBB) covering 8,000 and 49,960 individuals respectively. MPI-GWAS elapsed about 600 seconds using 2,720 CPU cores for 107 permutations of 1 SNP, which is up to 7.2 times faster than 272 cores. A total expected computing time for 30,000 SNPs with 171,360 CPU cores is about 4 days. 
MPI-GWAS enables us to feasibly compute the permutation based GWAS within reasonable period to harness the power of supercomputing resources. 
