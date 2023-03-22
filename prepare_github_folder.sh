#!/bin/bash

echo "WARNING: THIS METHOD IS INTENDED TO BE USED IN A BLANK GITHUB REPO"
echo "WARNING: IT MAY OVERWRITE ORIGINAL CONTENTS IN THE REPO "


# Parse command-line arguments
while getopts "github:rds:pipeline:docker:" opt; do
  case $opt in
    github) github_repo="$OPTARG";;
    rds) rds="$OPTARG";;
    pipeline) pipeline="$OPTARG";;
    docker) docker="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
    :) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
  esac
done

# Check if required input argument is present
if [ -z "$github_repo" ] || [ -z "$rds" ] || [ -z "$pipeline" ]|| [ -z "$docker" ]; then
  echo "Missing required input argument, should have github, rds, pipeline, docker" >&2
  exit 1
fi


hour=$(date '+%H')
day=$(date '+%d')
month=$(date '+%m')
year=$(date '+%Y')

echo "Preparing source git repo from GitHub: "
echo "$github_repo"

file_dir="$(dirname "$(readlink -f "$0")")"

echo "Changing workind directory to one level up."
cd $file_dir/../

echo "Cloning target GitHub repo"

logfile="github_creation_log_$year$month$day$hour.log"

echo $(git clone $github_repo) > $logfile

github_foler="$(grep -o "'[^']*'" $logfile)"

rm $logfile

cd ./$github_foler

echo "Copying the template folder to the GitHub repo"
cp $file_dir/github_template/* .

echo "Copying the template-R function and run-pipeline.sh into src folder:"
cp $file_dir/../$pipeline/template_*.R ./src

if [ "$rds" = "Yes" ]; then
  echo "rds option is set to Yes, copying rds_output folder to the github repo"
  echo "WARNING: PLEASE REMOVE RDS FILES THAT ARE GENERATED FROM THE PIPELINE RUN"
  echo "WARNING: PLEASE MAKE SURE YOU WANT TO SHARE THE DATA ON GITHUB"
  cp -R $file_dir/../$pipeline/rds_output ./src
else
  echo "RDS is not set to Yes, not including the rds outputs in the github repo"
  mkdir ./src/rds_output
  echo "This file is for maintaining folder structure." > ./src/rds_output/.githold 
fi

echo "Copying the Dockerfile to the GitHub repo:"
cp -R $file_dir/../$docker/* ./Docker_file


echo "Committing the changes"
git add --all
git commit -a -m "Update the GitHub Folder"

