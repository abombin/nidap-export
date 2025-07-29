library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), type = "character",
              help = "Path to the exported_NIDAP_codebook (required)"),
  make_option(c("-w", "--target_w_dir"), type = "character",
              help = "The path to the target working directory, which should be the your main (optional). If omitted, use current working directory."),
  make_option(c("-o", "--output_dir_name"), type = "character",
              help = "The name of folder to stored the parsed pipeline, which will be under the target working directory (optional). If omitted, it's generated from the input name."),
  make_option(c("-b", "--branch"), type = "character", default = "master",
              help = "The branch of dataset to be pulled (optional). [default %default]"),
  make_option(c("-k", "--key"), type = "character",
              help = "Acquire the key (the user's personal token in NIDAP) to access NIDAP (optional). If omitted, uses nidap_key environmental variable"),
  make_option(c("-d", "--run_get_data"),
              action = "store_true",
              default = FALSE,
              help = "Enable automatic download of data set [default %default]"),
  make_option(c("-r", "--rscript_path"), type = "character", default = "/opt/R/4.1.3/lib64/R/bin/Rscript",
              help = "Path to Rscript 4.1.3 (optional). [default %default]")
)

# Create a parser and parse the arguments
parser <- OptionParser(option_list = option_list)
opts <- parse_args(parser)

# Check if required '--input' argument was provided
if (is.null(opts$input)) {
  print_help(parser)
  stop("The --input argument is required.", call. = FALSE)
} 

if (is.null(opts$target_w_dir)) {
  opts$target_w_dir <- getwd()
} 

# If the output option was not provided by the user, opts$output will be NULL.
if (is.null(opts$output_dir_name)) {
  opts$output <- paste0(opts$input, "_pipeline")
  cat("Output file not specified. Defaulting to:", opts$output, "\n")
} 

if (is.null(opts$key)) {
  opts$key <- Sys.getenv("nidap_key")
} 


exported_NIDAP_codebook = paste0(opts$input, "/")
target_working_directory = paste0(opts$target_w_dir, "/")
foldername_to_store_pipeline = opts$output
branch_of_dataset = opts$branch
location_of_NIDAP_transform_scripts = paste0(target_working_directory, "nidap-export/nidap_exporter/R3_to_Docker/Code_Transformation/")
key = opts$key
download_data = opts$run_get_data
rscript_path = opts$rscript_path

# Print for confirmation (optional)
cat("Target working directory:", target_working_directory, "\n")
cat("Exported NIDAP codebook path:", exported_NIDAP_codebook, "\n")
cat("Folder to store pipeline:", foldername_to_store_pipeline, "\n")
cat("Branch of dataset:", branch_of_dataset, "\n")
cat("Tool set location:", location_of_NIDAP_transform_scripts, "\n")

# location_of_NIDAP_transform_scripts_from_target_folder
location_of_NIDAP_transform_scripts_from_target_folder <- paste0(location_of_NIDAP_transform_scripts,
                                                                 "/")
# Set the envrionment to the target working directory
setwd(target_working_directory)

# Source the transform.R from the repo
source(paste0(location_of_NIDAP_transform_scripts,"transform.R"))

# Generate the folder path
#target_folder_directory <- paste0("./",foldername_to_store_pipeline)
target_folder_directory <- foldername_to_store_pipeline

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

if (download_data) {
  setwd(target_folder_directory)
  Sys.setenv(nidap_key = key)
  system(paste0(rscript_path, " get_data.R"))
}


# last step that I need to do is to replace "key" with "nidap_key" in transform.R script


