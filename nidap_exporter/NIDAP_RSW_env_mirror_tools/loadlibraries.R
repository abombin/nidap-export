library(RCurl)
library(httr)
#Sys.setenv(RETICULATE_MINICONDA_PATH="/rstudio-files/ccbr-data/python/miniconda")
#Sys.unsetenv("RETICULATE_MINICONDA_PATH")
#conda env create --name migration  mamba 
library(reticulate)

#https://nidap.nih.gov/workspace/vector/view/ri.vector.main.workbook.716f8228-762f-4071-a1c0-81e47aa00682?branch=R3_Branch_Do_Not_Modify
##'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/resolvedEnvironment'
##'https://nidap.nih.gov/vector/api/workbooks/ri.vector.main.workbook.055d84fe-8d46-498b-af12-1c7b4105f8df/branches/master/environmentv2'
##'
url="https://nidap.nih.gov/vector/api/workbooks/"

rid="ri.vector.main.workbook.716f8228-762f-4071-a1c0-81e47aa00682"
branch="R3_Branch_Do_Not_Modify"
envname="myenv"



callresolved<-paste0(url  , rid,"/branches/",branch , '/resolvedEnvironment')
callenv<-paste0(url  , rid,"/branches/",branch , '/environmentv2')

key=Sys.getenv("token")

# print(callurl)
resres<-GET(url=callresolved,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,content_type_json())


con<-content(resres,"parsed")
cont<-content(resres,"text")
resrespkdf<-fromJSON(cont)$resolvedCondaEnvironment$packageSpecs

# print(callurl)
resenv<-GET(url=callenv,add_headers(Authorization = paste("Bearer", key, sep = " ")), verify=FALSE,content_type_json())


conce<-content(resenv,"parsed")
contce<-content(resenv,"text")




#rps<-  resrespkdf[grepl("^r-|^bioconductor-",resrespkdf$name),]


rpenv<-fromJSON(contce)$condaEnvironmentDefinition$packageMatchSpecs


mainpkgs<-sapply(strsplit(rpenv,"="), `[`, 1)
mainRpkgs1<-mainpkgs[grepl("^r-|^bioconductor-",mainpkgs)]
use_condaenv("migration")
mainRpkgs<-mainRpkgs1[! mainRpkgs1%in% c()]
#impute
#ggtree
#WGCNA
#xCell
#netBiov
#synergyFinder
#treeio


rps<-resrespkdf[resrespkdf$name%in%mainRpkgs,]



ymlout<-c("channels:","- conda-forge","- bioconda","dependencies:","",paste0("- ",rps$name,"=",rps$version),"- r-renv","- BioCmanager", paste0("name: ",envname))



write.table(ymlout, "environment.yml",quote = FALSE,row.names = FALSE,col.names = FALSE)


create_command=paste0("conda env create --name ",envname," --file environment.yml ")

mamba_log <- try(system(create_command, intern = TRUE))

use_condaenv(condaenv = NULL)

use_condaenv(condaenv = "myenv")

write.table(gsub("^r-|^bioconductor-","",mainRpkgs), "libraries_main.txt",quote = FALSE,row.names = FALSE,col.names = FALSE)



ip=rownames(installed.packages())







y <- read.table("libraries_main.txt",stringsAsFactors = FALSE)[[1]]


mls<-ip[match(y,tolower(ip))]

print("Non-installed/Non-matched libraries.")

print(y[is.na(mls)])

nnay<-mls[!is.na(mls)]

libs=paste0("library(",nnay,")")
projdir="project_test3"
dir.create(projdir)
setwd(projdir)
write.table(libs, "libraries_clean.R",quote = FALSE,row.names = FALSE,col.names = FALSE)
#install.packages("BiocManager")
library(BiocManager)
source("libraries_clean.R")
renv::init()

#

