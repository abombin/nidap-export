# NIDAP Exporter

The NIDAP Exporter is the collection of NIDAP utilities tools to provide add-on functions. 
Currently this tools collection contains:
  ### 1. R3_to_Docker: This tool set provides the neccesary tools to generate a GitHub repository containing exported NIDAP R code workbook for public access.
    Conceptual diagram for the process:
    ![R3 to Docker Process Illustration](https://raw.githubusercontent.com/FNLCR-DMAP/nidap-export/e8b7f5a135bab9197bc51d8ed5b69b8567a9d3cc/nidap_exporter/R3_to_Docker/R3_to_Docker_Process_Illustration.png)
  
  ### 2. R3_to_Docker_unit_tests: This tool is for unit testing the transformation R script for parsing exported NIDAP code workbook.
  
  ### 3. Get_Workbook_Images: This tool provides the script to download all images from the specific branch from a code workbook on NIDAP. This code does not support downloading from code workbook containing HTML images such as plotly images. 
