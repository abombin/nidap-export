#!/bin/bash

set -e

echo "WARNING: THIS METHOD IS INTENDED TO BE USED IN A BLANK GITHUB REPO"
echo "WARNING: IT MAY OVERWRITE ORIGINAL CONTENTS IN THE REPO "

echo "Log for updating GitHub repo\n" > github_repo_udpate_log.log
exec >> github_repo_udpate_log.log
# Parse command-line arguments
while getopts "g:r:p:d:" opt; do
  case "${opt}" in
    g) github_repo="$OPTARG";;
    r) rds="$OPTARG";;
    p) pipeline="$OPTARG";;
    d) docker="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
    :) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
  esac
done

echo "github_repo=$github_repo"
echo "rds=$rds"
echo "pipeline=$pipeline"
echo "docker=$docker\n"

# Check if required input argument is present
if [ -z "${github_repo}" ] || [ -z "${rds}" ] || [ -z "${pipeline}" ] || [ -z "${docker}" ]; then
  echo "Missing required input argument, should have github, rds, pipeline, docker" >&2
  exit 1
fi

hour=$(date '+%H')
day=$(date '+%d')
month=$(date '+%m')
year=$(date '+%Y')

echo "\nPreparing source git repo from GitHub: \n"
echo "$github_repo"

file_dir="$(dirname "$(readlink -f "$0")")"

# echo "\nChanging workind directory to one level up.\n"
# cd $file_dir/../

echo "\nCloning target GitHub repo\n"

logfile="github_creation_log_$year$month$day$hour.log"

echo $(git clone $github_repo) > $logfile

github_foler="$(grep -o "'[^']*'" $logfile)"
github_foler=$(echo $github_foler | tr -d "'")
rm $logfile

echo "\nGitHub Folder is: $github_foler\n"

cd ./$github_foler

echo "\nCopying the template folder to the GitHub repo\n"
cp -R $file_dir/github_template/* .

echo "\nCopying the template-R function and run-pipeline.sh into src folder:\n"
cp $pipeline/template_*.R ./src

if [ "$rds" = "Yes" ]; then
  echo "rds option is set to Yes, copying rds_output folder to the github repo"
  echo "WARNING: PLEASE REMOVE RDS FILES THAT ARE GENERATED FROM THE PIPELINE RUN"
  echo "WARNING: PLEASE MAKE SURE YOU WANT TO SHARE THE DATA ON GITHUB"
  cp -R $pipeline/rds_output ./src
else
  echo "\nRDS is not set to Yes, not including the rds outputs in the github repo\n"
  mkdir ./src/rds_output
  echo "\nThis file is for maintaining folder structure.\n" > ./src/rds_output/.githold 
fi

echo "\nCopying the Dockerfile to the GitHub repo:\n"
cp -R $docker/* ./Docker_file


echo "\nCommitting the changes\n"
git add --all
git commit -a -m "Update the GitHub Folder"

