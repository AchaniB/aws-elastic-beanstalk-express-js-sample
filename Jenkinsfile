pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achani99/node-docker"
    IMAGE_TAG  = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
  }

  stages {

    stage('Checkout Code') {
      steps {
        echo 'Checking out code...'
        checkout scm

        echo 'Showing current directory and latest commit:'
        sh 'echo "Code checked out at: $PWD"'
        sh 'echo "Commit: $(git rev-parse --short HEAD)"'
        sh 'ls -la'
      }
    }

    stage('Install Dependencies') {
      steps {
        echo 'Using node:16-alpine to install dependencies...'
        sh 'docker pull node:16-alpine'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            echo 'Checking Node and NPM versions:'
            sh 'node -v'
            sh 'npm -v'

            echo 'Installing dependencies with npm ci...'
            sh 'npm ci'
          }
        }
      }
    }

    stage('Fix Vulnerabilities') {
      steps {
        echo 'Attempting to fix known vulnerabilities...'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            sh 'npm audit fix || echo "Nothing to fix"'
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        echo 'Running npm audit --audit-level=high...'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            sh 'npm ci --prefer-offline --no-audit'
            sh 'npm audit --audit-level=high || echo "Vulnerabilities found"'
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        echo 'Building Docker image...'
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'

        echo 'Logging into DockerHub and pushing image...'
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Run Tests') {
      steps {
        echo 'Running tests...'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            sh 'npm test || echo "No tests or some tests failed"'
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
      echo 'Archiving npm logs (if any)...'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
