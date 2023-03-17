#!/bin/python
import json
import yaml
import argparse 
import sys
import os


def create_conda_yml_file(args):
    "Parse the exported files from NIDAP and generate the corresponding environment.yml conda file"

    resolved_env_file_name = args.nidap_resolved_env_file
    resolved_env_file = open(resolved_env_file_name)
    resolved_env = json.load(resolved_env_file)
    
    env_file_name = args.nidap_env_file 
    env_file = open(env_file_name)
    env = json.load(env_file)

    env_name = args.env_name

    all_packages = env['condaEnvironmentDefinition']['packageMatchSpecs']
    r_packages = [package for package in all_packages if package.startswith("r-") or package.startswith("bioconductor-")]

    resolved_packages = resolved_env['resolvedCondaEnvironment']['packageSpecs']
    resolved_packages_names_versions = [ (package['name'], package['version']) for package in resolved_packages]

    resolved_packages_dict = dict(resolved_packages_names_versions)

    conda_r_packages = []
    resolved_packages_names = resolved_packages_dict.keys()
    for package in r_packages:
        if package in resolved_packages_names:
            conda_r_packages.append(package+"="+resolved_packages_dict[package])
        else:

            #The package already has a version defined before resolving
            conda_r_packages.append(package)


    conda_r_packages.append("r-renv")
    conda_r_packages.append("r-biocmanager")
    conda_r_packages.sort()

    #Create the conda bash file
    #Use mamba to resolve the environment as it is much faster than conda.

    #Write the environment.yml file
    yml_file_name = "environment.yml"
    yml_contents = {} 
    yml_contents["name"] = env_name
    yml_contents["dependencies"] = conda_r_packages
    yml_contents["channels"] = ["bioconda", "conda-forge", "defaults"]
    with open(yml_file_name, 'w') as yml_file:
        yaml.dump(yml_contents, yml_file)
    
   
    bash_contents = "" 
    bash_contents += "mamba env create --name {0} --file {1}\n".format(env_name, yml_file_name)

    conda_file_name = "create_{}.sh".format(env_name)
    with open(conda_file_name, 'w') as conda_file:
        conda_file.write(bash_contents)

    print("Wrote:" + yml_file_name)
    print("Wrote:" + conda_file_name)
    return conda_r_packages


def create_r_library_file(conda_r_packages):
    "Parses the created conda_r_packages and export an R file that calls all libraries"
    r_file_name = "main.R"

    #Create the R file that loads the libraries
    r_packages = [package.split("=", 1)[0] for package in conda_r_packages]
    #remove the prefix "r-"
    r_packages = [ package.split("-")[1] for package in r_packages]

    #Remove the 'base' package
    r_packages.remove("base")

    #Replace the package name with the library call (e.g. seurat)  for known packages
    script_dir = os.path.dirname(os.path.abspath(__file__)) 
    conda_r_json = os.path.join(script_dir, "conda-r.json")
    with open(conda_r_json, 'r') as conda_r:
        translation = json.load(conda_r)

    translated_packages = [translation[package] for package in r_packages\
        if package in translation.keys()] 

    normal_packages = [package for package in r_packages\
        if package not in translation.keys()]    

    library_packages = normal_packages + translated_packages
    #Create the R file 
    r_file_contents = [ 'library({0})'.format(library) for library in library_packages]
    r_file_contents = "\n".join(r_file_contents)

    with open(r_file_name, 'w') as r_file:
        r_file.write(r_file_contents)

    print("Wrote:" + r_file_name)


if __name__ == '__main__':

   parser = argparse.ArgumentParser(description='Parse NIDAP exported environments and create equivalent environment.yml file')
   parser.add_argument("nidap_env_file", help="The exported NIDAP environment file")
   parser.add_argument("nidap_resolved_env_file", help="The exported solved NIDAP environment file")
   parser.add_argument("env_name", help="The name of then conda environment to be created")

   args = parser.parse_args()

   conda_r_packages = create_conda_yml_file(args)
   create_r_library_file(conda_r_packages)

