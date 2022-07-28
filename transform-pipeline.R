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
# The path to exported NIDAP codebook repo
exported_NIDAP_codebook = "/rstudio-files/ccbr-data/projects/r3-christine-minnar-cleaned/CMM_052223_R3_Final/"

# The branch of dataset to be pulled
branch_of_dataset = "master"

# The path to the target working directory, which should be the your main 
target_working_directory = "/rstudio-files/ccbr-data/projects/r3-christine-minnar-cleaned/"

# The name of folder to stored the parsed pipeline, which will be under the target working directory
foldername_to_store_pipeline <- "test_transform_pipeline"


# OPTIONAL
# The path to the NIDAP transform scripts, generally the user does not need to modify this unless required.
location_of_NIDAP_transform_scripts = "/rstudio-files/ccbr-data/git-repos/nidap-export/"

#############################################################
#############################################################
######### Automated portion, please do not change ###########
#############################################################
#############################################################

# Set the envrionment to the target working directory
setwd(target_working_directory)

# Acquire the key (the user's personal token in NIDAP) to access NIDAP
key=Sys.getenv("key")

# Source the transform.R from the repo
source(paste0(location_of_NIDAP_transform_scripts,"transform.R"))

# Generate the folder path
target_folder_directory <- paste0(target_working_directory, 
                                  foldername_to_store_pipeline)

# Acquire path to exported pipelines
exported_R_script_from_NIDAP <- paste0(exported_NIDAP_codebook, "pipeline.R")
exported_Python_script_from_NIDAP <- paste0(exported_NIDAP_codebook, "pipeline.py")

# Run the transform_pipeline
transform_pipeline(exported_R_script_from_NIDAP,
                   target_folder_directory, 
                   location_of_NIDAP_transform_scripts, 
                   branch_of_dataset,
                   exported_Python_script_from_NIDAP, 
                   gc_option=TRUE)

# Set current working directory to the target_folder_directory
setwd(target_folder_directory)
