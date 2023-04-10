import os, sys
from lib.docker_tools import get_repository_name, create_docker
from lib.cwl_tools import config, create_dir, get_sequence, get_topological_graph, fix_RScript_files, \
                        create_rscript_cwl_call, init_cwl_file, cwl_add_input_level, cwl_add_output_level, \
                        cwl_add_step_level, cwl_add_rscript_step, cwl_add_requirements
from lib.sbg_tools import SBGApi

def help():
        return """
sbg_importer.py: Creates a CWL pipeline based on the output of a project from
the NIDAP export.

USAGE:
    python sbg_importer.py <nidap_export_project> <cwl_output_directory>
           [<docker_registry_address>] [-f] [-h]

Required Positional Arguments:
    [1] nidap_export_project      Type [Path]: Relative PATH for the NIDAP transformed
                                  project folder.
    [2] project_name_directory    Type [Path]: Absolute or relative PATH to the output
                                  directory of the cwl files and pipeline. The files
                                  will be created in this folder and the name of this
                                  folder will be the name of the project on SBG.

Optional Positional Arguments:
    [2] docker_registry_address   Type [URL]: If your docker image is already at SBG,
                                  add the link to it here, otherwise the package will
                                  build the docker image and deploy to SBG.
Options:
    [-h, --help]                  Displays usage and help information for the script.
    [-f, --force]                 The software has a protection to not upload anything
                                  in case the project already exists on SBG. If you
                                  force, it will delete the project and create it again
                                  with the new data and scripts.

Example:
    # Run against user-provided information: "NIDAP_export_project", "/user/test/project_name"
    # Will use the files from NIDAP_export_project and create the pipeline under the path
    # "user/test/project_name", creating the name of the project in SBG as the latest folder,
    # in this case as "project_name" ("user/test/<project_name>")
    $ python create_cwl_pipeline.py NIDAP_export_project /user/test/project_name

Requirements:
    python >= 3.7
"""

def validate(target, output, docker, force):
    # Validate the user entries
    not_met = []
    files = [f for f in os.listdir(target)]
    for req in config["requirements"]:
        met = False
        for f in files:
            if req["value"] in f:
                met = True
        if not met:
            not_met.append(req["name"])

    if len(not_met) > 0:
        print("\n{}Error: Failed to find all required files in path provided:{} {} - {}".format(*config['.error'],target,not_met), file=sys.stderr)
        sys.exit(1)

    proj_name = output.split('/')[-1]

    return target, output, proj_name, docker, force

def args(argslist):
    # Extract the user entries
    user_args = argslist[1:]
    docker = ""
    force = False

    # Check for optional args
    if '-h' in user_args or '--help' in user_args:
        print(help())
        sys.exit(0)

    if '-f' in user_args or '--force' in user_args:
        user_args = [arg for arg in user_args if arg not in ['-f', '--force']]
        force = True

    if len(user_args) < 2:
        print("\n{}Error: Failed to provide all required arguments{}".format(*config['.error']), file=sys.stderr)
        print(help())
        sys.exit(1)

    if (len(user_args) == 3):
        docker = user_args[2]

    target, output = user_args[0], user_args[1]
    return validate(target, output, docker, force)

def create_pipeline(target="../Unit_test_pipeline", output="pipeline", sbg=None, repo=''):

    # Create the whole CWL pipeline file
    print("\n----------- Creating pipeline ------------")

    # Get files from target folder
    create_dir(target,output)

    # Get commands, sequences and calls from the generated pipeline
    fnames, names, requires, n_steps = get_sequence(f"run_pipeline.sh",f"{output}/src",to_remove=f"{output}/")

    # Get dependency graph
    graph, initial = get_topological_graph(fnames,output,requires[1:])

    # Fix some lines of code so that CWL can run them
    fix_RScript_files(fnames,output)

    # Generate common cwl scripts to be used
    create_rscript_cwl_call(f"{output}/cwl/rscript_tool.cwl", repo)

    # Initialize main cwl pipeline
    workflow_id = f"{sbg.user}/{output}/workflow/0"
    cwl = init_cwl_file(f"{output}/cwl/workflow.cwl","1.2",workflow_id,"workflow")
    cwl_add_input_level(cwl)

    # Include steps
    cwl_add_step_level(cwl)
    for s in range(n_steps):
        cwl_add_rscript_step(cwl,names[s],graph[s],fnames[s],repo)
    cwl_add_requirements(cwl,repo)
    cwl_add_output_level(cwl,names)

    # Process completed
    cwl.close()
    print("#################################################")
    print("#                     IMPORTANT                 #")
    print("# > Initial files required:                     #")
    for i in initial:
        print(f"# {i}{''.join([' ' for j in range(45-len(i))])} #")
    print("#################################################")

def create_project_sbg(path,sbg,force=False):
    # Create a project on the SBG
    print("\n--------- Create project in SBG ----------")
    project_name = path.split("/")[-1]

    projects = sbg.list_projects()
    
    for p in projects:
        if p.name == project_name:
            if not force:
                print("\n{}Error:{} Found an existing project on SBG with the same name ({}).".format(*config['.error'],project_name), file=sys.stderr)
                sys.exit(1)
            else:
                print("\n{}Warning:{} Found an existing project with the same name ({}).".format(*config['.warning'],project_name))
                print("User requested to force the upload, deleting the project and recreating...")
                p = sbg.get_project_by_id(p.id)
                p.delete()

    project = sbg.create_project(path)
    pid = project.id
    rootf = project.root_folder
    href = project.href
    return pid

def main():    
    # Get arguments
    target, output, proj_name, docker, force = args(sys.argv)
    print(f"Project name: {proj_name}")
    
    # Create an API session
    sbg = SBGApi()
    
    # Get the Docker Image address
    repo = get_repository_name(target,sbg.user,proj_name)[0] if docker == "" else docker
    print(f"Docker address: {repo}")

    # Create the CWL code pipeline
    create_pipeline(target,output,sbg,repo)
    print(f"Output folder: {output}")
    return
    # Create Docker Image and upload to SBG
    if docker == "":
        create_docker(target,sbg.user,output,proj_name)

    # Create the project into SBG
    pid = create_project_sbg(output,sbg,force)

    # Upload full directory (CWL code, data and scripts) to SBG
    sbg.upload_directory(output,pid)

if __name__ == '__main__':
    main()