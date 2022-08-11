Process_4 <- function(Process_3) {
    print("Topological order: 4")
    print("Save as dataset")

    nodal_name <- "topo_order_4"
    x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    y <- x * 3
    plot(x,y)
    png(filename=paste0(nodal_name,"_output.png"))
    dev.off()
    return(Process_3)    
}

print("template_function_Process_4.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Process_3<-readRDS(paste0(rds_output,"/var_Process_3.rds"))
var_Process_3<-as.data.frame(var_Process_3)
invisible(graphics.off())
var_Process_4<-Process_4(var_Process_3)
invisible(graphics.off())
saveRDS(var_Process_4, paste0(rds_output,"/var_Process_4.rds"))
