pipeline {
       agent {
        label 'docker-agent-label'  // Replace with your actual node label
    }

    environment {
        GIT_REPO = 'https://github.com/sakethravikanti/django-on-ec2.git'
        GIT_BRANCH = 'develop'
        DOCKER_IMAGE = 'todo-app'
        DEPLOY_SERVER = 'ubuntu@your-deployment-server-ip'
        PEM_KEY = '/path/to/your-key.pem' // Update this
    }

    stages {
        stage('Clone TO-DO Repository') {
            steps {
                script {
                    echo 'Checking if repository already exists...'
                    sh '''
                        if [ ! -d to-do-list-practise ]; then
                            git clone -b $GIT_BRANCH $GIT_REPO to-do-list-practise
                        else
                            echo "Repository exists. Pulling latest changes..."
                            cd to-do-list-practise
                            git reset --hard HEAD
                            git pull origin $GIT_BRANCH
                        fi
                    '''
                }
            }
        }

        stage('Run Pylint Checks') {
            steps {
                script {
                    echo 'Running Pylint Checks...'
                    sh '''
                        cd to-do-list-practise
                        if [ -f pylint.sh ]; then
                            chmod +x pylint.sh
                            ./pylint.sh | tee pylint.log
                        else
                            echo "Pylint script not found!"
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image...'
                    sh '''
                        cd to-do-list-practise
                        sudo docker build -t $DOCKER_IMAGE -f Dockerfile .
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    echo 'Logging in to AWS ECR...'
                    sh '''
                        AWS_REGION="your-region"
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        ECR_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                        aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    echo 'Pushing Docker Image to AWS ECR...'
                    sh '''
                        AWS_REGION="your-region"
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        ECR_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                        sudo docker tag $DOCKER_IMAGE $ECR_REPO/$DOCKER_IMAGE:latest
                        sudo docker push $ECR_REPO/$DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo 'Deploying Application to EC2...'
                    sh '''
                        scp -i $PEM_KEY docker-compose.yml $DEPLOY_SERVER:/home/ubuntu/
                        ssh -i $PEM_KEY $DEPLOY_SERVER << EOF
                            sudo docker pull $ECR_REPO/$DOCKER_IMAGE:latest
                            sudo docker stop $DOCKER_IMAGE || true
                            sudo docker rm $DOCKER_IMAGE || true
                            sudo docker run -d --name $DOCKER_IMAGE -p 8000:8000 $ECR_REPO/$DOCKER_IMAGE:latest
                        EOF
                    '''
                }
            }
        }
    }
}
