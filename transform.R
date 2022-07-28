# Dev Note
# The transform.R was developed by Robin, and refactored by Rui
# Current directory is 
# /rstudio-files/ccbr-data/git-repos/nidap-export
# This is the refactored version, original file can be found in 
# /rstudio-files/ccbr-data/RSK/nidap_transfer_scripts2/


# Library 
library(stringr)


# Body
transform_pipeline <- function(pipe_R, 
                               pipeline_dir, 
                               package_prfix, 
                               branch, 
                               pipe_py, 
                               gc_option){

  
  
# Create  directory for parsed scripts  
  dir.create(pipeline_dir)

# Read exported NIDAP pipeline, pipe_py for python script, pipe_in for R script
  Exported_python_script <- readLines(pipe_py)
  Exported_R_script <- readLines(pipe_R)

# Create list of functions, each function is a tranform in NIDAP codebook
  function_file_list <- c()
  formated_list <- c()

  state="code"
  newhash <- list()
  outhash <- list()


  this_function_out = NA
  this_function_in = list()


  functions <- list()

# Loop through every line in R script, remove NIDAP specific code, and formulate a cleaned list for further processing.
  orid = ""
  line_out_number = 1
  function_out_number = 1
  lastout = ""
  funname = "_"
  
  for(lin in 1 : length(Exported_R_script)){
    
    if(grepl("^@", Exported_R_script[lin])){
      state = "trans"
      function_file_list[[function_out_number]] <- formated_list
      print(funname)
      
      if(funname != "_"){
        functions[[funname]]$codebody <- formated_list
      }
      
      formated_list <- c()
      line_out_number = 1
      function_out_number <- function_out_number + 1
      
    }else if(state == "trans" && grepl("Input", Exported_R_script[lin])){
      current_line = Exported_R_script[lin]
      var2 = paste0("var_", trimws(str_match(current_line, "(?<=^).+?(?==)")))
      rid2 = str_match(current_line, "(?<=\\(rid=\").+?(?=\"\\))")
      this_function_in[rid2] <- var2
      
      if( !(rid2 %in% names(newhash)) && !(rid2 %in% names(outhash))){
        newhash[rid2] = var2
      }
  
    }else if(state == "trans" && grepl("Output", Exported_R_script[lin])){
      current_line = Exported_R_script[lin]
      rid2 = str_match(current_line, "(?<=\\(rid=\").+?(?=\"\\))")

      if(rid2 %in% outhash){
        print("error output rid seen more than once", rid2)
      }
  
      lastout <- rid2

      if(rid2 %in% names(newhash)){
        newhash[[rid2]] <- NULL
      }
      
    }else if(state == "trans" && grepl("^)", Exported_R_script[lin])){
      state = "transdone"
      
    }else if(state == "transdone" && grepl("sample_metadata <-", Exported_R_script[lin])){
      #exception we don't want the smple_metadata workbook
      print("sample_metadata")
      print(lastout)
      newhash[lastout] = "var_sample_metadata"
      outhash[[lastout]] <- NULL
      state = "function"
      formated_list[line_out_number] = Exported_R_script[lin]
      line_out_number <- line_out_number + 1
      
    }else if(state == "transdone" && grepl("<-", Exported_R_script[lin])){
      formated_list[line_out_number] = Exported_R_script[lin]
      line_out_number <- line_out_number + 1
      state = "function"
      var2 = str_extract(Exported_R_script[lin], "^.+?(?= |<)")
      this_function_out <- paste0("var_", var2)
      outhash[lastout] = this_function_out
      vars1 <- unname(c(outhash, newhash)[names(this_function_in)])
      myfun <- list(n=var2, out=this_function_out, 
                    ins=this_function_in, sig=Exported_R_script[lin])
      functions[[var2]] <- myfun
      funname <- var2
      this_function_out <- NA
      this_function_in <- list()
      
    }else if(grepl("graphicsFile", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('graphicsFile', paste0('"', funname,'.png"'), Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
    }else if(grepl("createDataFrame",Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('createDataFrame', "", Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
    }else if(grepl("orthology_table %>% SparkR::withColumnRenamed", Exported_R_script[lin])){
      formated_list[line_out_number] = 'orthology_table %>% dplyr::rename("orthology_reference" = orthology_reference_column) %>%'
      line_out_number <- line_out_number + 1
      
    }else if(grepl(fixed('SparkR::withColumnRenamed\\(orthology_conversion_column, "orthology_conversion"\\) %>% SparkR::select\\("orthology_reference", "orthology_conversion"\\) -> orthology_table'), Exported_R_script[lin])){
      formated_list[line_out_number] = 'dplyr::rename("orthology_conversion" = orthology_conversion_column ) %>% dplyr::select("orthology_reference", "orthology_conversion") -> orthology_table'
      line_out_number <- line_out_number + 1
  
    }else if(grepl("SparkR::`%in%`", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('SparkR::', "", 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
  
    }else if(grepl("SparkR::", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('SparkR::',"dplyr::", 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
  
    }else if(grepl("library.FoundrySparkR", Exported_R_script[lin])){
      formated_list[line_out_number] = "library(dplyr)"
      line_out_number <- line_out_number + 1
  
    }else if(grepl("output_fs\\$open", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('output_fs\\$open', 'file', 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
    }else if(grepl("\\$get_path", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('output_fs\\$get_path','file', 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1

    }else if(grepl("new.output()", Exported_R_script[lin])){
      formated_list[line_out_number] = paste0("# auto removed: ", 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
    }else if(grepl("\\$fileSystem\\(\\)", Exported_R_script[lin])){
      formated_list[line_out_number] = paste0("# auto removed: ", 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
    }else if(!grepl("install.packages|FRObjects", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('RFoundryObject\\(', 'list(value=', 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
    }
  }

  function_file_list[[function_out_number]] <- formated_list
  print(funname)
  functions[[funname]]$codebody <- formated_list
  function_file_names <- c("workbook_start_globals.R")

# Parsing templates
  print("Parsing Templates ======================================================")
  for(function_line in 1:length(functions)){
    fun <- functions[[function_line]]
    function_file_names[function_line + 1] <- paste0("template_function_", fun$n, ".R")
    functions[[function_line]]$filename <- function_file_names[function_line + 1]
    ino = str_match(fun$sig, "(?<=\\().*?(?=\\))")
    
    # Error handle: Invalid parameters
    if(nchar(ino) > 0){
      ino1 <- trimws(str_split(ino, ",")[[1]])
      
      if(sum(ino1 == "") > 0){
        print("=====================Function parameters are invalid, missing parameter stopping===================")
        print(fun$sig)
        stop()
      }
        print(ino1)
        revins <- names(fun$ins)
        names(revins) <- unname(fun$ins)
        orevins <- revins[paste0("var_", ino1)]
        varl <- ifelse(unname(orevins) %in% names(outhash), 
                       outhash[orevins], newhash[orevins])
        ins = paste0(unname(varl), collapse = ',')
    
    }else{
      ins = ""
      varl = list()
    }
    
    functions[[function_line]]$bind <- paste0(fun$out, "<-", 
        fun$n, "(", ins, ")")
    functions[[function_line]]$vars <- varl
  }

  calcvars <- unlist(unname(newhash))
  uncalcfun <- logical(length = length(functions))
  numfuncs = length(uncalcfun)

# Topologically sorting Templates, creating topomap
  seqsfunc <- c()
  seqsfunc <- c(seqsfunc, "options(browser = 'FALSE')")
  progress = TRUE
  print("Sorting Templates ======================================================")

  run_pipeline_script <- file(paste0(pipeline_dir, "/run_pipeline.sh"),"w")
  writeLines("set -e", con = run_pipeline_script)
  
  # Loop through the processed code list to generate separate R script
  while(numfuncs > 0 && progress){
    numfuncsstart <- numfuncs
    
    for(i in 1 : length(functions)){
      if(uncalcfun[i] == FALSE){
        func <- functions[[i]]
      
      if(sum(func$vars %in% calcvars) == length(func$vars)){
        print(func$filename)
        rds_output <- paste(pipeline_dir, "/rds_output", sep = "")
        
        if (file.exists(rds_output) != 1) {
          dir.create(rds_output, showWarnings = FALSE)
        }
  
        new_R_script <- file(paste0(pipeline_dir, "/", func$filename), "w")
        writeLines(func$codebody, con = new_R_script)
        function_script_body <- c(paste0("print(\"", func$filename, " #########################################################################\")"))
        writeLines(paste0("Rscript ", func$filename), 
                   con = run_pipeline_script)
        function_script_body <- c(function_script_body, 
                                  "library(plotly);library(ggplot2);library(jsonlite);")
        
        for(inrds in func$vars){
          function_script_body <- c(function_script_body, 
              "currentdir <- getwd()")
          function_script_body <- c(function_script_body, 
              "rds_output <- paste0(currentdir,'/rds_output')")
          function_script_body <- c(function_script_body, 
              paste0(inrds,"<-readRDS(paste0(rds_output,\"", "/", inrds, ".rds\"))"))
          function_script_body <- c(function_script_body, 
              paste0(inrds,"<-as.data.frame(", inrds, ")"))
        }
        
        function_script_body <- c(function_script_body, 
              paste0("invisible(graphics.off())"))
        function_script_body <- c(function_script_body, 
              func$bind)
        function_script_body <- c(function_script_body, 
              paste0("invisible(graphics.off())"))
        function_script_body <- c(function_script_body, 
              paste0("saveRDS(", func$out, ", paste0(rds_output,\"", 
                     "/", func$out, ".rds\"))"))
        
        # End of constructing script body and ready to write to file 
        writeLines(function_script_body, con = new_R_script)
        close(new_R_script)
        calcvars <- append(calcvars, func$out)
        uncalcfun[i] = TRUE
        numfuncs <- numfuncs - 1
        print(numfuncs)
        }
      }
    }
    
    # Error handle: Error topologically sorting graph
    if(numfuncs == numfuncsstart){
      print("Error topologically sorting graph, stopping")
      print("Unsatisfiable functions dependencies, check parse errors:")
      
      for(k in 1 : length(functions)){
        if(uncalcfun[k] == FALSE){
          func <- functions[[k]]
          print(func$sig)
          print(func$vars)
          function_line <- k
          fun <- func
          ino = str_match(fun$sig, "(?<=\\().*?(?=\\))")
          print(ino)
          
          if(nchar(ino)>0){
            ino1 <- trimws(str_split(ino, ",")[[1]])
            print("split")
            print(ino1)
            print("meta names")
            print(names(fun$ins))
            revins <- names(fun$ins)
            names(revins) <- unname(fun$ins)
            orevins <- revins[paste0("var_",ino1)]
            varl <- ifelse(unname(orevins) %in% names(outhash), 
                           outhash[orevins], newhash[orevins])
            print("varl")
            print(varl)
            ins = paste0(unname(varl), collapse = ',')
            }
          }
        }
      stop()
    }
  }


# Constructing get_date.R script
  print("write transport scripts")
  get_data_script <- file(paste0(pipeline_dir, "/get_data.R"), "w")
  writeLines(paste0("source(\"", package_prfix, 
      "download_tools.R\")"), con = get_data_script)
  writeLines("key<-Sys.getenv(\"key\")", 
       con = get_data_script)

  # Write rds output into a folder
  rds_output <- paste(pipeline_dir, "/rds_output", sep = "")
  writeLines(paste0("rds_output<-\"", rds_output, "\""), con = get_data_script)
  writeLines("if (file.exists(rds_output)!=1) {", con = get_data_script)
  writeLines("dir.create(rds_output,showWarnings = FALSE)}", con = get_data_script)
  
  
  for(new_hash_line in names(newhash)){
    print(new_hash_line)
    writeLines(paste0("rid=\"", new_hash_line, "\""), 
        con = get_data_script)
    branch1 = "master"
    
    if(sum(grepl(new_hash_line, Exported_python_script)) != 0){
      branch1 = branch
    }
    
    writeLines(paste0("branch=\"", branch1,"\""), 
       con = get_data_script)
    get_data <- paste0(newhash[new_hash_line], 
       "files","<-pullnidap_raw(key=key,rid=rid,branch=branch)")
    writeLines(get_data, con = get_data_script)
    get_data <- paste0(newhash[new_hash_line], 
       "<-figure_out_nidap_files(", newhash[new_hash_line], "files",")")
    writeLines(get_data, con = get_data_script)
    get_data <- paste0("saveRDS(", newhash[new_hash_line], 
       ",\"", rds_output, "/", newhash[new_hash_line], ".rds\"", ")")
    writeLines(get_data, con = get_data_script)
  }
  
  close(get_data_script)
  writeLines('source("workbook_start_globals.R")', 
     con = run_pipeline_script)
  close(run_pipeline_script)

# Construct verification file
  print("Writing verification file -------------------------------------------------")
  print("write verification scripts")
  verify_data_script <- file(paste0(pipeline_dir, "/verify_data.R"), "w")
  #writeLines(paste0('setwd("',pipeline_dir,'")'),con=verify_data_script)
  writeLines(paste0("source(\"", package_prfix, 
      "download_tools.R\")"), con = verify_data_script)
  writeLines("key<-Sys.getenv(\"key\")", con = verify_data_script)
  writeLines("report<-list()", con = verify_data_script)
  writeLines("currentdir <- getwd()", con = verify_data_script)
  writeLines("rds_output <- paste0(currentdir,\"/rds_output\")", 
       con = verify_data_script)
  
  for(new_hash_line in names(outhash)){
    print(new_hash_line)
    writeLines(paste0("rid=\"", new_hash_line,"\""), 
         con = verify_data_script)
    branch1 = branch
    verify_data <- paste0("report[\"", outhash[new_hash_line], "\"]<-'no comparison'")
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0("try({")
    writeLines(verify_data,con = verify_data_script)
    writeLines(paste0("branch=\"", branch1, "\""), 
         con = verify_data_script)
    verify_data <- paste0(outhash[new_hash_line], "files", 
          "<-pullnidap_raw(key=key,rid=rid,branch=branch)")
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0(outhash[new_hash_line], "_target", 
          "<-figure_out_nidap_files(", outhash[new_hash_line], "files", ")")
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0(outhash[new_hash_line], "_new", 
          "<-readRDS(paste0(rds_output,\"", "/", outhash[new_hash_line], ".rds\"", "))")
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0("report[\"", outhash[new_hash_line], 
          "\"]<-report_differences(", outhash[new_hash_line], 
          "_target,", outhash[new_hash_line], "_new)")
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0('},silent=TRUE)')
    writeLines(verify_data, con = verify_data_script)
    verify_data <- paste0("print(report[\"", outhash[new_hash_line], "\"])")
    writeLines(verify_data, con = verify_data_script)
    writeLines("###################################", con = verify_data_script)
    }
  close(verify_data_script)
}
