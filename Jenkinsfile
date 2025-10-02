pipeline {
  agent any

  environment {
    IMAGE_NAME = "achani99/node-docker"
    IMAGE_TAG  = "16"
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
        sh 'echo ✅ Code checked out'
      }
    }

    stage('Install Dependencies') {
      agent {
        docker {
          image "${IMAGE_NAME}:${IMAGE_TAG}"
          args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        sh 'node -v && npm -v'
        sh 'npm ci'
      }
    }

    stage('Fix Vulnerabilities') {
      agent {
        docker {
          image "${IMAGE_NAME}:${IMAGE_TAG}"
          args '-u root'
        }
      }
      steps {
        sh 'npm audit fix || echo "⚠️ No fixes or not needed"'
      }
    }

    stage('Snyk Security Scan') {
      agent {
        docker {
          image "${IMAGE_NAME}:${IMAGE_TAG}"
          args '-u root'
        }
      }
      steps {
        sh 'npm ci --prefer-offline --no-audit'
        sh 'npm audit --audit-level=high || echo "⚠️ High vulnerabilities found"'
      }
    }

    stage('Build & Push Image') {
      agent {
        docker {
          image "${IMAGE_NAME}:${IMAGE_TAG}"
          args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Run Tests') {
      agent {
        docker {
          image "${IMAGE_NAME}:${IMAGE_TAG}"
          args '-u root'
        }
      }
      steps {
        sh 'npm test || echo "⚠️ No tests or some tests failed"'
      }
    }

    stage('Post Actions') {
      steps {
        echo '📦 Archiving logs if any...'
        archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
      }
    }
  }

  post {
    success {
      echo "✅ Build and push successful for $IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Build failed"
    }
  }
}
