pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achani99/node-docker"
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
        script {
          env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.IMAGE_TAG = env.GIT_COMMIT_SHORT
        }
        sh '''
          echo "✅ Code checked out at: $PWD"
          echo "🔢 Commit: $GIT_COMMIT_SHORT"
          ls -la
        '''
      }
    }

    stage('Install Dependencies') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root -v /var/run/docker.sock:/var/run/docker.sock') {
            sh 'node -v && npm -v'
            // Assignment requires npm install, not ci
            sh 'npm install --save'
          }
        }
      }
    }

    stage('Run Unit Tests') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root') {
            sh 'npm test'
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          script {
            docker.image("${IMAGE_NAME}:16-alpine").inside('-u root') {
              sh '''
                npm install -g snyk
                snyk auth $SNYK_TOKEN
                # fail build on high/critical issues
                snyk test --severity-threshold=high
              '''
            }
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
              docker push $IMAGE_NAME:$IMAGE_TAG
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build and deployment successful for image: $IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Build failed. Check logs above."
    }
    always {
      echo '📦 Archiving npm logs (if any)...'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
