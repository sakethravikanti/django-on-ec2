pipeline {
    agent { label 'docker-agent-label' } // Change to your actual node label

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', url: 'https://github.com/sakethravikanti/django-on-ec2.git'
            }
        }

        stage('Code Analysis') {
            steps {
                echo 'Running code analysis...'
                sleep 2 // Simulating code analysis
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sleep 3 // Simulating build process
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sleep 2 // Simulating test execution
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo 'Deploying to staging environment...'
                sleep 3 // Simulating deployment
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Performing cleanup tasks...'
                sleep 1 // Simulating cleanup
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
