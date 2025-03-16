pipeline {
    agent { label 'docker-agent-label' } // Ensure this matches your Jenkins agent label
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cloning repository...'
                checkout([$class: 'GitSCM', 
                    branches: [[name: '*/develop']], 
                    userRemoteConfigs: [[
                        url: 'https://github.com/sakethravikanti/django-on-ec2.git', 
                        credentialsId: 'todo-token' // Make sure this is set up in Jenkins credentials
                    ]]
                ])
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
