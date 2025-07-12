# Dev Note
# The transfrom_piepline.R was developed by Robin, and refactored by Rui
# Current directory is 
# /rstudio-files/ccbr-data/git-repos/nidap-export
# This is the refactored version, original file can be found in 
# /rstudio-files/ccbr-data/RSK/nidap_transfer_scripts2/

# This code is expected to run on the workbench server: nciws-d2335-v

#############################################################
#############################################################
################## User defined portion  ####################
#############################################################
#############################################################

# Required
# Run tutorial or unit test, if set TRUE, 
# plase set working directory at the nidap-export folder in the repo
# Otherwise, please use TULL PATH to each directory.
Tutorial_and_unit_test = FALSE

# The path to the target working directory, which should be the your main
# For tutorial, please set the current working directory in the test folder.
target_working_directory = "./"
 
# The path to exported NIDAP codebook repo from target directory
exported_NIDAP_codebook = "./Unit_test_workbook/"

# The name of folder to stored the parsed pipeline, which will be under the target working directory
foldername_to_store_pipeline <- "Unit_test_pipeline"

# The branch of dataset to be pulled
branch_of_dataset = "master"

# The path to the NIDAP transform scripts from current directory, 
# generally the user does not need to modify this unless required.
# The repo location is "/rstudio-files/ccbr-data/git-repos/nidap-export"
# For tutorial, please u
location_of_NIDAP_transform_scripts = "./nidap-export/nidap_exporter/R3_to_Docker/Code_Transformation"

# Retrieve command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Default values
target_working_directory <- if (length(args) >= 1) args[[1]] else target_working_directory
exported_NIDAP_codebook <- if (length(args) >= 2) args[[2]] else exported_NIDAP_codebook
foldername_to_store_pipeline <- if (length(args) >= 3) args[[3]] else foldername_to_store_pipeline
branch_of_dataset <- if (length(args) >= 4) args[[4]] else branch_of_dataset
location_of_NIDAP_transform_scripts <- if (length(args) >= 5) args[[5]] else location_of_NIDAP_transform_scripts

# Print for confirmation (optional)
cat("Target working directory:", target_working_directory, "\n")
cat("Exported NIDAP codebook path:", exported_NIDAP_codebook, "\n")
cat("Folder to store pipeline:", foldername_to_store_pipeline, "\n")
cat("Branch of dataset:", branch_of_dataset, "\n")
cat("Tool set location:", location_of_NIDAP_transform_scripts, "\n")


#############################################################
#############################################################
######### Automated portion, please do not change ###########
#############################################################
#############################################################

# location_of_NIDAP_transform_scripts_from_target_folder
location_of_NIDAP_transform_scripts_from_target_folder <- paste0(location_of_NIDAP_transform_scripts,
                                                                 "/")

# Set parameter set for unit test and tutorial
if (Tutorial_and_unit_test == TRUE) {
  setwd("./test")
  target_working_directory = "./"
  exported_NIDAP_codebook = "./Unit_test_workbook/"
  foldername_to_store_pipeline <- "Unit_test_pipeline"
  branch_of_dataset = "master"
  location_of_NIDAP_transform_scripts = "../"
  #location_of_NIDAP_transform_scripts_from_target_folder <- 
  #  paste0("../", location_of_NIDAP_transform_scripts)
}

# Set the envrionment to the target working directory
setwd(target_working_directory)

# Acquire the key (the user's personal token in NIDAP) to access NIDAP
key=Sys.getenv("key")

# Source the transform.R from the repo
source(paste0(location_of_NIDAP_transform_scripts,"transform.R"))

# Generate the folder path
target_folder_directory <- paste0("./",foldername_to_store_pipeline)

# Acquire path to exported pipelines
exported_R_script_from_NIDAP <- paste0(exported_NIDAP_codebook, "pipeline.R")
# exported_Python_script_from_NIDAP <- paste0(exported_NIDAP_codebook, "pipeline.py")



# Run the transform_pipeline 
transform_pipeline(exported_R_script_from_NIDAP,
                   target_folder_directory, 
                   location_of_NIDAP_transform_scripts_from_target_folder, 
                   branch_of_dataset,
                   exported_Python_script_from_NIDAP)

# Set current working directory to the target_folder_directory
# Will not change directory for tutorial
if (Tutorial_and_unit_test != TRUE) {
  setwd(target_folder_directory)
  }

