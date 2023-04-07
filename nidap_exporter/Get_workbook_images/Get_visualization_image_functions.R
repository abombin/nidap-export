# Functions

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

getRidFromPath <- function(key, file_path_on_NIDAP){
  callurl <- paste0("https://nidap.nih.gov/compass/api/resources?path=", file_path_on_NIDAP)
  rma <- GET(url = callurl, 
             add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  cont <- content(rma, "text")
  cont
  return(con$rid)
}

getBranchFromRID <- function(key, workbook_RID){
  callurl <- paste0("https://nidap.nih.gov/vector/api/workbooks/", workbook_RID, "/branches")
  rma <- GET(url = callurl, 
             add_headers(Authorization = paste("Bearer", key, sep = " ")))
  con <- content(rma, "parsed")
  cont <- content(rma, "text")
  cont
  return(con)
}

palantir_upload_png_image <- function(image_name, image_location, target_folder_rid, token) {
  
  base_url <- 'https://nidap.nih.gov/blobster/api/salt?filename='
  url <- paste(base_url, image_name, "&parent=", target_folder_rid, sep="")
  
  auth_header <- paste("Bearer", token, sep=" ")
  headers = c("Content-Type"="image/png","Authorization"=auth_header)
  body=upload_file(image_location)
  
  response <- POST(url,
                   body=body,
                   add_headers(.headers=headers))
  
  response <- content(response, "parsed")
  
  return(response)
}

NIDAP_get_visualization_images <- function(workbook_rid, 
                                           branch, 
                                           formated_nodeID_request_body, 
                                           token) {
  
  base_url <- 'https://nidap.nih.gov/vector/api/workbooks/'
  url <- paste0(base_url, workbook_rid, 
                "/branches/", branch,
                "/logicNodes/buildOutputs-batchGet")
  
  auth_header <- paste("Bearer", token, sep=" ")
  headers = c("Content-Type"="application/json","Authorization"=auth_header)
  body=formated_nodeID_request_body
  response <- POST(url,
                   body=body,
                   add_headers(.headers=headers))
  
  response <- content(response, "parsed")
  
  return(response)
}

NIDAP_get_logic_node_id_list <- function(workbook_rid, branch, token) {
  
  base_url <- 'https://nidap.nih.gov/vector/api/workbooks/'
  url <- paste0(base_url, workbook_rid, 
                "/branches/", branch,
                "/logicNodes-batchGet")
  
  auth_header <- paste("Bearer", token, sep=" ")
  headers = c("Content-Type"="application/json","Authorization"=auth_header)
  requestbody <- '{}'
  
  response <- POST(url,
                   body=requestbody,
                   add_headers(.headers=headers))
  
  response <- content(response, "parsed")

  Logic_node_response <- response$nodes
  
  node_id_list <- c()
  for (node in Logic_node_response) {
    node_id_list <- append(node_id_list, node$id)
  }
  
  
  return(node_id_list)
}


NIDAP_api_create_folder <- function(parent_path, foldername, key){  
  url <- paste0("https://nidap.nih.gov/compass/api/paths/", parent_path, "/", foldername)        
  server_response <- PUT(url = url, 
                         add_headers(Authorization = paste("Bearer", key, sep = " ")))
  server_response <- content(server_response, "parsed")
  return(server_response$rid)
}

NIDAP_format_nodeID_request_body <- function(list_of_logic_node_id){
  request_string <- '{"includeFoundryPreviews":true,"logicNodeIds":["'
  for (id in list_of_logic_node_id){
    if (id != "NULL"){
      request_string<-paste0(request_string, id,'","')
    }
  }
  request_string <- paste0(request_string, id,'"]}')
  return(request_string)
}


NIDAP_export_visualization_images <- function(image_prefix,
                                              output_directory,
                                              logic_node_name_list,
                                              visualization_image_response){
  dir.create(output_directory)
  
  output_list <- visualization_image_response$responses

  image_dir <- paste0(output_directory, image_prefix)
  
  counter <- 1
  for (item in output_list){
    
    logic_id <- names(output_list[counter])
    
    name_loc <- which(sapply(logic_node_name_list, 
                                    function(x) logic_id %in% x))
    
    name <- logic_node_name_list[name_loc - 1]
    
    unredacted <- item$unredacted
    logic_node_output <- unredacted$logicNodeOutput
    visualization_output <- logic_node_output$visualizations
    visualization_Results <- visualization_output$visualizations
    
    if (length(visualization_Results) != 0){
      visualization_file <- unlist(visualization_Results[1][1])
      
      if (visualization_file[1] == "base64Png"){
        inconn <- unlist(visualization_Results[1][1])[2]
        
        filename <- paste0(image_dir, name, ".png")

        outconn <- file(filename,"wb")
        base64decode(what=inconn, output=outconn)
        close(outconn)
        }
    }
    counter <- counter + 1
  }
  print("Output finished.")
  }



NIDAP_get_logic_node_name_list <- function(workbook_rid, 
                                           branch, 
                                           logic_nodes_id_list,
                                           token) {
  # Get display nade info
  base_url <- 'https://nidap.nih.gov/vector/api/workbooks/'
  url <- paste0(base_url, workbook_rid, 
                "/branches/", branch,
                "/displayNodes-batchGet")
  
  auth_header <- paste("Bearer", token, sep=" ")
  headers = c("Content-Type"="application/json","Authorization"=auth_header)
  requestbody <- '{}'
  
  response <- POST(url,
                   body=requestbody,
                   add_headers(.headers=headers))
  
  response <- content(response, "parsed")
  
  display_node_response <- response$displayNodes
  
  
  # Get datanode info
  base_url <- 'https://nidap.nih.gov/vector/api/workbooks/'
  url <- paste0(base_url, workbook_rid, 
                "/branches/", branch,
                "/dataNodes-batchGet")
  
  auth_header <- paste("Bearer", token, sep=" ")
  headers = c("Content-Type"="application/json","Authorization"=auth_header)
  requestbody <- '{}'
  
  response <- POST(url,
                   body=requestbody,
                   add_headers(.headers=headers))
  
  response <- content(response, "parsed")
  
  data_node_response <- response$nodes
  
  # Create matching list between logic and data node
  
  node_id_match_list <- c()
  for (node in display_node_response) {
    display_spec <- node$displaySpec
    collapsed <- display_spec$collapsed
    logicNode <- collapsed$logicNode
    logicNode_id <- logicNode$logicNodeId
    
    dataNode <- collapsed$dataNode
    dataNode_id <- dataNode$dataNodeId
    
    add_row <- c(logicNode_id, dataNode_id)
    
    node_id_match_list <- append(node_id_match_list, add_row)
  }
  
  
  # Create matching list between name and data node id
  
  node_name_match_list <- c()
  
  
  for (node in data_node_response) {
    nodename <- node$alias
    nodeid <- node$id
    
    add_row <- c(nodename, nodeid)
    
    node_name_match_list <- append(node_name_match_list, add_row)
  }
  
  # Get matching names
  
  output_name_list <- c()
  
  for (i in 1 : length(logic_nodes_id_list) ){
    dataNode_id_loc <- which(sapply(node_id_match_list, 
                                    function(x) logic_nodes_id_list[i] %in% x)) 
    dataNode_id <- node_id_match_list[dataNode_id_loc+1]
    
    node_name_match_list_loc <- which(sapply(node_name_match_list, 
                                             function(x) dataNode_id %in% x)) 
    
    node_name <- node_name_match_list[node_name_match_list_loc-1]
    
    out_row <- c(node_name, logic_nodes_id_list[i])
    
    output_name_list <- append(output_name_list, out_row)
  }
  
  return(output_name_list)
}


