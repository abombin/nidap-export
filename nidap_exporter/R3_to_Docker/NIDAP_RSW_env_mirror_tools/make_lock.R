ip=installed.packages(fields=c("Package","Version","Repository"))[,c("Package","Version","Repository")]

ip2=cbind(ip[,c("Package","Version")],"Repository"=ifelse(is.na(ip[,"Repository"]),"Bioconductor","CRAN"))
#ip2=ip
#ip2[!(!is.na(ip[,"Repository"])& ip2[,"Repository"]=="CRAN"), "Version" ]<-NA
#ip2[!(!is.na(ip[,"Repository"])& ip2[,"Repository"]=="CRAN"), "Repository" ]<-"Bioconductor"

re=''
p=ip2[1,]
prefix=""
for(pi in 1:length(ip2[,1])){
  p=ip2[pi,]
  pe=sprintf('%s
    "%s": {
      "Package": "%s",
      "Version": "%s",
      "Source": "Repository",
      "Repository": "%s"
    }',prefix, p["Package"], p["Package"],p["Version"], p["Repository"])
  re=paste0(re,pe)
  prefix=','
}
#re

rea=sprintf('{
  "R": {
    "Version": "%s",
    "Repositories": [
      {
        "Name": "CRAN",
        "URL": "https://ftp.osuosl.org/pub/cran"
      }
    ]
  },
  "Bioconductor": {
    "Version": "%s"
  },
  "Packages": {
    %s
  }
}
',paste0(R.version$major,".",R.version$minor),
tools:::.BioC_version_associated_with_R_version(),re)

#rea

writeLines(rea, "myrenv.lock")  

#get packages

pksp=installed.packages(fields=c())[,c(1,2)]

pksp2=paste0(pksp[,2],"/",pksp[,1],"/DESCRIPTION")

a=readLines(pksp2[3])


system("grep ^git_ /opt/conda/lib/R/library/*/DESCRIPTION", intern = TRUE, ignore.stderr = TRUE)


#renv::restore(exclude = c("affy","affyio","annotate","AnnotationFilter","AnnotationForge","apeglm","aroma.light","beachmat","BiocNeighbors","BiocParallel"),confirm=FALSE,clean=TRUE)
