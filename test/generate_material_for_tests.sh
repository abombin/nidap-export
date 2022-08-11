# General run before test
echo "Stop and remove previous unit_test_docker container"
docker container stop unit_test_docker
docker rm unit_test_docker


echo "###############################################################"
echo "###############################################################"
echo "###############################################################"
echo "Start copntainer unit_test_docker from image unit_test"
docker run -d --name unit_test_docker --publish-all -ti -v $(pwd):/tmp unit_test bash

echo "Check current running container"
docker container ls

echo "Start a bash session in the unit_test_docker containder"
docker exec unit_test_docker bash

echo "###############################################################"
echo "###############################################################"
echo "###############################################################"
echo "Run transform-pipeline.R in the unit_test_docker containder"
docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/; Rscript ./transform-pipeline.R'

echo "###############################################################"
echo "Create and change folder permission for nidap_downloads folder"
docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test; mkdir nidap_downloads; chmod g+rws nidap_downloads/; chmod o-r-x nidap_downloads/'
echo "Change folder permission for pipeline folder"
docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test; chmod ug+rws Unit_test_pipeline/; chmod o-r-x Unit_test_pipeline/'
#echo "Change file permission for pipelines in folder"
#docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test/Unit_test_pipeline/; find * -type f -exec chmod ugo+rw {} \;'
echo "Change folder permission for rds_output folder"
docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test/Unit_test_pipeline/; chmod g+rws rds_output/; chmod o-r-x rds_output/'




# echo "###############################################################"
echo "Run get_data.R top acquire data"
cd ./test
Rscript ./Unit_test_pipeline/get_data.R
# docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test; Rscript ./Unit_test_pipeline/get_data.R'

echo "###############################################################"
echo "Run pipeline in the unit_test_docker containder"
docker exec -ti unit_test_docker /bin/bash -c 'cd ~/../tmp/test/Unit_test_pipeline; bash run_pipeline.sh'


echo "###############################################################"
docker container stop unit_test_docker
docker rm unit_test_docker

echo "Check current running container"
docker container ls

