pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-terraform')
        AWS_DEFAULT_REGION    = 'us-east-1'
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

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -input=false -out=tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Terraform plan looks good. Apply changes?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        success {
            echo 'Terraform deployment completed successfully.'
        }

        failure {
            echo 'Terraform pipeline failed. Check the Jenkins console output.'
        }
    }
}
