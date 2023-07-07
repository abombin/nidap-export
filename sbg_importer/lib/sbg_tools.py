import os, sys
from sevenbridges import Api

#pip install sevenbridges-python
#credentials at:
#api_endpoint = https://api.sbgenomics.com/v2
#auth_token = <hash>
class SBGApi():
    """
    A utility class to perform Seven Bridges Genomics requests
    """

    def __init__(self, token=""):
        """
        Constructor

        @param token <str>
        The SBG authentication token
        """
        self.token = token if token != "" else self.get_token()
        self.url = "https://cgc-api.sbgenomics.com/v2"
        self.api = Api(self.url,self.token)
        self.me = self.api.users.me()
        self.user = self.me.username
        self.email = self.me.email
        print(f"SBG username: {self.user}")
        import requests
        from requests.packages.urllib3.exceptions import InsecureRequestWarning
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    def get_token(self):
        # Get the token from the credentials file
        f = open(os.path.expanduser("~/.sevenbridges/credentials"))
        lines = f.readlines()
        for l in lines:
            if "auth_token" in l:
                return l.split("=")[-1].strip().replace("\n","")
        return ""

    def get_files(self,pid,names=[]):
        # Get files based on the project id
        file_list = self.api.files.query(project=pid, names = names if len(names) > 0 else None)
        return file_list
    
    def list_files(self,pid,names):
        # List files based on the project id
        print(" - List of files:")
        print("   <name>: <id>")
        for file in self.get_files(pid,names):
            print(f"   + {file.name}: {file.id}")

    def get_projects(self):
        # Get the projects of the user
        return self.api.projects.query().all()
    
    def list_projects(self):
        # List the projects of the user
        print(" - List of projects:")
        print("   <name>: <id> (<created_on>)")
        projects = self.get_projects()
        for p in self.get_projects():
            print(f"   + {p.name}: {p.id} ({p.created_on})")
        return projects
    
    def get_project_by_id(self,pid):
        # Get a given project by its id
        return self.api.projects.get(id=pid)
    
    def create_project(self,name):
        # Create a project based on the argument name and returns its project id
        print(f" - Create project: {name}")
        # Grab the first billing group
        bg = self.api.billing_groups.query(limit=1)[0]
        # Create a project using the billing group grabbed above
        project = self.api.projects.create(name=name, billing_group=bg.id)
        print(f"id: {project.id}")
        return project
    
    def delete_project(self,pid):
        # Delete a project based on the project id
        project = self.get_project_by_id(pid)
        project.delete()
    
    def upload_file_to_project(self,path,pid):
        # Upload a file to a given project based on its id
        self.api.files.upload(path, project=pid)
    
    def upload_file_to_folder(self,path,fid):
        # Upload a file to a given folder based on its id
        parent_folder = self.api.files.get(fid)
        self.api.files.upload(path, parent=parent_folder)

    def upload_directory(self,path,pid):
        # Upload the whole directory structure of the pipeline to SBG
        print(f" - Uploading full directory to SBG")
        print(f"   > Local Path: {path}")
        print(f"   > Project id: {pid}")

        # Get project
        project = self.get_project_by_id(pid)
        assert project.id == pid, "Issue when retrieving project class from SBG"

        files = [f"{path}/{f}" for f in os.listdir(path) if os.path.isfile(f"{path}/{f}")]
        dirs = [d for d in os.listdir(path) if os.path.isdir(f"{path}/{d}")]
        
        print("   > Uploading to project base directory:")
        for f in files:
            print(f"     + {f}")
            self.upload_file_to_project(f,pid)
        
        for d in dirs:
            print(f"   > Creating project/{d} directory")
            new_folder = self.api.files.create_folder(
                name=d, project=pid,
            )

            files = [f"{path}/{d}/{f}" for f in os.listdir(f"{path}/{d}") if os.path.isfile(f"{path}/{d}/{f}")]
            if len(files) == 0:
                continue
            
            print(f"   > Uploading to project/{d} directory:")
            for f in files:
                print(f"     + {f}")
                self.upload_file_to_folder(f,new_folder.id)

    def create_app(self, name, fname, pid):
        # Create an application
        # Use sbpack: https://github.com/rabix/sbpack
        # TO DO
        return
    
    def create_task(self, name, fname, pid):
        # Create a task
        # TO DO
        return