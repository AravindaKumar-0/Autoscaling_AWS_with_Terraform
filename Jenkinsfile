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

        stage('Terraform Destroy Plan') {
            steps {
                sh 'terraform plan -destroy -input=false'
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: 'This will destroy the Terraform infrastructure. Continue?',
                    ok: 'Destroy'
                )
            }
        }

        stage('Terraform Destroy') {
            steps {
                sh 'terraform destroy -auto-approve -input=false'
            }
        }
    }

    post {

        success {
            echo 'Terraform infrastructure destroyed successfully.'
        }

        failure {
            echo 'Terraform destroy failed. Check the Jenkins console output.'
        }
    }
}
