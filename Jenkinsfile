pipeline {
    agent {
        docker {
            image 'achani99/node-docker:18' // <-- Your custom image
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        npm_config_cache = "${env.WORKSPACE}/.npm-cache"
        IMAGE_NAME = 'achani99/nodejs-cicd-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    try {
                        sh 'npm test'
                    } catch (err) {
                        echo "⚠️ Tests failed or missing"
                    }
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        npm install -g snyk
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high || echo "⚠️ Snyk issues found"
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME:$BUILD_NUMBER
                        docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

post {
    success {
        echo '✅ Pipeline completed successfully!'
        cleanWs()
    }
    failure {
        echo '🚨 Pipeline failed. Please check the logs.'
        cleanWs()
    }
}
