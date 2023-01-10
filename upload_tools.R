# Dev Note
# The upload_tools.R was developed by Robin, 
# Further development and refactoring was by Rui
# Current directory is 
# /rstudio-files/ccbr-data/git-repos/nidap-export
# This is the refactored version, original file can be found in 
# /rstudio-files/ccbr-data/RSK/nidap_transfer_scripts2/


# Library
library(RCurl)
library(httr)
library(jsonlite)

# Create_folder is the function to generate a folder on nidap
create_folder <- function(path, pathname, key){
  
  callurl <- paste0("https://nidap.nih.gov/compass/api/paths/", path, "/", pathname)
  
  rma <- PUT(url = callurl, 
           add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  cont <- content(rma, "text")
  cont
  return(con$rid)
}

# Upload_project is the function to upload the dataset from local onto NIDAP
upload_project <- function(upload_file_name, datasetname, folder_path_on_NIDAP, key){

  # Services address on NIDAP
  url = "https://nidap.nih.gov/"
  dataproxy = "foundry-data-proxy/api/dataproxy/datasets/"
  catalog = "foundry-catalog/api/catalog/datasets/"

  # Get address to the catalog service
  callurlcreate <- paste0(url , "foundry-catalog/api/catalog/datasets")
  rmc <- POST(url = callurlcreate, 
                add_headers(Authorization = paste("Bearer", key, sep = " ")), 
                verify = FALSE, 
                content_type_json(), 
                body = list(path = paste0(folder_path_on_NIDAP, "/", datasetname)), 
                encode = "json")
  rmcc <- content(rmc, "parsed")

  # Create Branch
  callurlcreatebranch <- paste0(url , 
                            "foundry-catalog/api/catalog/datasets/", 
                            rmcc$rid, 
                            "/branchesUnrestricted2/master")
  rmcb <- POST(url = callurlcreatebranch, 
              add_headers(Authorization = paste("Bearer", key, sep = " ")), 
              verify = FALSE, 
              content_type_json(), 
              body = '{}', 
              encode = "raw")
  rmccb <- content(rmcb, "parsed")

  # Create Transaction
  callurl <- paste0(url , catalog , rmcc$rid , '/transactions')
  rm <- POST(url = callurl, 
            add_headers(Authorization = paste("Bearer", key, sep = " ")), 
            verify = FALSE, 
            content_type_json(), 
            body = list(branchId = "master"), 
            encode = "json")
  con <- content(rm, "parsed")
  cont <- content(rm, "text")

  #Upload File
  trid <- con$rid
  print(trid)
  brid <- con$datasetRid
  file_url = paste0(url, dataproxy, brid, 
                    "/transactions/", trid, 
                    "/putFile?logicalPath=", 
                    upload_file_name)
  resp2 = POST(url = file_url, 
               add_headers(Authorization = paste("Bearer", key, sep = " ")), 
               body = upload_file(upload_file_name))

  print(resp2)

 # Commit transaction
  callurlabort <- paste0(url , catalog , brid , '/transactions/', trid, '/commit')
  rma <- POST(url = callurlabort, 
              add_headers(Authorization = paste("Bearer", key, sep = " ")), 
              verify = FALSE, 
              content_type_json(), 
              body = '{}', 
              encode = "raw")
  rma
 return(brid)
}

# getDestinations is the function to get the location of the phonograph2 dataset from NIDAP
getDestinations <- function(key, phonograph2tableRID){
 # Create Transaction
  callurl <- "https://nidap.nih.gov/phonograph2/api/search/tables"
  requestbody <- paste0('{
  "tableRids": [', 
  tableRID, 
  '], 
  "filter": {
   "type": "matchAll", 
   "matchAll": {}
  }, 
  "aggregations": {}
 }')
  rm <- POST(url = callurl, add_headers(Authorization = paste("Bearer", key, sep = " ")), verify = FALSE, 
  content_type_json(), body = requestbody, encode = "json")
  con <- content(rm, "parsed")
  cont <- content(rm, "text")
  return(fromJSON(cont)$hits[, 3][, 2])
}

# getRidFromPath is used to get RID of a existing NIDAP file
getRidFromPath <- function(key, file_path_on_NIDAP){
  callurl <- paste0("https://nidap.nih.gov/compass/api/resources?path=", file_path_on_NIDAP)
  rma <- GET(url = callurl, 
          add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  cont <- content(rma, "text")
  cont
  return(con$rid)
}

# getNameFromRid is used to get name of the rid
getNameFromRid <- function(key, RID){
  callurl <- paste0("https://nidap.nih.gov/compass/api/resources/", 
                RID, 
                "/path-json")
  rma <- GET(url = callurl, 
             add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  result <- sub('.*\\/', '', con)
  cont <- content(rma, "text")
  cont
  return(result)
}

# getPathFromRid is used to get path of the rid
getPathFromRid <- function(key, RID){
  callurl <- paste0("https://nidap.nih.gov/compass/api/resources/", 
                    RID, 
                    "/path-json")
  rma <- GET(url = callurl, 
             add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  result <- sub('.*\\/', '', con)
  cont <- content(rma, "text")
  cont
  return(con)
}

# createWorkBook adds dataset as nodes in an existing NIDAP workbook
createWorkBook <- function(key, 
                           list_of_dataset_rids, 
                           folder_path, 
                           workbook_name,
                           branch){
  
  # Get rid of the workbook
  path_rid <- getRidFromPath(key, folder_path)
  
  #Get workbook rid
  workbook_path <- paste0(folder_path, "/", workbook_name)
  print(workbook_path)
  workbook_rid <- getRidFromPath(key, workbook_path)
  print(workbook_rid)
  
  # Locate the add node service
  callurl = paste0( "https://nidap.nih.gov/vector/api/workbooks/", 
                    workbook_rid, 
                    "/branches/",branch,"/logicNodes-batchCreate")
  
  # Position of datasets
  start_x_posision <- 200
  x_position_step <- 20
  start_y_posision <- 300
  y_position_step <- 60
  step_count <- 0
  # Loop through the list of datasets to post nodes into targeted workbook
  for(dataset_rids in list_of_dataset_rids){
    current_x_position <- start_x_posision + x_position_step * step_count
    current_y_position <- start_y_posision + y_position_step * step_count
    step_count <- step_count + 1
    dataset_alias <- getNameFromRid(key, dataset_rids)
    dataset_alias <- sub(" ", "_", dataset_alias)
    requestbody = paste0('{
    "requests": [
     {
      "displayOptions": {
       "dimensions": {
        "height": 200, 
        "width": 300
       }, 
       "position": {
        "left": ', current_x_position, ', 
        "top": ', current_y_position, '
       }, 
       "viewMode": "DATA_PREVIEW"
      }, 
      "inputs": [], 
      "outputAlias": "', dataset_alias,'",
      "spec": {
       "importedDataset": {
        "datasetRid": "', dataset_rids, '"
       }, 
       "type": "importedDataset"
      }
     }
    ]
   }')

    response_from_NIDAP <- POST(url = callurl, 
              add_headers(Authorization = paste("Bearer", key, sep = " ")), 
              verify = FALSE, 
              content_type_json(), 
              body = requestbody, 
              encode = "json")
    response_content_table <- content(response_from_NIDAP, "parsed")
    response_content_text <- content(response_from_NIDAP, "text")
    
    # Report status of action
    if(is.null(response_content_table$errorCode)){
      print(paste0("Success imported: ", dataset_alias))
      }else{
      print(paste0("Fail to imported: ", dataset_alias, 
                   "\n", response_content_table$errorCode))
      }
  }
  
 return(response_content_table$workbook$rid)
}


