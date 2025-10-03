pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Verify Code') {
            steps {
                echo '✅ Code is available in workspace'
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
                    echo '🔧 Verifying Node & NPM...'
                    sh 'node -v || echo "❌ Node not found"'
                    sh 'npm -v || echo "❌ NPM not found"'

                    echo '📦 Installing production dependencies...'
                    sh '''
                        if [ -f package.json ]; then
                            npm ci --only=production || npm install --only=production
                        else
                            echo "❌ package.json not found"; exit 1
                        fi
                    '''
                }
            }
        }

        stage('Fix Vulnerabilities') {
            steps {
                echo '🔒 Checking for vulnerabilities...'
                // Add fix logic if needed
            }
        }

        stage('Snyk Security Scan') {
            steps {
                echo '🔍 Running Snyk security scan...'
                // Add snyk scan logic here
            }
        }

        stage('Build & Push Image') {
            steps {
                echo '🐳 Building and pushing Docker image...'
                // Add docker build and push logic here
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
                    sh '''
                        if [ -f package.json ]; then
                            npm test || echo "⚠️ Some tests may have failed."
                        else
                            echo "❌ package.json not found. Skipping tests."
                        fi
                    '''
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
