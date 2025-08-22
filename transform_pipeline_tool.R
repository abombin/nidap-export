library(optparse)

transform_download_script <- function(input_file, branch_name, output_file) {
  # Read all lines from input file
  lines <- readLines(input_file)
  output_lines <- c()
  i <- 1
  while (i <= length(lines)) {
    line <- trimws(lines[i])
    # Check if current line is branch="master"
    if (grepl('branch\\s*=\\s*["\']master["\']', line)) {
      # Found branch="master", collect the next 2 lines
      branch_line <- lines[i]
      pullnidap_line <- if (i + 1 <= length(lines)) lines[i + 1] else ""
      figure_out_line <- if (i + 2 <= length(lines)) lines[i + 2] else ""
      save_line <- if (i + 3 <= length(lines)) lines[i + 3] else ""
      # Create modified version with CD8_Tcells
      #modified_branch <- gsub('["\']master["\']', '"CD8_Tcells"', branch_line)
      #modified_branch <- gsub('master', branch_name, branch_line)
      modified_branch <- gsub('["\']master["\']', paste0('"', branch_name, '"'), branch_line)
      # Create the try/catch block
      print("generate output lines")
      output_lines <- c(output_lines,
                        paste0("# Try ", branch_name, " first, fallback to master"),
                        "tryCatch({",
                        paste0("  ", modified_branch),
                        paste0("  ", pullnidap_line),
                        paste0("  ", figure_out_line),
                        paste0("  ", save_line),
                        "}, error = function(e) {",
                        paste0("  cat('", branch_name, " failed, trying master...\\n')"),
                        paste0("  ", branch_line),
                        paste0("  ", pullnidap_line),
                        paste0("  ", figure_out_line),
                        paste0("  ", save_line),
                        "})")
      
      # Skip the next 2 lines since we already processed them
      i <- i + 4
    } else {
      # Regular line, just copy it
      output_lines <- c(output_lines, lines[i])
      i <- i + 1
    }
  }
  
  # Write the transformed script
  writeLines(output_lines, output_file)
  cat("Transformed script written to:", output_file, "\n")
}

option_list <- list(
  make_option(c("-i", "--input"), type = "character",
              help = "Path to the exported_NIDAP_codebook (required)"),
  make_option(c("-w", "--target_w_dir"), type = "character",
              help = "The path to the target working directory, which should be your main directory (optional). If omitted, use current working directory."),
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

cmd = paste0("cp nidap-export/run_pipeline.py ", foldername_to_store_pipeline, "/")
system(cmd)

# identify GSVA templates
gsva_templates = list.files(foldername_to_store_pipeline, pattern = "GSVA", full.names = T)
gsva_templates = gsva_templates[!grepl("PostIt", gsva_templates, ignore.case = T)]

# make edits 
for (cur_teplate in gsva_templates) {
  content <- readLines(cur_teplate, warn = FALSE)
  content <- paste(content, collapse = "\n")
  content <- gsub("geneset_table <- geneset_table %>% dplyr::filter(filter_string)", 
                  "geneset_table <- geneset_table[grepl(constraints, geneset_table[, filter_column], ignore.case = T),]", 
                  content, fixed = T)
  
  writeLines(content, cur_teplate)
}

# edit template_AutoThresh.R

if (file.exists(paste0(foldername_to_store_pipeline,"/template_AutoThresh.R"))) {
  content <- readLines(paste0(foldername_to_store_pipeline,"/template_AutoThresh.R"), warn = FALSE)
  content <- paste(content, collapse = "\n")
  content <- gsub("return(so[[1]])", 
                  "#return(so[[1]])", 
                  content, fixed = T)
  writeLines(content, paste0(foldername_to_store_pipeline,"/template_AutoThresh.R"))
}

# Set current working directory to the target_folder_directory
if (download_data) {
  setwd(target_folder_directory)
  Sys.setenv(nidap_key = key)
  if (branch_of_dataset == "master") {
    system(paste0(rscript_path, " get_data.R"))
  } else {
    transform_download_script(input_file = "get_data.R",
                              output_file = "get_data_branch.R", 
                              branch_name = branch_of_dataset)
    
    system(paste0(rscript_path, " get_data_branch.R"))
  }
}

