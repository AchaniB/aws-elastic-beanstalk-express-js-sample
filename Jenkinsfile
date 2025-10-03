pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        SNYK_TOKEN = credentials('snyk-token')
        IMAGE_NAME = "achan99/node-docker"
        IMAGE_TAG  = "16-alpine"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Checkout Code') {
            steps {
                sh 'echo "✅ Code is now available in workspace: ${WORKSPACE}"'
                sh 'ls -la'
            }
        }

        stage('Install Dependencies') {
            agent {
                docker {
                    image "${IMAGE_NAME}:${IMAGE_TAG}"
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo '🔧 Installing dependencies...'
                    sh '''
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
                    echo '🔒 Running npm audit...'
                    sh '''
                      npm audit --audit-level=high || true
                    '''
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                script {
                    echo '🔍 Running Snyk security scan...'
                    sh '''
                      npm install -g snyk
                      snyk auth ${SNYK_TOKEN}
                      snyk test --severity-threshold=high || exit 1
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    echo '🐳 Building and pushing Docker image...'
                    sh '''
                      docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                      echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                      docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                      docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:${IMAGE_TAG}
                      docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Run Tests') {
            agent {
                docker {
                    image "${IMAGE_NAME}:${IMAGE_TAG}"
                    args '-u root'
                    reuseNode true
                }
            }
            steps {
                script {
                    echo '🧪 Running tests...'
                    sh '''
                      if npm run | grep -q "test"; then
                        npm test
                      else
                        echo "⚠️ No test script found in package.json, skipping tests."
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
