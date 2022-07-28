This repo is for updated refactored RSK transform code.
Details of the refactoring process can be found on:

https://tracker.nci.nih.gov/browse/DSP-17

########################################################################
The NIDAP transfer scripts consist of three core scripts:

1. transform.R contains the function to parse the exported NIDAP pipeline. It is the core of the transform-pipeline.R, which is the very first script to be run in the R3 SOP.

2. download_tools.R contains functions to request dataset from NIDAP using personal NIDAP token and dataset rid and format acquired dataset into rds,

3. upload_tools.R contains functions to upload results onto NIDAP

########################################################################
INSTRUCTIONS:

The standard operating procedure (SOP) for NIDAP R3 process can be found on:
https://tracker.nci.nih.gov/projects/DSP/issues/DSP-1?filter=allissues

In short, the user is expected to:
1. Run the transform_pipeline.R first. This script run will automatically parse the pipeline exported from NIDAP and generate three utility scripts:
    1). "get_data.R" to download datasets;
    2). "verify_data.R" to compare the off-platform results and the results from NIDAP run;
    3). "run_pipeline.sh", which is a bash script to run the parsed pipeline following in a topological sorted manner.  

2. Run the get_data.R. This script will download the dataset(s) used in NIDAP codebook and store the dataset(s) in "nidap_downloads" folder. The dataset used in pipeline run will be stored as .rds format in "rds_output" folder.

3. Run the run_pipeline.sh in the ***DOCKER image built to run the codebook***. The rds output during the run will be stored in "rds_output" folder.

4. OPTIONAL. Run the verify_data.R in Rstudio or the IDE you are using to compare the pipeline results (rds outputs). The report will be present as "Report" in environment. 
