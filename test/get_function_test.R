library(RCurl)
library(httr)
library(arrow)
library(dplyr)

key<-Sys.getenv("key")
print(key)
rds_output<-"./Unit_test_pipeline/rds_output"
branch <- "master"
url = "https://nidap.nih.gov/"
dataproxy = "foundry-data-proxy/api/dataproxy/datasets/"
catalog = "foundry-catalog/api/catalog/datasets/"
rid="ri.foundry.main.dataset.d6d40105-1dd4-417f-9066-6896b55fb3d2"
callurl <- paste0(url, catalog, rid, 
                  '/views2/', branch, '/files?pageSize=100')
rm <- GET(url = callurl, 
          add_headers(Authorization = paste("Bearer", key, sep = " ")), 
          verify = FALSE, content_type_json())
cont <- content(rm, "text")
print(cont)