pipeline {
    agent { label 'docker-agent-label' }  // Adjust the agent label if needed

    environment {
        EC2_USER = 'ubuntu'  
        EC2_HOST = '13.201.78.62'  // Deployment server IP
        APP_DIR = '/home/ubuntu/todo-app'  // Deployment directory
        PYTHON_BIN = '/usr/bin/python3'
        DJANGO_MANAGE = 'manage.py'  // Django management script
    }

    stages {
        stage('Clone Repository') {
            steps {
                sshagent(['ubuntu']) {  // Using Jenkins credentials ID "ubuntu"
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                    if [ ! -d "$APP_DIR" ]; then
                        git clone https://github.com/sakethravikanti/django-on-ec2.git $APP_DIR
                    else
                        cd $APP_DIR
                        git pull origin develop
                    fi
                    EOF
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                    sudo apt update -y
                    sudo apt install python3-pip python3-venv -y
                    cd $APP_DIR
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    EOF
                    '''
                }
            }
        }

        stage('Run Pylint Checks') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source venv/bin/activate
                    pylint $(find . -name "*.py") || true
                    EOF
                    '''
                }
            }
        }

        stage('Run Migrations & Collect Static Files') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source venv/bin/activate
                    python $DJANGO_MANAGE migrate
                    python $DJANGO_MANAGE collectstatic --noinput
                    EOF
                    '''
                }
            }
        }

        stage('Deploy with Uvicorn') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source venv/bin/activate
                    
                    # Kill any existing process on port 8000
                    fuser -k 8000/tcp || true
                    
                    # Run the application using Uvicorn
                    nohup uvicorn myproject.asgi:application --host 0.0.0.0 --port 8000 --reload > app.log 2>&1 &
                    EOF
                    '''
                }
            }
        }
    }

    triggers {
        githubPush()  // Auto-trigger pipeline on GitHub push
    }
}
