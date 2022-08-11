Process_3_1 <- function(Process_2) {
    print("Topological order: 3.1")
    print("Save as dataset")

    nodal_name <- "topo_order_3_1"
    x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    y <- x * 2
    plot(x,y)
    png(filename=paste0(nodal_name,"_output.png"))
    dev.off()
    return(Process_2)    
}

print("template_function_Process_3_1.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Process_2<-readRDS(paste0(rds_output,"/var_Process_2.rds"))
var_Process_2<-as.data.frame(var_Process_2)
invisible(graphics.off())
var_Process_3_1<-Process_3_1(var_Process_2)
invisible(graphics.off())
saveRDS(var_Process_3_1, paste0(rds_output,"/var_Process_3_1.rds"))
