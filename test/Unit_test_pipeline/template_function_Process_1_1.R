Process_1_1 <- function(Dataset_1) {
    print("Topological order: 1.1")
    print("Save as dataset")

    
    print('sample_metadata <-') # Test string 1
    print('"Process_1_1.png"') # Test string 2
    print('') # Test string 3
    print('orthology_table %>% dplyr::rename("orthology_reference" = orthology_reference_column) %>%') # Test string 4
    print('"dplyr::withColumnRenamed\\(orthology_conversion_column, "orthology_conversion"\\) %>% dplyr::select\\("orthology_reference", "orthology_conversion"\\) -> orthology_table"') # Test string 5
    print('`%in%`') # Test string 6
    print('dplyr::') # Test string 7
library(dplyr)
    print('output_fs\\$open') # Test string 9
    print('\\$get_path') # Test string 10
# auto removed:     print('new.output()') # Test string 11
    print('$fileSystem\\') # Test string 12
    

    return(Dataset_1)    
}

print("template_function_Process_1_1.R #########################################################################")
library(plotly);library(ggplot2);library(jsonlite);
currentdir <- getwd()
rds_output <- paste0(currentdir,'/rds_output')
var_Dataset_1<-readRDS(paste0(rds_output,"/var_Dataset_1.rds"))
var_Dataset_1<-as.data.frame(var_Dataset_1)
invisible(graphics.off())
var_Process_1_1<-Process_1_1(var_Dataset_1)
invisible(graphics.off())
saveRDS(var_Process_1_1, paste0(rds_output,"/var_Process_1_1.rds"))
