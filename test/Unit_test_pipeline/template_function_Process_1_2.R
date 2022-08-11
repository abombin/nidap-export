Process_1_2 <- function(Dataset_1) {
    print("Topological order: 1.2")

    nodal_name <- "topo_order_1_2"
    x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    plot(x,y)
    png(filename=paste0(nodal_name,"_output.png"))
    dev.off()

    return(Dataset_1)    
}

print("template_function_Process_1_2.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Dataset_1<-readRDS(paste0(rds_output,"/var_Dataset_1.rds"))
var_Dataset_1<-as.data.frame(var_Dataset_1)
invisible(graphics.off())
var_Process_1_2<-Process_1_2(var_Dataset_1)
invisible(graphics.off())
saveRDS(var_Process_1_2, paste0(rds_output,"/var_Process_1_2.rds"))
