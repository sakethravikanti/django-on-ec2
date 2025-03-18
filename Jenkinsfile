pipeline {
    agent { label 'docker-agent-label' } // Ensure this matches your Jenkins agent label

    environment {
        AWS_ACCOUNT_ID = '571600845308'
        AWS_REGION = 'ap-south-1'
        EC2_USER = 'ubuntu'
        EC2_HOST = '3.109.185.115'
        APP_DIR = '/home/ubuntu/jenkins/jenkins/workspace/multi-branch_develop/django-on-ec2'
        ECR_URI = "571600845308.dkr.ecr.ap-south-1.amazonaws.com/todo/app"
        PYTHON_BIN = '/usr/bin/python3'
    }
    stages {
        // 🟢 Clone the Repository
        stage('Clone TO-DO Repository') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token-key', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh '''
                    echo "Checking if repository already exists..."
                    if [ -d "django-on-ec2/.git" ]; then
                        echo "Repository exists. Pulling latest changes..."
                        cd django-on-ec2
                        git remote set-url origin https://$GIT_USER:$GIT_PASS@github.com/sakethravikanti/django-on-ec2.git
                        git fetch origin develop
                        git reset --hard origin/develop
                        git pull origin develop
                    else
                        echo "Cloning TO-DO LIST repository..."
                        git clone -b develop https://$GIT_USER:$GIT_PASS@github.com/sakethravikanti/django-on-ec2.git
                    fi
                    '''
                }
            }
        }

        // 🟢 Run Pylint Checks
        stage('Run Pylint Checks') {
            steps {
                sh '''
                echo "Running Pylint Checks..."
                cd django-on-ec2
                if [ -f pylint.sh ]; then
                    chmod +x pylint.sh
                    ./pylint.sh | tee pylint.log || echo "⚠️ Pylint warnings found, review pylint.log."
                else
                    echo "❌ pylint.sh not found in django-on-ec2 directory. Check file path."
                    exit 1
                fi
                '''
            }
        }

        // 🟢 Build Docker Image
        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker Image..."
                cd django-on-ec2
                export DOCKER_BUILDKIT=0  # ❗️ Disable BuildKit temporarily
                docker build --no-cache -t todo-app -f Dockerfile .
                '''
            }
        }

        // 🟢 Fix Docker Permission Issue
        stage('Fix Docker Permissions') {
            steps {
                sh '''
                echo "Ensuring Docker permissions are correct..."
                sudo usermod -aG docker $USER || echo "User already part of docker group"
                sudo chmod 666 /var/run/docker.sock
                '''
            }
        }

        // 🟢 Login to AWS ECR
        stage('Login to AWS ECR') {
            steps {
                withCredentials([string(credentialsId: 'aws-ecr-tuesday', variable: 'AWS_ECR_PASSWORD')]) {
                    sh '''
                    echo "Logging into AWS ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
                    '''
                }
            }
        }

        // 🟢 Push Docker Image to ECR
        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                echo "Tagging Docker Image..."
                docker tag todo-app $ECR_URI:latest

                echo "Pushing Docker Image to AWS ECR..."
                docker push $ECR_URI:latest
                '''
            }
        }

        // 🟢 Deploy to EC2
        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ubuntu', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    echo "Deploying on EC2..."
                    ssh -tt -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST bash -c "
                    set -e
                    cd $APP_DIR

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
