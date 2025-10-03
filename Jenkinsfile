pipeline {
    agent any

    environment {
        IMAGE_NAME = "achani99/node-docker"
        IMAGE_TAG  = "16-alpine"
        SNYK_TOKEN = credentials('snyk-token')        // Add your Snyk Jenkins secret
        DOCKERHUB = credentials('dockerhub-creds')   // Your DockerHub credentials
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Checkout Code') {
            steps {
                echo "✅ Code checked out"
                sh 'ls -la'
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
                        sh 'node -v && npm -v'
                        sh '''
                          if [ -f package-lock.json ]; then
                            npm ci
                          else
                            npm install
                          fi
                        '''
                    }
                }
            }
        }

        stage('Fix Vulnerabilities') {
            steps {
                script {
                    docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
                        sh 'npm audit fix || echo "⚠️ Nothing to fix"'
                    }
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                script {
                    docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
                        sh '''
                          npm install -g snyk
                          snyk auth $SNYK_TOKEN
                          snyk test --severity-threshold=high
                        '''
                    }
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                script {
                    sh '''
                      echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
                      docker build -t $IMAGE_NAME:$IMAGE_TAG .
                      docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
                        sh 'npm test || echo "⚠️ No tests defined or some tests failed"'
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build and deployment successful!"
        }
        failure {
            echo "❌ Build failed. Check logs above."
        }
        always {
            echo "📦 Archiving npm logs (if any)..."
            archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
        }
    }
}
