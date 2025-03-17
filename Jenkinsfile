pipeline {
    agent { label 'docker-agent-label' }  // Ensure correct agent label

    environment {
        EC2_USER = 'ubuntu'  
        EC2_HOST = '13.201.78.62'  // Deployment server IP
        SSH_KEY = '/var/lib/jenkins/.ssh/id_rsa'  // Path to private key
        APP_DIR = '/home/ubuntu/todo-app'  // Deployment directory
        DJANGO_MANAGE = 'manage.py'  // Django management script
        VENV_DIR = '${APP_DIR}/venv'  // Virtual environment directory
        UVICORN_CMD = '${VENV_DIR}/bin/uvicorn'
    }

    stages {
        stage('Clone Repository') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    if [ ! -d "$APP_DIR" ]; then
                        git clone git@github.com:sakethravikanti/django-on-ec2.git $APP_DIR
                    else
                        cd $APP_DIR
                        git pull origin main
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
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    sudo apt update -y
                    sudo apt install python3-pip python3-venv -y
                    cd $APP_DIR
                    if [ ! -d "$VENV_DIR" ]; then
                        python3 -m venv venv
                    fi
                    source $VENV_DIR/bin/activate
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
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source $VENV_DIR/bin/activate
                    pylint --fail-under=7 $(find . -name "*.py" ! -path "./venv/*") || true
                    EOF
                    '''
                }
            }
        }

        stage('Run Migrations & Collect Static Files') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source $VENV_DIR/bin/activate
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
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source $VENV_DIR/bin/activate
                    pkill -f "uvicorn" || true  # Stop any running Uvicorn instance
                    nohup $UVICORN_CMD myproject.asgi:application --host 0.0.0.0 --port 8000 > app.log 2>&1 &
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
