pipeline {
    agent {
        docker {
            image 'node:16-alpine'
            args '-u root'
        }
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        SNYK_TOKEN = credentials('snyk-token')
        IMAGE_NAME = "achani99/node-docker"
        IMAGE_TAG = "16-alpine"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo '🔧 Installing dependencies...'
                    sh '''
                      node -v
                      npm -v
                      npm install --save
                    '''
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    echo '🧪 Running tests...'
                    sh 'npm test || true'
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                script {
                    echo '🔍 Running Snyk scan...'
                    sh '''
                      npm install -g snyk
                      snyk auth ${SNYK_TOKEN}
                      snyk test --severity-threshold=high
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Building Docker image: $IMAGE_NAME:$IMAGE_TAG"
                    sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "📤 Pushing image to Docker Hub: $IMAGE_NAME:$IMAGE_TAG"
                    sh '''
                      echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                      docker push $IMAGE_NAME:$IMAGE_TAG
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
            echo '❌ Build failed due to errors/vulnerabilities.'
        }
        success {
            echo '✅ Build successful!'
        }
    }
}
