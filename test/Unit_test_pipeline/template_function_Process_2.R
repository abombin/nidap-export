Process_2 <- function(Process_1) {
    print("Topological order: 2")

    return(Process_1)    
}

print("template_function_Process_2.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Process_1<-readRDS(paste0(rds_output,"/var_Process_1.rds"))
var_Process_1<-as.data.frame(var_Process_1)
invisible(graphics.off())
var_Process_2<-Process_2(var_Process_1)
invisible(graphics.off())
saveRDS(var_Process_2, paste0(rds_output,"/var_Process_2.rds"))
