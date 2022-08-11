source("../download_tools.R")
key<-Sys.getenv("key")
rds_output<-"./Unit_test_pipeline/rds_output"
if (file.exists(rds_output)!=1) {
dir.create(rds_output,showWarnings = FALSE)}
rid="ri.foundry.main.dataset.d6d40105-1dd4-417f-9066-6896b55fb3d2"
branch="master"
var_Dataset_1files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Dataset_1<-figure_out_nidap_files(var_Dataset_1files)
saveRDS(var_Dataset_1,"./Unit_test_pipeline/rds_output/var_Dataset_1.rds")
rid="ri.foundry.main.dataset.078693cc-2e38-4c1a-b4b5-8bc59ed9e10d"
branch="master"
var_Dataset_2files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Dataset_2<-figure_out_nidap_files(var_Dataset_2files)
saveRDS(var_Dataset_2,"./Unit_test_pipeline/rds_output/var_Dataset_2.rds")
