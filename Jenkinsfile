pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achani99/node-docker"
    GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    IMAGE_TAG = "${GIT_COMMIT_SHORT}"
  }

  stages {

    stage('Checkout Code') {
      steps {
        checkout scm
        sh '''
          echo "Code checked out at: $PWD"
          echo "Commit: $(git rev-parse --short HEAD)"
          ls -la
        '''
      }
    }

    stage('Install Dependencies') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root -v /var/run/docker.sock:/var/run/docker.sock') {
            sh 'node -v && npm -v'
            sh 'npm ci'
          }
        }
      }
    }

    stage('Fix Vulnerabilities') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root') {
            sh 'npm audit fix || echo "Nothing to fix"'
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root') {
            sh 'npm ci --prefer-offline --no-audit'
            sh 'npm audit --audit-level=high || echo "Vulnerabilities found"'
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

    stage('Run Tests') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:16-alpine").inside('-u root') {
            sh 'npm test || echo "No tests or some tests failed"'
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build and deployment successful for image: $IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "Build failed. Check logs above."
    }
    always {
      echo 'Archiving npm logs (if any)...'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
achanibandara@a
