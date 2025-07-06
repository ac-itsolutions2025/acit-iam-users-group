pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2' // Update if needed
    }

    parameters {
        booleanParam(name: 'EXECUTE_DEPLOYMENT', defaultValue: true, description: 'Deploy IAM users and group')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://your.git.repo/IAMUserProvisioning.git', branch: 'main'
            }
        }

        stage('Create IAM Users & Group') {
            when {
                expression { params.EXECUTE_DEPLOYMENT }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins-creds'  // Update with your Jenkins credential ID
                ]]) {
                    sh 'bash ./create_users.sh'
                }
            }
        }
    }

    post {
        success {
            echo 'IAM users and group created successfully!'
        }
        failure {
            echo 'Something went wrong during user creation.'
        }
    }
}
