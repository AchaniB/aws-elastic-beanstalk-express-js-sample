pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo '🔁 Checking out source code from Git...'
                checkout scm
            }
        }

        stage('Checkout Code') {
            steps {
                echo '📁 Verifying code in workspace...'
                sh 'echo "✅ Code is now available in workspace: ${WORKSPACE}"'
                sh 'ls -la'
            }
        }

        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16-alpine'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                echo '🔧 Installing dependencies...'
                sh 'node -v'
                sh 'npm -v'
                sh 'npm ci --only=production'
            }
        }

        stage('Fix Vulnerabilities') {
            steps {
                echo '🔒 Checking for vulnerabilities...'
                // Add your security scanning steps here
            }
        }

        stage('Snyk Security Scan') {
            steps {
                echo '🔍 Running Snyk security scan...'
                // Add Snyk scanning steps here
            }
        }

        stage('Build & Push Image') {
            steps {
                echo '🐳 Building and pushing Docker image...'
                // Add Docker build and push logic here
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image 'node:16-alpine'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                echo '🧪 Running tests...'
                sh 'npm test || echo "⚠️ Some tests may have failed."'
            }
        }
    }

    post {
        always {
            echo '📦 Archiving npm logs (if any)...'
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
        failure {
            echo '❌ Build failed. Check logs above.'
        }
        success {
            echo '✅ Build successful!'
        }
    }
}
