# NIDAP 2 SBG package
The [NIDAP2SBG](https://github.com/fnlcr-bids-sdsi/nidap-export/tree/main/) package is a 2-step tool for:
1. Exporting a [NIDAP](https://nidap.nih.gov) (based in [Palantir](https://www.palantir.com)) transform code
2. Import the pipeline to [Seven Bridges Genomics](http://cgc.sbgenomics.com) ([CGC](https://www.cancergenomicscloud.org))

## 1 - NIDAP Exporter
The [NIDAP Exporter](https://github.com/fnlcr-bids-sdsi/nidap-export/tree/main/nidap_exporter) can automatically:
1. Download complete workbooks, its transform codes and datasets from NIDAP
2. Creates the step-by-step pipeline from the workbook, by parsing and recreating all of the transform steps in local scripts
3. Prepare the docker file to be able to run the scripts in a container
4. Prepare it for a publication - in a form of a github project

## 2 - SBG Importer
The [SBG Importer](https://github.com/fnlcr-bids-sdsi/nidap-export/tree/main/sbg_importer) receives the output from the [NIDAP Exporter](https://github.com/fnlcr-bids-sdsi/nidap-export/tree/main/nidap_exporter), and:
1. Build the docker image and deploy it to the SBG docker registry
2. Based on the inputs from NIDAP Exporter, recreate the scripts to be able to be run using parameters by CWL calls
3. Recreate the topological graph with the CWL pipeline that runs this workflow
4. Upload this CWL pipeline and the whole project structure to SBG.