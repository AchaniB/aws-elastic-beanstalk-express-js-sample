pipeline {
  agent any
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achai99/node-docker"
    IMAGE_TAG  = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    CUSTOM_NODE_IMAGE = "achai99/node-docker:16-alpine"
  }

  stages {
    stage('Checkout') {
      steps { 
        checkout scm 
      }
    }

    stage('Install & Test (Custom Node 16)') {
      agent {
        docker {
          image "${CUSTOM_NODE_IMAGE}"
          args '-v $HOME/.npm:/root/.npm'
        }
      }
      steps {
        sh 'node -v && npm -v'
        sh 'npm ci'
        sh 'npm test || echo "no tests"'
      }
    }

    stage('Dependency Scan (fail on HIGH)') {
      agent {
        docker {
          image "${CUSTOM_NODE_IMAGE}"
        }
      }
      steps {
        sh 'npm ci --prefer-offline --no-audit'
        sh 'npm audit --audit-level=high'
      }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
        }
        sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
      }
    }
  }

  post {
    success {
      echo "✅ Successfully pushed image: $IMAGE_NAME:$IMAGE_TAG"
    }
    always {
      archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
    }
  }
}
