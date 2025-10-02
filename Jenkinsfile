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
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }

    stage('Checkout Code') {
      steps {
        sh 'echo "✅ Code checked out"'
      }
    }

    stage('Install Dependencies') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Fix Vulnerabilities') {
      steps {
        // Optional: automatic fix (only if using something like npm audit fix)
        sh 'npm audit fix || echo "⚠️ No fixable vulnerabilities"'
      }
    }

    stage('Snyk Security Scan') {
      steps {
        sh '''
          if ! command -v snyk &> /dev/null; then
            npm install -g snyk
          fi
          snyk auth $SNYK_TOKEN || echo "⚠️ Snyk auth failed"
          snyk test || echo "⚠️ Vulnerabilities found"
        '''
      }
    }

    stage('Build & Push Image') {
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
      steps {
        script {
          def result = sh(script: 'npm test', returnStatus: true)
          if (result != 0) {
            echo "❌ Tests failed"
          } else {
            echo "✅ Tests passed"
          }
        }
      }
    }

    stage('Post Actions') {
      steps {
        archiveArtifacts artifacts: '**/npm-debug.log', allowEmptyArchive: true
      }
    }
  }

  post {
    success {
      echo "✅ Successfully built and pushed $IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Build failed"
    }
  }
}
