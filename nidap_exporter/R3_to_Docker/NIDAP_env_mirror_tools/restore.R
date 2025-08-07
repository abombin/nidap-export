

libraries_file="/rstudio-files/ccbr-data/RSK/migration2/library_names.txt"

y <- read.table(libraries_file,stringsAsFactors = FALSE)[[1]]
y2=y

if(file.exists("failed_packages.txt")){
  ml=readLines("failed_packages.txt")
  file.copy("failed_packages.txt",paste0("failed_packages.txt", Sys.Date(), ".log"))
}else{
  ml=c()
}
el=c()
done=FALSE
packs_f <- file("failed_packages.txt","w")
writeLines(ml,con=packs_f,sep="\n")
packs_log <- file(paste0("error_", Sys.Date(), ".log"),"w")

while(!done){


x <- tryCatch(
  {
    ny=y[!y%in%ml]
    renv::restore(packages=ny,confirm=FALSE,clean=TRUE)
    done<<-TRUE
  },
  error = function(e){
    el=c(el,e$message)
    print(e)
    writeLines(e$message,con=packs_log,sep="\n-------rsk-----\n")
    pml=gsub(".*'(.*)'.*", "\\1", e$message)
    
   
    writeLines(pml,con=packs_f,sep="\n")
    if(pml %in% ml){
      print("repeated package break loop")
      close(packs_f)
      close(packs_log)
      done<<-TRUE
    }
    ml<<- c(ml, pml)
    print(ml)
    
  }
)

}
close(packs_f)
close(packs_log)



