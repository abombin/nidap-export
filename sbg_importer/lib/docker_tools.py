import os, sys

def get_repository_name(folder,user,proj_name):
    docker_dir = f"{folder}/../Docker"
    name = docker_dir.split("/")[-4]
    name_low = name.lower()
    proj_name = proj_name.lower()
    repo = f"cgc-images.sbgenomics.com/{user}/{proj_name}:latest"
    return repo, name, name_low, docker_dir

def create_docker_file():
    docker_original = open("Dockerfile","r")
    docker_modified = open("Dockerfile_mod","w")
    original_lines = docker_original.readlines()
    modified_lines = []
    for l in original_lines:
        if l.startswith("CMD "):
            modified_lines.append(
                "RUN mkdir /src/\n"
            )
            modified_lines.append(
                f"COPY src/* /src/\n"
            )
        modified_lines.append(l)
    docker_modified.writelines(modified_lines)
    docker_original.close()
    docker_modified.close()

def create_docker(folder,user,output,proj_name):
    # Creates the docker file and upload it to the SBG registry and returns
    # its repository address
    print("\n------------- Create Docker --------------")

    current_dir = os.getcwd()
    repo, name, name_low, docker_dir = get_repository_name(folder,user,proj_name)
    
    # Go to Docker location
    os.chdir(docker_dir)
    
    os.system(f"cp -r {current_dir}/{output}/src .")
    create_docker_file()
    
    print(f"Building docker image for project: {name}")
    os.system(f"docker build -t {name_low} -f Dockerfile_mod .")
    
    print(f"Tagging docker image: {name_low}")
    os.system(f"docker tag {name_low} {repo}")

    print(f"Docker SBG repository login, please use your email and your auth-token credential if necessary (under ~/.sevenbridges/credentials)")
    os.system(f"docker login cgc-images.sbgenomics.com")

    print(f"Push docker image to SBG")
    os.system(f"docker push {repo}")

    # Come back to working dir
    os.chdir(current_dir)
    return repo

#docker run -it proj_test

#docker tag proj_test cgc-images.sbgenomics.com/degenhardthf/proj_test:latest
#docker login cgc-images.sbgenomics.com
#username + auth-token
#docker push cgc-images.sbgenomics.com/degenhardthf/proj_test:latest
