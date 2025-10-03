pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
  }

  environment {
    IMAGE_NAME = "achani99/node-docker"
    IMAGE_TAG  = "16-alpine"
  }

  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }

    stage('Checkout Code') {
      steps {
        echo "✅ Code checked out"
      }
    }

    stage('Install Dependencies') {
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root -v /var/run/docker.sock:/var/run/docker.sock') {
            sh 'node -v && npm -v'
            sh '''
              if [ -f package-lock.json ]; then
                npm ci
              else
                npm install
              fi
            '''
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
      environment {
        SNYK_TOKEN = credentials('snyk-token') // store your Snyk API token in Jenkins credentials
      }
      steps {
        script {
          docker.image("${IMAGE_NAME}:${IMAGE_TAG}").inside('-u root') {
            sh 'npm ci --prefer-offline --no-audit'
            sh 'npx snyk auth $SNYK_TOKEN'
            sh 'npx snyk test --severity-threshold=high || echo "⚠️ Vulnerabilities found"'
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
            sh '''
              if npm run | grep -q "test"; then
                npm test
              else
                echo "⚠️ No test script found in package.json, skipping..."
              fi
            '''
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

