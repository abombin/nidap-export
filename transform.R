
library(stringr)
#l0<-readLines("/rstudio-files/ccbr-data/RSK/mylocktest/new_nidap_project/RK1-robin-kramer-nih-gov-12-11-20-03-24/pipeline.R")



#pipeline_dir<-"/rstudio-files/ccbr-data/RSK/scale/transformed_pipeline"
#pipe_in<-"/rstudio-files/ccbr-data/RSK/scale/repo/refactor_single/pipeline.R"


# Dev Note, Rui He, 6/28/2022
# added a line to determine if the rds is a single class variable, then convert it to dataframe uisng "as.data.frame()"
transform_pipeline<-function(pipe_in,pipeline_dir,package_prfix, branch,pipe_py,gc_option){
  dir.create(pipeline_dir)
  py0<-readLines(pipe_py)
  l0<-readLines(pipe_in)
function_file_list<-c()
l1<-c()

state="code"
newhash<-list()
outhash<-list()


thisfunctionout=NA
thisfunctionin=list()


functions<-list()


orid=""
lineoutnum=1
functionoutnum=1
lastout=""
funname="_"
for(lin in 1:length(l0)){
  if(grepl("^@",l0[lin]))
     {
    state="trans"
    function_file_list[[functionoutnum]]<-l1
    print(funname)
    if(funname!="_"){
    functions[[funname]]$codebody<-l1
    }
    l1<-c()
    lineoutnum=1
    functionoutnum<-functionoutnum+1
  }else if(state=="trans" && grepl("Input",l0[lin])){

   # print("input")
    lin1=l0[lin]
    var2=paste0("var_",trimws(str_match(lin1, "(?<=^).+?(?==)")))
    #print(var2)
    rid2=str_match(lin1, "(?<=\\(rid=\").+?(?=\"\\))")
    #print(rid2)
    #print(names(newhash))
    thisfunctionin[rid2]<-var2
    if( !( rid2 %in% names(newhash)) && !( rid2 %in% names(outhash))){
      newhash[rid2]=var2
    }


  }else if(state=="trans" && grepl("Output",l0[lin])){
    #print("output")
    lin1=l0[lin]
    rid2=str_match(lin1, "(?<=\\(rid=\").+?(?=\"\\))")
    #print(rid2)
    if(rid2%in%outhash){
      print("error output rid seen more than once",rid2)
    }

    lastout<-rid2
  # print(rid2)
   # print(outhash)
    if(rid2 %in% names(newhash)){
      newhash[[rid2]] <- NULL

    }
  }else if(state=="trans" && grepl("^)",l0[lin])){
    state="transdone"
  }else if(state=="transdone" && grepl("sample_metadata <-",l0[lin])){
    #exception we don't want the smple_metadata workbook
    print("sample_metadata")
    print(lastout)
    newhash[lastout]="var_sample_metadata"
    outhash[[lastout]]<-NULL
    state="function"
    l1[lineoutnum]=l0[lin]
    lineoutnum<-lineoutnum+1
  }else if(state=="transdone" && grepl("<-",l0[lin])){
    l1[lineoutnum]=l0[lin]
    lineoutnum<-lineoutnum+1
    state="function"
    #print(state)
    #print(l0[lin])

    var2=str_extract(l0[lin], "^.+?(?= |<)")
    #  print(var2)
    # print(thisfunctionout)
    thisfunctionout<-paste0("var_",var2)
    #print(lastout)

    outhash[lastout]=thisfunctionout
    #print(thisfunctionout)
    vars1<-unname(c(outhash,newhash)[names(thisfunctionin)])
    # print(thisfunctionin)

    #print(paste0(thisfunctionout,"<-",var2,"(",vars1,")"))

    myfun<-list(n=var2,out=thisfunctionout,ins=thisfunctionin,sig=l0[lin])
   # print(myfun)
    functions[[var2]]<-myfun
    funname<-var2

    thisfunctionout<-NA
    thisfunctionin<-list()
  }else if(grepl("graphicsFile",l0[lin])){
    l1[lineoutnum]=gsub('graphicsFile',paste0('"',funname,'.png"'),l0[lin])
    lineoutnum<-lineoutnum+1
  }else if(grepl("createDataFrame",l0[lin])){
    l1[lineoutnum]=gsub('createDataFrame',"",l0[lin])
    lineoutnum<-lineoutnum+1
  }else if(grepl("orthology_table %>% SparkR::withColumnRenamed",l0[lin])){
    l1[lineoutnum]='orthology_table %>% dplyr::rename("orthology_reference" = orthology_reference_column) %>%'
    lineoutnum<-lineoutnum+1
  }else if(grepl(fixed('SparkR::withColumnRenamed\\(orthology_conversion_column, "orthology_conversion"\\) %>% SparkR::select\\("orthology_reference", "orthology_conversion"\\) -> orthology_table'),l0[lin])){
    l1[lineoutnum]='dplyr::rename("orthology_conversion" = orthology_conversion_column ) %>% dplyr::select("orthology_reference", "orthology_conversion") -> orthology_table'
    lineoutnum<-lineoutnum+1

  }else if(grepl("SparkR::`%in%`",l0[lin])){
    l1[lineoutnum]=gsub('SparkR::',"",l0[lin])
    lineoutnum<-lineoutnum+1

  }else if(grepl("SparkR::",l0[lin])){
      l1[lineoutnum]=gsub('SparkR::',"dplyr::",l0[lin])
      lineoutnum<-lineoutnum+1

  }else if(grepl("library.FoundrySparkR",l0[lin])){
    l1[lineoutnum]="library(dplyr)"
    lineoutnum<-lineoutnum+1

  }else if(grepl("output_fs\\$open",l0[lin])){
    l1[lineoutnum]=gsub('output_fs\\$open','file',l0[lin])
    lineoutnum<-lineoutnum+1
  }else if(grepl("\\$get_path",l0[lin])){
    l1[lineoutnum]=gsub('output_fs\\$get_path','file',l0[lin])
    lineoutnum<-lineoutnum+1
    #output_fs$get_path
  }else if(grepl("new.output()",l0[lin])){
    l1[lineoutnum]=paste0("# auto removed: ",l0[lin])
    lineoutnum<-lineoutnum+1
  }else if(grepl("\\$fileSystem\\(\\)",l0[lin])){
    l1[lineoutnum]=paste0("# auto removed: ",l0[lin])
    lineoutnum<-lineoutnum+1
  }else if(!grepl("install.packages|FRObjects",l0[lin])){
    l1[lineoutnum]=gsub('RFoundryObject\\(','list(value=',l0[lin])
    lineoutnum<-lineoutnum+1
  }

  #print(paste0(state,"\t",l0[lin]))

}

function_file_list[[functionoutnum]]<-l1
print(funname)
functions[[funname]]$codebody<-l1
function_file_names<-c("workbook_start_globals.R")
#print(functions)
#

print("Parsing Templates ======================================================")
for(fin in 1:length(functions)){
  #print("#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
  fun<-functions[[fin]]
  function_file_names[fin+1]<-paste0("template_function_",fun$n,".R")
  functions[[fin]]$filename<-function_file_names[fin+1]
  #print(fun$sig)
  ino=str_match(fun$sig, "(?<=\\().*?(?=\\))")
  if(nchar(ino)>0){
  ino1<-trimws(str_split(ino,",")[[1]])
  if(sum(ino1=="")>0){
  print("=====================Function parameters are invalid, missing parameter stopping===================")
    print(fun$sig)
    stop()
  }
  print(ino1)
  revins<-names(fun$ins)
  names(revins)<-unname(fun$ins)

  orevins<-revins[paste0("var_",ino1)]

  varl<-ifelse(unname(orevins)%in%names(outhash),outhash[orevins],newhash[orevins])
 # print("varl")
  #print(varl)
  ins=paste0(unname(varl), collapse = ',')
  }else{
    ins=""
    varl=list()
  }
  functions[[fin]]$bind<-paste0(fun$out,"<-",fun$n,"(",ins,")")
  functions[[fin]]$vars<-varl
  #print(functions[[fin]])


}

calcvars<-unlist(unname(newhash))
uncalcfun<-logical(length =length(functions))

numfuncs=length(uncalcfun)

seqsfunc<-c()
seqsfunc<-c(seqsfunc,"options(browser = 'FALSE')")
progress=TRUE
print("Sorting Templates ======================================================")


newR2<-file(paste0(pipeline_dir,"/run_pipeline.sh"),"w")
writeLines("set -e",con=newR2)
while(numfuncs>0 && progress){
  numfuncsstart<-numfuncs
  for(i in 1:length(functions)){
    if(uncalcfun[i]==FALSE){
    func<-functions[[i]]
  #  print(func)
    if(sum(func$vars%in%calcvars)==length(func$vars)){
     print(func$filename)

      ###
      rds_output<-paste(pipeline_dir,"/rds_output",sep = "")
      if (file.exists(rds_output)!=1) {
      dir.create(rds_output,showWarnings = FALSE)
      }
      ###

      newR<-file(paste0(pipeline_dir,"/",func$filename),"w")
      writeLines(func$codebody,con=newR)
      seqsfunc1<-c(paste0("print(\"",func$filename," #########################################################################\")"))



      writeLines(paste0("Rscript ",func$filename),con=newR2)

      seqsfunc1<-c(seqsfunc1, "library(plotly);library(ggplot2);library(jsonlite);")
      for(inrds in func$vars){

        ###
        seqsfunc1<-c(seqsfunc1, "currentdir <- getwd()")
        seqsfunc1<-c(seqsfunc1, "rds_output <- paste0(currentdir,'/rds_output')")
        seqsfunc1<-c(seqsfunc1, paste0(inrds,"<-readRDS(paste0(rds_output,\"", "/", inrds, ".rds\"))"))
        ###

        # seqsfunc1<-c(seqsfunc1, paste0(inrds,"<-readRDS(\"",rds_output, "/", inrds, ".rds\")"))

        ###
        seqsfunc1<-c(seqsfunc1, paste0(inrds,"<-as.data.frame(",inrds,")"))
        ###
      }
      #first dev.off not necessar
      seqsfunc1<-c(seqsfunc1, paste0("invisible(graphics.off())"))
      seqsfunc1<-c(seqsfunc1,func$bind)
      seqsfunc1<-c(seqsfunc1, paste0("invisible(graphics.off())"))

      # seqsfunc1<-c(seqsfunc1, paste0("saveRDS(",func$out,",\"", rds_output, "/", func$out,".rds\")"))
      seqsfunc1<-c(seqsfunc1, paste0("saveRDS(",func$out, ", paste0(rds_output,\"", "/", func$out, ".rds\"))"))

      writeLines(seqsfunc1,con=newR)
      close(newR)
      calcvars<-append(calcvars,func$out)
      uncalcfun[i]=TRUE
      numfuncs<-numfuncs-1
      print(numfuncs)
    }

  }


  }

  #print(numfuncs)
  if(numfuncs==numfuncsstart){
    print("Error topologically sorting graph, stopping")
    print("Unsatisfiable functions dependencies, check parse errors:")
    for(k in 1:length(functions)){
      if(uncalcfun[k]==FALSE){
        func<-functions[[k]]
     print(func$sig)
    print(func$vars)
    #print(sum(func$vars%in%calcvars)==length(func$vars))
    fin<-k

    #print("#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    fun<-func

    #print(fun$sig)
    ino=str_match(fun$sig, "(?<=\\().*?(?=\\))")
    print(ino)
    if(nchar(ino)>0){
      ino1<-trimws(str_split(ino,",")[[1]])
      print("split")
      print(ino1)
      print("meta names")
      print(names(fun$ins))
      revins<-names(fun$ins)
      names(revins)<-unname(fun$ins)

      orevins<-revins[paste0("var_",ino1)]

      varl<-ifelse(unname(orevins)%in%names(outhash),outhash[orevins],newhash[orevins])
       print("varl")
      print(varl)
      ins=paste0(unname(varl), collapse = ',')
    }
    #print(functions[[fin]])

      }

  }
    stop()
  }
}
#print(l1)
#print(seqsfunc)


print("write transport scripts")
newR0<-file(paste0(pipeline_dir,"/get_data.R"),"w")
#writeLines(paste0('setwd("',pipeline_dir,'")'),con=newR0)
writeLines(paste0("source(\"",package_prfix,"download_tools.R\")"),con=newR0)
writeLines("key<-Sys.getenv(\"key\")",con=newR0)

###
rds_output <- paste(pipeline_dir,"/rds_output",sep = "")
writeLines(paste0("rds_output<-\"",rds_output,"\"") ,con=newR0)
writeLines("if (file.exists(rds_output)!=1) {",con=newR0)
writeLines("dir.create(rds_output,showWarnings = FALSE)}",con=newR0)
###


for(nh in names(newhash)){
  print(nh)
  writeLines(paste0("rid=\"",nh,"\""),con=newR0)
  branch1="master"
  if(sum(grepl(nh,py0))!=0){
    branch1=branch
  }
  writeLines(paste0("branch=\"",branch1,"\""),con=newR0)
  get_data<-paste0(newhash[nh],"files","<-pullnidap_raw(key=key,rid=rid,branch=branch)")
  writeLines(get_data,con=newR0)
  get_data<-paste0(newhash[nh],"<-figure_out_nidap_files(",newhash[nh],"files",")")
  writeLines(get_data,con=newR0)

  get_data<-paste0("saveRDS(",newhash[nh],",\"",rds_output,"/", newhash[nh],".rds\"",")")
  writeLines(get_data,con=newR0)

  #var_H5_test_saved<-readRDS("var_H5_test.rds")
}

close(newR0)


writeLines('source("workbook_start_globals.R")',con=newR2)


close(newR2)
print("Writing verification file -------------------------------------------------")
###############################
print("write verification scripts")
newR3<-file(paste0(pipeline_dir,"/verify_data.R"),"w")
#writeLines(paste0('setwd("',pipeline_dir,'")'),con=newR3)
writeLines(paste0("source(\"",package_prfix,"download_tools.R\")"),con=newR3)
writeLines("key<-Sys.getenv(\"key\")",con=newR3)
writeLines("report<-list()",con=newR3)
###
writeLines("currentdir <- getwd()",con=newR3)
writeLines("rds_output <- paste0(currentdir,\"/rds_output\")",con=newR3)
###


for(nh in names(outhash)){
  print(nh)
  writeLines(paste0("rid=\"",nh,"\""),con=newR3)

  branch1=branch
  get_data<-paste0("report[\"",outhash[nh],"\"]<-'no comparison'")
  writeLines(get_data,con=newR3)
  get_data<-paste0("try({")
  writeLines(get_data,con=newR3)
  writeLines(paste0("branch=\"",branch1,"\""),con=newR3)
  get_data<-paste0(outhash[nh],"files","<-pullnidap_raw(key=key,rid=rid,branch=branch)")
  writeLines(get_data,con=newR3)
  get_data<-paste0(outhash[nh],"_target","<-figure_out_nidap_files(",outhash[nh],"files",")")
  writeLines(get_data,con=newR3)


  get_data<-paste0(outhash[nh],"_new","<-readRDS(paste0(rds_output,\"","/",outhash[nh],".rds\"","))")
  writeLines(get_data,con=newR3)
  get_data<-paste0("report[\"",outhash[nh],"\"]<-report_differences(",outhash[nh],"_target,",outhash[nh],"_new)")
  writeLines(get_data,con=newR3)
  get_data<-paste0('},silent=TRUE)')
  writeLines(get_data,con=newR3)
  get_data<-paste0("print(report[\"",outhash[nh],"\"])")
  writeLines(get_data,con=newR3)
  writeLines("###################################",con=newR3)

  #var_H5_test_saved<-readRDS("var_H5_test.rds")
}
close(newR3)
}
