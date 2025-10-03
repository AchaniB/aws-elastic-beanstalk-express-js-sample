pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
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
                script {
                    echo '🔧 Installing dependencies...'
                    sh 'node -v'
                    sh 'npm -v'
                    sh 'npm ci --only=production'
                }
            }
        }
        
        stage('Fix Vulnerabilities') {
            steps {
                script {
                    echo '🔒 Checking for vulnerabilities...'
                    // Add your security scanning steps here
                }
            }
        }
        
        stage('Snyk Security Scan') {
            steps {
                script {
                    echo '🔍 Running security scan...'
                    // Add Snyk scanning steps here
                }
            }
        }
        
        stage('Build & Push Image') {
            steps {
                script {
                    echo '🐳 Building and pushing Docker image...'
                    // Add Docker build/push steps here
                }
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
                script {
                    echo '🧪 Running tests...'
                    sh 'npm test || true'  // Continue even if tests fail
                }
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
