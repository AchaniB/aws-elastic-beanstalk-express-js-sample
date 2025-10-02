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
