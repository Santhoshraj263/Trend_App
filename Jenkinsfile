pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'san263/trend_project:latest'
        DOCKER_REGISTRY_CREDENTIALS = 'dockerhub-credentials' // Add credentials in Jenkins
        KUBECONFIG_CREDENTIALS = 'kubeconfig-id'              // Add kubeconfig in Jenkins
    }

    stages {
        stage('Checkout Source') {
            steps {
                git 'https://github.com/Santhoshraj263/Trend_App.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_REGISTRY_CREDENTIALS) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(credentialsId: KUBECONFIG_CREDENTIALS) {
                    sh 'kubectl apply -f deployment.yml'
                    sh 'kubectl apply -f service.yml'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
