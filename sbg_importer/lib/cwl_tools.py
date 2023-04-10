import os, sys
from lib.contents import *

config = {
    ".warning": ["\033[93m", "\033[00m"], ".error": ["\033[91m", "\033[00m"],
    "requirements": [
        {"name": "RScripts", "value":".R"},
        {"name": "Run Pipeline", "value":"run_pipeline.sh"},
    ]
}

def get_sequence(fname = 'run_pipeline.sh',path="pipeline/src",to_remove="pipeline/"):
    # Returns the sequence of commands, names of files, inputs, outputs, file requirements and
    # number of steps of the pipeline based on the run_pipeline.sh based on the outputs of the
    # transform.R scripts.  
    print(f" - Reading sequence of commands from {fname}")
    f = open(f"{path}/{fname}")
    commands = []
    for l in f:
        if 'template_function' not in l:
            continue
        commands.append(l.replace('\n',''))
    f.close()
    calls = [c.split(' ')[0] for c in commands]
    fnames = [f"{path.replace(to_remove,'')}/{c.split(' ')[-1]}" for c in commands]
    names = [f"{f.split('.')[0].split('/')[-1].replace('template_function_','')}" for f in fnames]
    outputs = [f"out_{f}" for f in names]
    n_steps = len(calls)
    requires = [None]
    requires.extend([outputs[i-1] for i in range(1,n_steps+1)])
    return fnames, names, requires, n_steps

def init_cwl_file(fname = 'cwl_pipeline.cwl', version = '1.2', workflow_id="<your-user>/<your-project>/<your-workflow>/0", label="workflow"):
    # Returns the cwl pipeline file address with its header initialized
    print(f" - Creating CWL pipe: {fname}")
    f = open(fname, 'w')
    f.write(f"class: Workflow\n")
    f.write(f"cwlVersion: v{version}\n")
    #f.write(f"id: {workflow_id}\n")
    #f.write(f"label: {label}\n")
    f.write(f"$namespaces:\n")
    f.write(f"  sbg: 'https://sevenbridges.com'\n")
    return f

def cwl_add_input_level(f):
    # Includes the input level in the cwl pipeline file
    print(f" - Add input level to CWL pipe")
    f.write("inputs:\n" )
    f.write("  - id: input_data\n" )
    f.write("    type: 'File[]?'\n" )

def cwl_add_input_fname(f,name,fname):
    # Includes the file-type input to the cwl file
    print(f"   > Add file input: {name}")
    f.write(f"  - id: {name}\n")
    f.write(f"    type: String\n")
    f.write(f"    default: /{fname}\n")

def cwl_add_multiple_inputs_fname(f,name,fname):
    # Includes multiple file-type inputs to the cwl file
    for i in range(len(name)):
        cwl_add_input_fname(f,name[i],fname[i])

def cwl_add_input_directory(f,name,path):
    # Includes directory-type input to the cwl file
    print(f"   > Add input directory: {path}")
    f.write(f"  - id: {name}\n")
    f.write( "    type: Directory\n")
    f.write( "    loadListing: deep_listing\n")

def cwl_add_output_level(f,name):
    # Includes the output level in the cwl pipeline file
    print(f" - Add output level to CWL pipe")
    f.write("outputs:\n" )
    for n in name:
        f.write(f"  - id: {n}_output\n")
        f.write(f"    outputSource:\n")
        f.write(f"      - {n}/output\n")
        f.write(f"    type: 'File[]?'\n")

def cwl_add_step_level(f):
    # Includes the step level in the cwl pipeline file
    print(f" - Add step level to CWL pipe")
    f.write("steps:\n" )

def cwl_add_rscript_step(f,name,requirement,input,repo):
    # Includes the rscript step to cwl pipeline file based on the argument parameters
    print(f"   > Add Rscript step: {name}")
    # Add id
    f.write(f"  - id: {name}\n")

    # Add inputs
    f.write(f"    in:\n")
    f.write(f"      - id: script_file\n")
    f.write(f"        default: /{input}\n")
    f.write(f"      - id: input_data\n")
    f.write(f"        source:\n")
    #f.write(f"          - input_data\n")
    if requirement is not None:
        if "input_data" in requirement:
            f.write(f"          - input_data\n")
        for r in (requirement):
            if r == "input_data":
                continue
            else:
                f.write(f"          - {r[4:]}/output\n")

    # Add outputs
    f.write(f"    out:\n")
    f.write(f"      - id: output\n")

    # Add runner
    f.write(f"    run:")
    rscript_content = cwl_rscript_content.format(docker_image=repo)
    for l in rscript_content.splitlines():
        f.write("      "+l+"\n")
    f.write(f"    label: {name}\n")

def cwl_add_requirements(f,repo):
    # Includes the final requirements to the cwl pipeline file
    f.write("requirements:\n")
    f.write("  - class: MultipleInputFeatureRequirement\n")
    f.write("  - class: InlineJavascriptRequirement\n")
    f.write("  - class: StepInputExpressionRequirement\n")

def create_rscript_cwl_call(fname='rscript.cwl',repo=''):
    # Populates the Rscript.cwl file
    print(f" - Creating Rscript run: {fname}")
    f = open(fname, 'w')
    f.write(cwl_rscript_content.format(docker_image=repo))
    f.close()

def get_lines(fname):
    # Get file lines
    f = open(fname,'r')
    lines = f.readlines()
    return lines

def get_lines_with(fname,string):
    # Get file lines that contains a given string
    lines = get_lines(fname)
    filtered = [l for l in lines if string in l]
    return filtered

def get_file_from_line(line,ext):
    # Get the name of a file from a given string line and the file extension
    fname = line.split('"')[1]
    if fname[0] == '/':
        fname = fname[1:]
    if (ext not in fname):
        print('ERROR')
    return fname

def append_path_dep(arr,base):
    # Append the path dependency
    path = []
    for a in arr:
        path.append([f"{base}/{i}" for i in a])
    return path

def get_inputs(script,base):
    # Get the input datasets from the Rscript file
    lines = get_lines_with(f"{base}/{script}",'readRDS')
    inputs = [get_file_from_line(l,'.rds') for l in lines]
    return inputs
    
def get_input_dependencies(file_arr,base):
    # Get the dataset dependencies from and array of files
    print(" - Get dataset dependencies")
    inputs = [get_inputs(fname,base) for fname in file_arr]
    path = append_path_dep(inputs,base)
    names = []
    for i in inputs:
        names.append([f"in_{j.split('.')[0]}" for j in i])
    return inputs, path, names

def get_outputs(script,base):
    # Get the output datasets from the Rscript file
    lines = get_lines_with(f"{base}/{script}",'saveRDS')
    outputs = [get_file_from_line(l,'.rds') for l in lines]
    return outputs

def get_generated_outputs(file_arr,base):
    # Get all the dataset that will be generated based on an array of files
    print(" - Get generated outputs")
    outputs = [get_outputs(fname,base) for fname in file_arr]
    path = append_path_dep(outputs,base)
    return outputs, path

def get_initial_dataset(inp,out):
    inputs, outputs = [], []
    for i in inp:
        inputs.extend(i)
    for o in out:
        outputs.extend(o)
    initial = list(set(inputs) - set(outputs))
    generated = list(set(outputs))
    return initial, generated

def get_topological_graph(fnames,output_folder,flow):
    # Get the topological graph dependencies
    print(" - Get topological graph")
    input = get_input_dependencies(fnames,output_folder)[0]
    output = get_generated_outputs(fnames,output_folder)[0]
    initial, generated = get_initial_dataset(input,output)
    graph = []
    #graph.append([])
    for i in range(0,len(flow)):
        #need = list(set(input[i]) - set(initial))
        need = list(set(input[i]))
        gi = []
        for n in need:
            for j in range(len(initial)):
                if initial[j] == n:
                    gi.append("input_data")
            for j in range(len(output)):
                for o in output[j]:
                    if o == n:
                        gi.append(flow[j])
        graph.append(list(set(gi)))
    return graph, initial

def write_lines(fname,lines):
    # Write the array of lines to a file
    f = open(fname,'w')
    f.writelines(lines)
    f.close()

def fix_replaces(line):
    # Replace the 'rds_output' to be actually received by the argument of the script to where
    # the data is and where it should be saved
    if ("saveRDS" in line):
        line = line.replace('paste0(rds_output,"/','paste0("","')
    elif ("readRDS" in line):
        arg = line.split('"')[-2][1:]
        line = line.replace("paste0(rds_output,",f"paste0(get_path(args,\"{arg}\"),")
    return line

def fix_RScript_lines(lines):
    # Includes argument parameters to the Rscripts
    mod_lines = []
    mod_lines.append("args <- commandArgs(trailingOnly=TRUE)\n")
    mod_lines.append("get_path <- function(arguments,name) {message(\"In get_path:\"); message(arguments); message(name); for (i in 1:length(arguments)){arg = arguments[i]; if(grepl(name, arg, fixed=TRUE)){message(\"Found argument\"); pos = nchar(arg)-nchar(name); message(substr(arg,1,pos-1)); return(substr(arg,1,pos-1))}}; message(\"No argument found\")}\n")
    for l in lines:
        mod_lines.append(fix_replaces(l))
        
    return mod_lines

def fix_RScript_files(arr,base):
    # Fix all the Rscript files including the possibility of receiving arguments and
    # using them as paths to read/store files
    print(" - Fixing RScripts")
    for a in arr:
        lines = get_lines(f"{base}/{a}")
        lines = fix_RScript_lines(lines)
        write_lines(f"{base}/{a}",lines)
    
def create_dir(target,output):
    # Create the initial project directory and organize its structure
    print(" - Copying target folder files")
    os.system(f"mkdir {output}")
    os.system(f"mkdir {output}/cwl")
    os.system(f"mkdir {output}/src")
    os.system(f"mkdir {output}/data")
    os.system(f"cp {target}/template_function_*.R {output}/src/")
    os.system(f"cp {target}/run_pipeline.sh {output}/src/")
    os.system(f"cp {target}/rds_output/* {output}/data/")

