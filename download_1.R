
source("download_tools.R")
key<-Sys.getenv("key")
rid="ri.foundry.main.dataset.472fd4b4-d26e-41d2-9c89-5d6d3c92c687"


raw_files=pullnidap_raw(key=key,rid=rid,branch="master")


rid="ri.foundry.main.dataset.bc0fbb12-ef31-4827-98a5-5a0a560d7ddc"


dataset=pullnidap_dataset(key=key,rid=rid,branch="master")

write.csv(dataset,file=paste0("prostate_",rid))

