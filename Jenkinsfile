pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        SNYK_TOKEN = credentials('snyk-token')
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
                    image 'achani99/node-docker:16-alpine'
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
            agent {
                docker {
                    image 'achani99/node-docker:16-alpine'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo '🔒 Running npm audit fix...'
                    sh 'npm audit fix || true'
                }
            }
        }

        stage('Snyk Security Scan') {
            agent {
                docker {
                    image 'achani99/node-docker:16-alpine'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo '🔍 Running Snyk scan...'
                    // Install snyk CLI inside container
                    sh 'npm install -g snyk'
                    // Authenticate using Jenkins credential
                    sh 'snyk auth ${SNYK_TOKEN}'
                    // Run the scan
                    sh 'snyk test || true'
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    echo '🐳 Building and pushing Docker image...'
                    sh '''
                      docker build -t achani99/node-docker:latest .
                      echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                      docker push achani99/node-docker:latest
                    '''
                }
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image 'achani99/node-docker:16-alpine'
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo '🧪 Running tests...'
                    sh 'npm test || true'
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
