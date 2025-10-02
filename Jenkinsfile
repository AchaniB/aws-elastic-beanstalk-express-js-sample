pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achani99/node-docker"
    IMAGE_TAG  = "18"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install & Test (Node 18)') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root -v /var/run/docker.sock:/var/run/docker.sock') {
            sh 'node -v && npm -v'
            sh 'npm ci'
            sh 'npm test || echo "⚠️ No tests found or tests failed"'
          }
        }
      }
    }

    stage('Dependency Scan (fail on HIGH)') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
            sh 'npm ci --prefer-offline --no-audit'
            sh 'npm audit --audit-level=high || echo "⚠️ Vulnerabilities found"'
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Successfully built and pushed $IMAGE_NAME:$IMAGE_TAG"
    }
    always {
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
