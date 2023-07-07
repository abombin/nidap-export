source("./Get_visualization_image_functions.R")

library("httr")
library("RCurl")

token <- Sys.getenv("key")

workbook_rid <- "ri.vector.main.workbook.380753ec-334c-4282-b6f1-27dd16d3f0fa"
branch <- "Scott_test"
image_prefix <- "test_output_"
output_direction <- "./test/"


logic_nodes_id_list <- NIDAP_get_logic_node_id_list(workbook_rid, branch, token)

formated_nodeID_request_body <- NIDAP_format_nodeID_request_body(logic_nodes_id_list)

logic_node_name_list <- NIDAP_get_logic_node_name_list(workbook_rid, 
                               branch, 
                               logic_nodes_id_list,
                               token)

visualization_image_response <- NIDAP_get_visualization_images(workbook_rid, 
                                                               branch, 
                                                               formated_nodeID_request_body, 
                                                               token) 



NIDAP_export_visualization_images(image_prefix,
                                  output_direction,
                                  logic_node_name_list,
                                  visualization_image_response)
