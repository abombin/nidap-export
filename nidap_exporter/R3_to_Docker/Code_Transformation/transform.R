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
                               pipe_py){

  
  
# Create  directory for parsed scripts  
  dir.create(pipeline_dir)

# Read exported NIDAP pipeline, pipe_py for python script, pipe_in for R script
  # Exported_python_script <- readLines(pipe_py)
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
  current_input_var <- NULL
  
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
      
      var_input <-  str_extract(Exported_R_script[lin], '[(]\\S+[)]')
      var_input <- gsub("[()]", "", var_input)
      var_input_name <- var_input
      var_input <- paste0("var_", var_input, ".rds")
      
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
      
      # 8/10/22 RH: Update by adding gsub(), The replacement apprears to be a part of a line rather than stand alone line
    }else if(grepl('localFilePaths <- ',Exported_R_script[lin])){
      formated_list[line_out_number] = paste0('localFilePaths <- readRDS("', "./rds_output/", var_input, '")')
      line_out_number <- line_out_number + 1
      
      # 9/16/2022 RH: for h5 file handling
    }else if(grepl("\\$fileSystem\\(\\)", Exported_R_script[lin])){
      
      current_input_var <- sub("\\$fileSystem\\(\\).*", "", Exported_R_script[lin])
      current_input_var <- sub(".*<-\\s*", "", current_input_var)
      current_input_var <- trimws(current_input_var)
      formated_list[line_out_number] = paste0("# auto removed: ", 
                                              Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
    }else if(grepl(' <- fs\\w*\\$', Exported_R_script[lin])){
      formated_list[line_out_number] = paste0('# auto removed: ', Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
      # 9/16/2022 RH: for h5 file handling
    }else if(grepl('<- nidapGetPath', Exported_R_script[lin])){
      formated_list[line_out_number] = paste0('# auto removed: ', Exported_R_script[lin])
      # Extract the content within parentheses of nidapGetPath
      current_input_var <- sub(".*nidapGetPath\\((.*)\\).*", "\\1", Exported_R_script[lin])
      
      # Split the arguments by comma
      current_input_var <- strsplit(current_input_var, ",")[[1]]
      current_input_var <- trimws(current_input_var)
      
      line_out_number <- line_out_number + 1
      
      # 7/16/2024 RH: for latest get path
    }else if(grepl('<- readRDS', Exported_R_script[lin])){
      formated_list[line_out_number] = paste0(sub("<-.*", "<- ", Exported_R_script[lin]), current_input_var)
      line_out_number <- line_out_number + 1
      
      # 7/16/2024 RH: for latest get path
    }else if(grepl("return\\(NULL\\)", Exported_R_script[lin])){
      formated_list[line_out_number] = paste0('# auto removed: ', Exported_R_script[lin])
      line_out_number <- line_out_number + 1
      
      # 9/16/2022 RH: for h5 file handling
    }else if(grepl("saveRDS\\(", Exported_R_script[lin])){
      var_current_output <-  str_extract(Exported_R_script[lin], '[(]\\S+[,]')
      var_current_output <- gsub("[(,]", "", var_current_output)
      
      formated_list[line_out_number] = paste0('return(', var_current_output, ")")
      line_out_number <- line_out_number + 1
      
      # 9/16/2022 RH: for h5 file handling
    }else if(grepl("\\$upload\\(", Exported_R_script[lin])){
      formated_list[line_out_number] = paste0('# auto removed: ', Exported_R_script[lin])
      line_out_number <- line_out_number + 1
    }else if(grepl("htmlwidgets\\:\\:saveWidget\\(", Exported_R_script[lin])){
      modified_line <- gsub(
        "(htmlwidgets\\:\\:saveWidget\\([^,]+,)[^,]+(,.+\\))", 
        paste0("\\1 \"", funname, "\" \\2"), 
        Exported_R_script[lin]
      )
      formated_list[line_out_number] = modified_line
      line_out_number <- line_out_number + 1
    }else if(grepl("stop\\(\\'Input data not properly imported into Workbook\\'\\)", Exported_R_script[lin])){
      formated_list[line_out_number] = "input.dat <- input[grepl('\\\\.h5$', input)]; input.tcr <- input[grepl('\\\\.csv$', input)]; input=c(input.dat,input.tcr);"
      line_out_number <- line_out_number + 1
    }else if(grepl('stop\\(\\"Input should be Seurat object in rds file format', Exported_R_script[lin])){
      formated_list[line_out_number] =  paste0('# auto removed: ', Exported_R_script[lin])
      line_out_number <- line_out_number + 1
    }else if(grepl("orthology_table %>% SparkR::withColumnRenamed", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub("orthology_table %>% SparkR::withColumnRenamed" ,
                                 'orthology_table %>% dplyr::rename("orthology_reference" = orthology_reference_column) %>%', 
                                   Exported_R_script[lin])
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
      
    }else if(!grepl("install.packages|FRObjects", Exported_R_script[lin])){
      formated_list[line_out_number] = gsub('RFoundryObject\\(', 'list(value=', 
          Exported_R_script[lin])
      line_out_number <- line_out_number + 1
    }
  }

  function_file_list[[function_out_number]] <- formated_list
  print(funname)
  functions[[funname]]$codebody <- formated_list
  function_file_names <- c("")
  
  # AB code to adress GSEA GSVA templates
  all_workflow_function_names = names(functions)
  gsea_template_name = all_workflow_function_names[grepl("GSEA" ,all_workflow_function_names, ignore.case = T) & 
                                           grepl("Preranked" , all_workflow_function_names, ignore.case = T)]
  gsva_template_name = all_workflow_function_names[grepl("GSVA" ,all_workflow_function_names, ignore.case = T) & 
                                                    grepl("Results" , all_workflow_function_names, ignore.case = T)]
  
  gsea_templates_to_correct = c(gsea_template_name, gsva_template_name)
  for (current_template_name in gsea_templates_to_correct) {
    current_template = functions[[current_template_name]]$codebody
    current_template = gsub('pathways_database', 'pathways_df_database', current_template, fixed = T)
    current_template = gsub('pathways_df_database[["species"]] == collection_species', 'species == collection_species', current_template, fixed = T)
    current_template = gsub('pathways_df_database[["collection"]], collections_to_include)', 'collection, collections_to_include)', current_template, fixed = T)
    current_template = gsub('SparkR', 'dplyr', current_template, fixed = T)
    functions[[current_template_name]]$codebody = current_template
  }

# Parsing templates
  print("Parsing Templates ======================================================")
  for(function_line in 1:length(functions)){
    fun <- functions[[function_line]]
    function_file_names[function_line + 1] <- paste0("template_", fun$n, ".R")
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
  
  script_starter_lines <- c(
    "#!/bin/bash",
    "",
    "set -e",
    "for dir in Logs PDFs Images; do",
    "  if [ -d \"$dir\" ]; then",
    "    echo \"Directory $dir already exists, skipping creation.\"",
    "  else",
    "     mkdir \"$dir\"",
    "     chmod -R ug=rwx,o=rx \"$dir\"",
    "     echo \"Directory $dir created successfully.\"",
    "  fi",
    "done",
    "",
    "run_workbook_template() {",
    "  local template_name=$1",
    "  local template_location=$2",
    "  local template_count=$3",
    '  echo "############ ${template_location}/${template_count} ${template_name}.R Starting... ########"',
    "  Rscript ${template_name}.R 2>&1 | tee ./Logs/${template_name}.log; exit_status=${PIPESTATUS[0]}",
    "  if [ $exit_status -ne 0 ]; then",
    "    exit $exit_status",
    "  fi",
    "  if [ -f Rplots.pdf ]; then",
    "    mv Rplots.pdf ./PDFs/${template_name}.pdf",
    "  fi",
    "  find . -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' \\) -exec mv {} Images/ \\;",
    '  echo "############ ${template_location}/${template_count} ${template_name}.R Completed! ########"',
    "}"
  )
  
  writeLines(script_starter_lines, con = run_pipeline_script)
  
  run_pipeline_script_R <- file(paste0(pipeline_dir, "/Console_R_run_pipeline.R"),"w")
  seq_counter <- 1
  
  # Loop through the processed code list to generate separate R script
  while(numfuncs > 0 && progress){
    numfuncsstart <- numfuncs
    total_count <- length(functions)
    for(i in 1 : total_count){
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
        
        
        function_script_body <- c(
          "######### Node Execution Steps ##########",
          paste0("print(\"", func$filename, " #########################################################################\")"))
        writeLines(paste0("############ ", seq_counter, "/", total_count, " ", func$filename, " ########"),
                   con = run_pipeline_script)
        writeLines(
          paste0(
            'run_workbook_template \"',
            sub("\\.R$", "", func$filename),
            '\" \"',
            seq_counter,
            '\" \"',
            total_count,
            '\"'),
          con = run_pipeline_script)
        writeLines(paste0(""),
                   con = run_pipeline_script)
        
        seq_counter <- seq_counter + 1
        
        writeLines(paste0('source("', func$filename, '")'), 
                   con = run_pipeline_script_R)
        new_filename <- paste0(sub("\\.R$", "", func$filename, '\"'),"pdf")
        writeLines(paste0('file.rename("Rplots.pdf","', new_filename,'")'),
                   con = run_pipeline_script_R)
        
        paste0("template_", fun$n, ".R")
        writeLines(paste0('rm(', 
                    gsub("\\.R$", "",
                    gsub("template_", "", func$filename)), 
                    ')'), con = run_pipeline_script_R)

        function_script_body <- c(function_script_body, 
                                  "# Setup Compute Environment")
        function_script_body <- c(function_script_body, 
                                  "library(plotly);library(ggplot2);library(jsonlite);")
        function_script_body <- c(function_script_body, 
                                  "currentdir <- getwd()")
        function_script_body <- c(function_script_body, 
                                  "rds_output <- paste0(currentdir,'/rds_output')")
        function_script_body <- c(
          function_script_body,
          "############################")

        for(inrds in func$vars){
          function_script_body <- c(
            function_script_body,
            "",
            paste0("# Processing input variable: ", inrds))
          
          function_script_body <- c(function_script_body, 
              paste0(inrds,"<-readRDS(paste0(rds_output,\"", "/", inrds, ".rds\"))"),
              "")
          
          function_script_body <- c(
            function_script_body, 
            paste0("if (!('Seurat' %in% class(", inrds, "))) {",
                   " if (!(class(", inrds, ") %in% c('data.frame', 'RFilePath', 'character', 'list'))) {", inrds, " <- as.data.frame(", inrds, ")}}"
            )
          )
          function_script_body <- c(
            function_script_body,
            "#############################",
            ""
          )
          function_script_body <- c(
            function_script_body, 
            paste0(
              "if (class(", inrds,") == 'data.frame') { colnames(", inrds,") <- gsub('.', '_', colnames(",inrds, "), fixed = TRUE)}"
            )
          )
          function_script_body <- c(
            function_script_body,
            "#############################",
            ""
          )
          function_script_body <- c(
            function_script_body, 
            paste0(
              "if (class(", inrds,") == 'data.frame') { colnames(", inrds,") <- gsub('ï»¿', '', colnames(",inrds, "), fixed = TRUE)}"
            )
          )
          function_script_body <- c(
            function_script_body,
            "#############################",
            ""
          )
        }
        
        function_script_body <- c(
          function_script_body,
          "# Saving Output Dataset"
        )
        
        function_script_body <- c(function_script_body, 
              paste0("invisible(graphics.off())"))
        function_script_body <- c(function_script_body, 
              func$bind)

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
      print("=============================================================================")
      print("ERROR: Topological sorting failed - Unsatisfiable function dependencies")
      print("=============================================================================")
      print(paste("Total functions:", length(functions)))
      print(paste("Remaining unprocessed functions:", numfuncs))
      print(paste("Available calculated variables:", paste(calcvars, collapse = ", ")))
      print("")
      
      # Enhanced error reporting with detailed dependency analysis
      unresolved_functions <- c()
      missing_dependencies <- list()
      circular_deps <- list()
      
      print("DETAILED ANALYSIS OF UNRESOLVED FUNCTIONS:")
      print("==========================================")
      
      for(k in 1 : length(functions)){
        if(uncalcfun[k] == FALSE){
          func <- functions[[k]]
          function_name <- func$n
          unresolved_functions <- c(unresolved_functions, function_name)
          
          print(paste(">>> FUNCTION", k, ":", function_name, "<<<"))
          print(paste("   File name:", func$filename))
          print(paste("   Function signature:", func$sig))
          print(paste("   Expected output variable:", func$out))
          print(paste("   Required input variables:", paste(func$vars, collapse = ", ")))
          
          # Check which specific variables are missing
          missing_vars <- func$vars[!(func$vars %in% calcvars)]
          available_vars <- func$vars[func$vars %in% calcvars]
          
          if(length(missing_vars) > 0){
            print(paste("   ❌ MISSING DEPENDENCIES:", paste(missing_vars, collapse = ", ")))
            missing_dependencies[[function_name]] <- missing_vars
          }
          
          if(length(available_vars) > 0){
            print(paste("   ✅ Available dependencies:", paste(available_vars, collapse = ", ")))
          }
          
          # Check for potential circular dependencies
          if(func$out %in% func$vars){
            print("   ⚠️  CIRCULAR DEPENDENCY: Function depends on its own output!")
            circular_deps[[function_name]] <- func$out
          }
          
          # Detailed parameter analysis
          ino = str_match(func$sig, "(?<=\\().*?(?=\\))")
          if(!is.na(ino) && nchar(ino) > 0){
            ino1 <- trimws(str_split(ino, ",")[[1]])
            print(paste("   Function parameters:", paste(ino1, collapse = ", ")))
            print(paste("   Input mappings:", paste(names(func$ins), "->", unname(func$ins), collapse = "; ")))
            
            # Check each parameter mapping
            revins <- names(func$ins)
            names(revins) <- unname(func$ins)
            orevins <- revins[paste0("var_", ino1)]
            
            for(param_idx in 1:length(ino1)){
              param_name <- ino1[param_idx]
              var_name <- paste0("var_", param_name)
              mapped_var <- orevins[var_name]
              
              if(is.na(mapped_var)){
                print(paste("   ❌ UNMAPPED PARAMETER:", param_name, "-> no mapping found"))
              } else {
                final_var <- ifelse(unname(mapped_var) %in% names(outhash), 
                                    outhash[mapped_var], newhash[mapped_var])
                if(is.na(final_var) || is.null(final_var)){
                  print(paste("   ❌ UNRESOLVED PARAMETER:", param_name, "->", mapped_var, "-> NULL"))
                } else {
                  print(paste("   📋 Parameter mapping:", param_name, "->", mapped_var, "->", final_var))
                }
              }
            }
          }
          print("")
        }
      }
      
      print("DEPENDENCY SUMMARY:")
      print("==================")
      print(paste("Functions with unresolved dependencies:", length(unresolved_functions)))
      
      if(length(missing_dependencies) > 0){
        print("\nMISSING DEPENDENCIES BY FUNCTION:")
        for(fname in names(missing_dependencies)){
          print(paste("  ", fname, "needs:", paste(missing_dependencies[[fname]], collapse = ", ")))
        }
      }
      
      if(length(circular_deps) > 0){
        print("\nCIRCULAR DEPENDENCIES DETECTED:")
        for(fname in names(circular_deps)){
          print(paste("  ", fname, "depends on its own output:", circular_deps[[fname]]))
        }
      }
      
      # Check for potential producers of missing variables
      print("\nPOTENTIAL SOLUTIONS:")
      print("===================")
      all_missing <- unique(unlist(missing_dependencies))
      for(missing_var in all_missing){
        producers <- c()
        for(j in 1:length(functions)){
          if(functions[[j]]$out == missing_var){
            producers <- c(producers, functions[[j]]$n)
          }
        }
        if(length(producers) > 0){
          print(paste("Variable", missing_var, "should be produced by:", paste(producers, collapse = ", ")))
        } else {
          print(paste("Variable", missing_var, "has NO PRODUCER - check newhash or outhash mapping"))
        }
      }
      
      print("\nHASH TABLES STATE:")
      print("==================")
      print("newhash (input variables):")
      if(length(newhash) > 0){
        for(i in 1:length(newhash)){
          print(paste("  ", names(newhash)[i], "->", newhash[[i]]))
        }
      } else {
        print("  (empty)")
      }
      
      print("outhash (output variables):")
      if(length(outhash) > 0){
        for(i in 1:length(outhash)){
          print(paste("  ", names(outhash)[i], "->", outhash[[i]]))
        }
      } else {
        print("  (empty)")
      }
      
      print("=============================================================================")
      stop("Topological sorting failed due to unresolvable dependencies. See detailed analysis above.")
    }
  }


# Constructing get_date.R script
  print("write transport scripts")
  get_data_script <- file(paste0(pipeline_dir, "/get_data.R"), "w")
  writeLines(paste0('source(\"', package_prfix, 
      "download_tools.R\")"), con = get_data_script)
  writeLines("key<-Sys.getenv(\"nidap_key\")", 
       con = get_data_script)

  # Write rds output into a folder
  #rds_output <- paste(pipeline_dir, "/rds_output", sep = "")
  rds_output <- paste("./rds_output", sep = "")
  writeLines(paste0("rds_output<-\"", rds_output, "\""), con = get_data_script)
  writeLines("if (file.exists(rds_output)!=1) {", con = get_data_script)
  writeLines("dir.create(rds_output,showWarnings = FALSE)}", con = get_data_script)
  
  
  for(new_hash_line in names(newhash)){
    print(new_hash_line)
    writeLines(paste0("rid=\"", new_hash_line, "\""), 
        con = get_data_script)
    branch1 = "master"
    
    # if(sum(grepl(new_hash_line, Exported_python_script)) != 0){
    #   branch1 = branch
    # }
    
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
  # writeLines('source("workbook_start_globals.R")', 
     # con = run_pipeline_script)
  
  close(run_pipeline_script)
  close(run_pipeline_script_R)

# Construct verification file
  print("Writing verification file -------------------------------------------------")
  print("write verification scripts")
  verify_data_script <- file(paste0(pipeline_dir, "/verify_data.R"), "w")
  #writeLines(paste0('setwd("',pipeline_dir,'")'),con=verify_data_script)
  writeLines(paste0("source(\"", package_prfix, 
      "download_tools.R\")"), con = verify_data_script)
  writeLines("key<-Sys.getenv(\"nidap_key\")", con = verify_data_script)
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
