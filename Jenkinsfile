/*
Jenkinsfile for deploying Terraform
*/

node {
    properties([
        parameters([
            string(name: 'bucket', description: 'Bucket Name for State File', trim: false),
            string(name: 'project', description: 'Project', trim: false).
            string(name: 'git_creds', description: 'GithHub Credentials', trim: false),
            string(name: 'aws_credentials', description: 'AWS Credentials', trim: false),
            choice(choices: ['Apply', 'Destroy'], name: 'apply_or_destroy', description: 'Apply or Destroy Terraform')
        ])
    ])

    withCredentials([
        [
            $class: 'SSHUserPrivateKeyBinding',
            credentialsId: "${params.git_creds}",
            keyFileVariable: 'ssh_key_file'
        ],
        [
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${params.aws_creds}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]
    ])
        {

            deleteDir()

            stage('Checkout') {
                checkout scm
            }

            stage('Initialize the Backend') {
                dir("base-vpc") {
                    sh "terraform init -backend-config=\"bucket=${params.bucket}\" -backend-config=\"key=terraform/${params.project}.tfstate\" -backend-config=\"dynamodb_table=terraform=${params.project}-lock\" -backend-config=\"region=us-east-1\""
                }
            }

            stage('Terraform Plan') {
                dir("base-vpc") {
                    if (params.apply_or_destroy == 'Destroy') {
                        sh "terraform plan -destroy -input=false -refresh=true -module-depth=-1 -var-file=environments/globals/inputs.tfvars -var-file=environments/${params.project}/inputs.tfvars"
                    } else {
                        sh "terraform plan -input=false -refresh=true -module-depth=-1 -var-file=environments/globals/inputs.tfvars -var-file=environments/${params.project}/inputs.tfvars"
                    }
                }
            }

            stage('Terraform Apply/Destroy') {
                dir("base-vpc") {
                    if (params.apply_or_destroy == 'Destroy') {
                        sh "terraform destroy -auto-approve -var-file=environments/globals/inputs.tfvars -var-file=environments/${params.project}/inputs.tfvars"
                    } else {
                        sh "terraform apply -input=true -auto-approve -refresh=true -var-file=environments/globals/inputs.tfvars -var-file=environments/${params.project}/inputs.tfvars"
                    }
                }
            }
        }
}
