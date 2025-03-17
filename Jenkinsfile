pipeline {
    agent { label 'docker-agent-label' }  // Update with your actual agent label

    environment {
        EC2_USER = 'ubuntu'  
        EC2_HOST = '13.201.78.62'  // Replace with your deployment server IP
        SSH_KEY = '/var/lib/jenkins/.ssh/id_rsa'  // Path to the private key
        APP_DIR = '/home/ubuntu/todo-app'  // Deployment directory
        PYTHON_BIN = '/usr/bin/python3'
        DJANGO_MANAGE = 'manage.py'  // Django management script
    }

    stages {
        stage('Clone Repository') {
stage('Clone Repository') {
    steps {
        sshagent(['github-token-key']) {  // Ensure this matches the credential ID in Jenkins
            sh '''
            ssh -o StrictHostKeyChecking=no -i $SSH_KEY git@github.com
            git clone git@github.com:sakethravikanti/django-on-ec2.git $APP_DIR
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
                    python3 -m venv venv
                    source venv/bin/activate
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
                    source venv/bin/activate
                    pylint $(find . -name "*.py") || true  # Run pylint on all Python files
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
                    source venv/bin/activate
                    python $DJANGO_MANAGE migrate  # Apply database migrations
                    python $DJANGO_MANAGE collectstatic --noinput  # Collect static files
                    EOF
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST << EOF
                    cd $APP_DIR
                    source venv/bin/activate
                    nohup python $DJANGO_MANAGE runserver 0.0.0.0:8000 > app.log 2>&1 &
                    EOF
                    '''
                }
            }
        }
    }
}
