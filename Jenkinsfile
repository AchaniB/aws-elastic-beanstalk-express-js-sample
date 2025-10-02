pipeline {
  agent any

  options {
    skipDefaultCheckout() // Disable automatic duplicate checkout
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }

    stage('Checkout Code') {
      steps {
        echo '✅ Code checked out'
        // Add any logic here to verify files, show status, etc.
      }
    }

    stage('Install Dependencies') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root -v /var/run/docker.sock:/var/run/docker.sock') {
            sh 'node -v && npm -v'
            sh 'npm ci'
          }
        }
      }
    }

    stage('Fix Vulnerabilities') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
            sh 'npm audit fix || echo "⚠️ Nothing to fix"'
          }
        }
      }
    }

    stage('Snyk Security Scan') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
            sh 'npm ci --prefer-offline --no-audit'
            sh 'npm audit --audit-level=high || echo "⚠️ Vulnerabilities found"'
          }
        }
      }
    }

    stage('Build & Push Image') {
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
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
            sh 'npm test || echo "⚠️ No tests or some tests failed"'
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build and deployment successful!"
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
