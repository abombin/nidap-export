source("../download_tools.R")
key<-Sys.getenv("key")
report<-list()
currentdir <- getwd()
rds_output <- paste0(currentdir,"/rds_output")
rid="ri.foundry.main.dataset.5e2cd52f-99ee-49e8-9ab6-804da37ae47c"
report["var_Process_1"]<-'no comparison'
try({
branch="master"
var_Process_1files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_1_target<-figure_out_nidap_files(var_Process_1files)
var_Process_1_new<-readRDS(paste0(rds_output,"/var_Process_1.rds"))
report["var_Process_1"]<-report_differences(var_Process_1_target,var_Process_1_new)
},silent=TRUE)
print(report["var_Process_1"])
###################################
rid="ri.foundry.main.dataset.2febf5cd-3958-4a74-ba01-a44f988ff0f2"
report["var_Process_1_1"]<-'no comparison'
try({
branch="master"
var_Process_1_1files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_1_1_target<-figure_out_nidap_files(var_Process_1_1files)
var_Process_1_1_new<-readRDS(paste0(rds_output,"/var_Process_1_1.rds"))
report["var_Process_1_1"]<-report_differences(var_Process_1_1_target,var_Process_1_1_new)
},silent=TRUE)
print(report["var_Process_1_1"])
###################################
rid="ri.vector.main.execute.c39dc46c-63a1-4d21-9920-c3abc291b332"
report["var_Process_1_2"]<-'no comparison'
try({
branch="master"
var_Process_1_2files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_1_2_target<-figure_out_nidap_files(var_Process_1_2files)
var_Process_1_2_new<-readRDS(paste0(rds_output,"/var_Process_1_2.rds"))
report["var_Process_1_2"]<-report_differences(var_Process_1_2_target,var_Process_1_2_new)
},silent=TRUE)
print(report["var_Process_1_2"])
###################################
rid="ri.vector.main.execute.6f68e3a5-ebf5-4fc0-97a7-753d87eecd69"
report["var_Process_2"]<-'no comparison'
try({
branch="master"
var_Process_2files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_2_target<-figure_out_nidap_files(var_Process_2files)
var_Process_2_new<-readRDS(paste0(rds_output,"/var_Process_2.rds"))
report["var_Process_2"]<-report_differences(var_Process_2_target,var_Process_2_new)
},silent=TRUE)
print(report["var_Process_2"])
###################################
rid="ri.vector.main.execute.70a499d0-f9cd-4230-bf4b-2198bde81c40"
report["var_Process_3"]<-'no comparison'
try({
branch="master"
var_Process_3files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_3_target<-figure_out_nidap_files(var_Process_3files)
var_Process_3_new<-readRDS(paste0(rds_output,"/var_Process_3.rds"))
report["var_Process_3"]<-report_differences(var_Process_3_target,var_Process_3_new)
},silent=TRUE)
print(report["var_Process_3"])
###################################
rid="ri.foundry.main.dataset.66e03eaa-2a47-49dd-ba1a-20eea7c859e9"
report["var_Process_3_1"]<-'no comparison'
try({
branch="master"
var_Process_3_1files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_3_1_target<-figure_out_nidap_files(var_Process_3_1files)
var_Process_3_1_new<-readRDS(paste0(rds_output,"/var_Process_3_1.rds"))
report["var_Process_3_1"]<-report_differences(var_Process_3_1_target,var_Process_3_1_new)
},silent=TRUE)
print(report["var_Process_3_1"])
###################################
rid="ri.foundry.main.dataset.620aad22-ba43-4003-b1a8-ef6aba4d12e7"
report["var_Process_4"]<-'no comparison'
try({
branch="master"
var_Process_4files<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_Process_4_target<-figure_out_nidap_files(var_Process_4files)
var_Process_4_new<-readRDS(paste0(rds_output,"/var_Process_4.rds"))
report["var_Process_4"]<-report_differences(var_Process_4_target,var_Process_4_new)
},silent=TRUE)
print(report["var_Process_4"])
###################################
