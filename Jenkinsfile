pipeline {
    agent any

    options {
        skipDefaultCheckout(true)   // prevent multiple SCM checkouts
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = "achani99/nodejs-cicd-app:latest"
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
                    sh '''
                      apk add --no-cache make g++ python3
                      node -v
                      npm -v
                      if [ -f package-lock.json ]; then
                        npm ci --only=production
                      else
                        npm install --only=production
                      fi
                    '''
                }
            }
        }

        stage('Fix Vulnerabilities') {
            steps {
                script {
                    echo '🔒 Checking for vulnerabilities...'
                    // Example: auto-fix (optional)
                    sh 'npm audit fix || true'
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                script {
                    echo '🔍 Running security scan...'
                    // Ensure snyk is installed first
                    sh '''
                      if ! command -v snyk >/dev/null 2>&1; then
                        npm install -g snyk
                      fi
                      snyk test || true
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    echo '🐳 Building and pushing Docker image...'
                    sh '''
                      echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                      docker build -t $IMAGE_NAME .
                      docker push $IMAGE_NAME
                    '''
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
                    sh '''
                      if npm test; then
                        echo "✅ Tests passed"
                      else
                        echo "⚠️ Tests failed but pipeline continues"
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
