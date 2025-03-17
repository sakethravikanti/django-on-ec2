pipeline {
    agent { label 'todo-label' }

    environment {
        AWS_ACCOUNT_ID = '571600845308'
        AWS_REGION = 'ap-south-1'
        EC2_USER = 'ubuntu'
        EC2_HOST = '3.109.185.115'
        APP_DIR = '/home/ubuntu/jenkins/jenkins/workspace/todo-pipeline_main'
        ECR_URI = "571600845308.dkr.ecr.ap-south-1.amazonaws.com/todo/app"
        PYTHON_BIN = '/usr/bin/python3'
    }
    stages {
        stage('Clone TO-DO Repository') {
            steps {
                withCredentials([string(credentialsId: 'github-token-key', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                    echo "Checking if repository already exists..."
                    if [ -d "to-do-list-practise/.git" ]; then
                        echo "Repository exists. Pulling latest changes..."
                        cd to-do-list-practise
                        git remote set-url origin https://github.com/sakethravikanti/django-on-ec2.git
                        git fetch origin main
                        git reset --hard origin/main
                        git pull origin main
                    else
                        echo "Cloning TO-DO LIST repository..."
                        git clone https://$GITHUB_TOKEN@github.com/sakethravikanti/django-on-ec2.git
                    fi
                    '''
                }
            }
        }

        stage('Run Pylint Checks') {
            steps {
                sh '''
                echo "Running Pylint Checks..."
                if [ -f to-do-list-practise/pylint.sh ]; then
                    chmod +x to-do-list-practise/pylint.sh
                    ./to-do-list-practise/pylint.sh | tee pylint.log || echo "⚠ Pylint warnings found, review pylint.log."
                else
                    echo "❌ pylint.sh not found. Skipping pylint checks."
                fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker Image..."
                cd to-do-list-practise
                docker build -t todo-app -f Dockerfile .
                docker tag todo-app:latest $ECR_URI:latest
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([string(credentialsId: 'aws-key', variable: 'AWS_ECR_PASSWORD')]) {
                    sh '''
                    echo "Logging into AWS ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                echo "Pushing Docker Image to AWS ECR..."
                docker push $ECR_URI:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ubuntu', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    echo "Deploying on EC2..."
                    ssh -tt -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST bash -c "
                    set -e
                    echo 'Checking for existing container...'
                    docker ps -q --filter 'name=todo-container' | grep -q . && docker stop todo-container && docker rm -f todo-container || echo 'No running container found.'

                    echo 'Checking for processes using port 8000...'
                    sudo lsof -ti:8000 | xargs -r sudo kill -9 || echo 'No process found on port 8000.'

                    echo 'Pulling latest image from ECR...'
                    docker pull $ECR_URI:latest

                    echo 'Running new container...'
                    docker run -d --restart=always -p 8000:8000 --name todo-container $ECR_URI:latest
                    "
                    '''
                }
            }
        }
    }
}
