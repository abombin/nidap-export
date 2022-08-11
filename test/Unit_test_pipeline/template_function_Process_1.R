Process_1 <- function(Dataset_2, Dataset_1) {
    print("Topological order: 1")
    print("Save as dataset")

    
    nodal_name <- "topo_order_1"
    x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    plot(x,y)
    png(filename=paste0(nodal_name,"_output.png"))
    dev.off()

    return(Dataset_1)    
}

print("template_function_Process_1.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Dataset_2<-readRDS(paste0(rds_output,"/var_Dataset_2.rds"))
var_Dataset_2<-as.data.frame(var_Dataset_2)
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Dataset_1<-readRDS(paste0(rds_output,"/var_Dataset_1.rds"))
var_Dataset_1<-as.data.frame(var_Dataset_1)
invisible(graphics.off())
var_Process_1<-Process_1(var_Dataset_2,var_Dataset_1)
invisible(graphics.off())
saveRDS(var_Process_1, paste0(rds_output,"/var_Process_1.rds"))
