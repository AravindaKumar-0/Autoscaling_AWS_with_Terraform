pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-terraform')
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Select Action') {
            steps {
                script {
                    env.TERRAFORM_ACTION = input(
                        message: 'Select Terraform action',
                        parameters: [
                            choice(
                                name: 'ACTION',
                                choices: ['APPLY', 'DESTROY'],
                                description: 'Choose whether to apply or destroy infrastructure'
                            )
                        ]
                    )
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (env.TERRAFORM_ACTION == 'APPLY') {
                        sh 'terraform plan -input=false -out=tfplan'
                    } else {
                        sh 'terraform plan -destroy -input=false -out=destroy.tfplan'
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    if (env.TERRAFORM_ACTION == 'APPLY') {
                        input(
                            message: 'Terraform plan looks good. Apply changes?',
                            ok: 'Apply'
                        )
                    } else {
                        input(
                            message: 'WARNING: This will destroy all Terraform infrastructure. Continue?',
                            ok: 'Destroy'
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    env.TERRAFORM_ACTION == 'APPLY'
                }
            }
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    env.TERRAFORM_ACTION == 'DESTROY'
                }
            }
            steps {
                sh 'terraform apply -input=false destroy.tfplan'
            }
        }
    }

    post {
        success {
            echo 'Terraform operation completed successfully.'
        }

        failure {
            echo 'Terraform pipeline failed. Check the Jenkins console output.'
        }

        aborted {
            echo 'Terraform pipeline was aborted.'
        }
    }
}
