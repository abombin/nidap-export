Process_3 <- function(Process_2) {
    print("Topological order: 3")

    
    return(Process_2)    
}

print("template_function_Process_3.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Process_2<-readRDS(paste0(rds_output,"/var_Process_2.rds"))
var_Process_2<-as.data.frame(var_Process_2)
invisible(graphics.off())
var_Process_3<-Process_3(var_Process_2)
invisible(graphics.off())
saveRDS(var_Process_3, paste0(rds_output,"/var_Process_3.rds"))
