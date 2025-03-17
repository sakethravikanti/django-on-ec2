pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1' // Change to your AWS region
        ECR_REPO = 'your-ecr-repository-url' // Change to your ECR repository URL
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    echo 'Checking out SCM...'
                    checkout scm
                }
            }
        }

        stage('Run Pylint Checks') {
            steps {
                script {
                    echo 'Running Pylint Checks...'
                    sh '''
                        cd django-on-ec2
                        chmod +x pylint.sh
                        ./pylint.sh
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image...'
                    sh '''
                        cd django-on-ec2
                        docker build -t my-django-app .
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    echo 'Logging in to AWS ECR...'
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    echo 'Pushing Docker Image to ECR...'
                    sh '''
                        docker tag my-django-app:latest $ECR_REPO:latest
                        docker push $ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo 'Deploying to EC2...'
                    sh '''
                        ssh -i /path/to/your-key.pem ec2-user@your-ec2-instance-ip "docker pull $ECR_REPO:latest && docker run -d -p 8000:8000 my-django-app"
                    '''
                }
            }
        }
    }
}
