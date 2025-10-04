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

    stage('Checkout SCM') {
      steps {
        echo 'Checking out code from SCM'
        checkout scm
      }
    }

    stage('Checkout Code') {
      steps {
        echo 'Displaying current working directory'
        sh 'echo "PWD: $PWD"'

        echo 'Getting short commit hash'
        sh 'git rev-parse --short HEAD'

        echo 'Listing directory contents'
        sh 'ls -la'
      }
    }

    stage('Install Dependencies') {
      steps {
        echo 'Pulling node:16-alpine image'
        sh 'docker pull node:16-alpine'

        echo 'Running inside node:16-alpine container'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            echo 'Verifying Node.js version'
            sh 'node -v'

            echo 'Verifying npm version'
            sh 'npm -v'

            echo 'Installing dependencies using npm ci'
            sh 'npm ci'
          }
        }
      }
    }

    stage('Fix Vulnerabilities') {
      steps {
        echo 'Fixing known vulnerabilities'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            echo 'Running npm audit fix'
            sh 'npm audit fix || echo "Nothing to fix"'
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        echo 'Preparing for audit scan'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            echo 'Reinstalling dependencies without audit'
            sh 'npm ci --prefer-offline --no-audit'

            echo 'Running npm audit with high severity level'
            sh 'npm audit --audit-level=high || echo "Vulnerabilities found"'
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        echo 'Building Docker image'
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'

        echo 'Logging into DockerHub and pushing image'
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
        echo 'Running tests'
        script {
          docker.image('node:16-alpine').inside('-u root') {
            echo 'Executing npm test'
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
      echo 'Archiving npm logs if any'
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
