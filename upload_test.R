
source("R/upload_tools.R")

key<-Sys.getenv("key")

path="/NIH/CCBR/RSK/msigdbs/"


upload_file_name="/rstudio-files/ccbr-data/RSK/nidapuploads/R/pathworks.txt"
datasetname="pathworks4"

brid<-upload_project(upload_file_name,datasetname,path,key)

