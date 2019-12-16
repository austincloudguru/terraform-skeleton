# terraform-skeleton
When I first started with Terraform a few years ago, I wanted to have my repositories structured in a logical fashion, but nothing I found seemed to fit what I was looking for.  I searched the internet to find out what HashiCorp recommended and what other people are doing, but nothin I saw really felt right to me.  In examining what other people were doing, however, I was able to take the best parts from various layouts and meld it into a structure that worked for me and I have been using it ever since.

I expect that many will look at my layout and feel the same way I did about many of the ones I looked at.  Hopefully, you will be able to take a way at least a nugget or two to help you with your structure.  You can check out the GitHub repo here.

## Directory Layout
The directory layout is pretty straight forward.  It contains a directory for all the project variables and Terraform files as well as a Makefile and Jenkinsfile for automation.  The file tree of the directory looks like this:

    .
    ├── projects
    │   ├── globals
    │   │   └── inputs.tfvars
    │   └── template
    │       └── inputs.tfvars
    ├── Makefile 
    ├── Jenkinsfile
    ├── backend.tf
    ├── provider.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── statefile.tf 
    ├── README.md
    └── LICENSE
## Projects
The projects directory stores the .tfvars file for each project.  The skeleton repo contains two directories.  The globals directory is run each time Terraform is run.  It contains variables that are constant across deployments.  The template directory is an example of an individual project file.   When you use Makefile or Jenkinsfile to run the Terraform command, it will run with the global variables as well as the variables of the defined project.  I think of a project as an individual instantiation of the Terraform state.  It could be an environment (development/staging/production), accounts (aws1, aws2, etc), or even regions (us-west-1, eu-east-1, etc).

### Makefile
I do not remember where I came across the idea to use a Makefile for running my Terraform commands, but it has been extremely useful.  It allows me to run multiple commands at once without typing long command lines.  Prior to running the make file, you need to set two environmental variables.  The BUCKET variable is used in the  terraform init command to set the S3 bucket used to store state.  The  PROJECT variable is the project that you want to run the terraform for.  This variable is used in the name of the Terraform state file as well as to choose which project variables to run.

### Jenkinsfile
The Jenkinsfile is used to run the terraform commands from Jenkins.  It runs a a Jenkins pipeline that includes 4 stages: Checkout, Initialize the Backend, Terraform Plan, and Terraform Apply/Destroy.  As requires 5 parameters to run the job: The name of the S3 bucket, the project name, the Git credentials to use, the AWS credentials to use, and a dropdown to apply or destroy the project.

### Terraform Files
Rather than cramming everything into a single file, I tend to use more files rather than less for readability.  To that end I generally have 5 .tf files that I use when working with Terraform.

#### backend.tf
The backend.tf file contains information about which backend to use (S3 in my case).

#### provider.tf
The provider.tf file contains which provider to use.  My directory defaults to the AWS provider, but I have used Azure and GCP as well.

#### main.tf
This is where I define which modules I want to use.  Now that Terraform has a module registry, I try to use that as much as possible, but occasionally I will write my own.

#### variables.tf
The variables.tf file is used to initialize all the variables that I want to pass in via my projects file.

#### outputs.tf
The outputs.tf file is for storing any outputs that you may want to make available to other Terraform projects at a later time.

#### statefile.tf
The statefile.tf file is for creating the resources needed to create the S3 bucket and DynamoDB used for the statefile.

### Errata
The README.md and LICENSE file are self explanitory.

## Starting a New Project (New Way)
Now when I start a new project, it is relatively easy for me to .  I use GitHub, and the recently introduced the concepts of templates, so it really easy to create a new repository via the CLI from a template:
```shell script
curl -s -X POST https://api.github.com/repos/austincloudguru/terraform-skeleton/generate \
-H "Accept: application/vnd.github.baptiste-preview+json" \
-H "Authorization: token $GIT_TOKEN" \
-d @<(cat <<EOF
{
  "owner": "austincloudguru",
  "name": "my-new-repo",
  "description": "My Test Repo",
  "private": true
}
EOF
)|jq -r .ssh_url
```
From there you can clone the repository.

## Starting a New Project (Original Way)
Now when I start a new project, it is relatively easy for me to .  Since I use GitHub, all my commands will be tailored for that platform.

### Create an Empty Repository on GitHub
Start by creating an empty repository on GitHub.  You can do this through the web interface, or if you have a GitHub token you can create it through the API with the following command:

    curl -s -X POST https://api.github.com/user/repos \
    -H "Authorization: token $GIT_TOKEN" \
    -d @<(cat <<EOF
    {
      "name": "terraform-test",
      "private": true
    }
    EOF
    )|jq -r .ssh_url
This will return the SSH URL for the newly created repo.

### Clone the Skeleton Repo
Next you can clone the skeleton repository to your local machine and rename it to your new repo:

    git clone git@github.com:AustinCloudGuru/terraform-skeleton.git terraform-test
    
### Change the Origin
Once you have the skeleton repository checked out, you can update the origin and push the code back up to GitHub:

    cd terraform-test/
    git remote rm origin
    git remote add origin git@github.com:AustinCloudGuru/terraform-test.git
    git push --set-upstream origin master
    
## Initialize the Statefile
In order to avoid the chicken and the egg issue with terraform, we create the S3 storage and DynamoDB using a local statefile, and then once the resources exist we transfer the statefile to S3 bucket.  

    make stateinit
    make stateplan
    make stateapply

Uncomment the S3 backend in backends.tf file and then run the following command:

    make init