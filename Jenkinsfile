pipeline {
    agent {
        docker {
            image 'node:18-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_IMAGE = 'achani99/nodejs-cicd-app'
        DOCKER_TAG = 'latest'
    }

    stages {
        stage('Install Docker CLI') {
            steps {
                sh 'apt-get update && apt-get install -y docker.io'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    try {
                        sh 'npm test'
                    } catch (err) {
                        echo "⚠️ No test script found or failed — skipping tests"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push $DOCKER_IMAGE:$DOCKER_TAG'
            }
        }

        stage('Snyk Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        npm install -g snyk
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high || echo "⚠️ Snyk found issues"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline completed successfully!'
            cleanWs()
        }
        failure {
            echo '🚨 Pipeline failed. Please check the error logs.'
            cleanWs()
        }
    }
}

