source("/rstudio-files/ccbr-data/git-repos/nidap-export/download_tools.R")
key<-Sys.getenv("key")
rds_output<-"./exported_pipeline/rds_output"
if (file.exists(rds_output)!=1) {
dir.create(rds_output,showWarnings = FALSE)}
rid="ri.foundry.main.dataset.8cd125d5-9cd1-4305-9c68-0ca114a34943"
branch="master"
var_ccbr804_metadata_for_NIDAPfiles<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_ccbr804_metadata_for_NIDAP<-figure_out_nidap_files(var_ccbr804_metadata_for_NIDAPfiles)
saveRDS(var_ccbr804_metadata_for_NIDAP,"./exported_pipeline/rds_output/var_ccbr804_metadata_for_NIDAP.rds")
rid="ri.foundry.main.dataset.31a7e6b4-37c2-4b78-bff8-2130f2039eb2"
branch="master"
var_ccbr804_rawcounts_for_NIDAP_csvfiles<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_ccbr804_rawcounts_for_NIDAP_csv<-figure_out_nidap_files(var_ccbr804_rawcounts_for_NIDAP_csvfiles)
saveRDS(var_ccbr804_rawcounts_for_NIDAP_csv,"./exported_pipeline/rds_output/var_ccbr804_rawcounts_for_NIDAP_csv.rds")
rid="ri.foundry.main.dataset.7e2bf6bd-4851-4392-b5c0-939d4beff279"
branch="master"
var_msigdb_v6_2_with_orthologsfiles<-pullnidap_raw(key=key,rid=rid,branch=branch)
var_msigdb_v6_2_with_orthologs<-figure_out_nidap_files(var_msigdb_v6_2_with_orthologsfiles)
saveRDS(var_msigdb_v6_2_with_orthologs,"./exported_pipeline/rds_output/var_msigdb_v6_2_with_orthologs.rds")
