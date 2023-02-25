pipeline {
  agent any
  environment {
    SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
  }
  options {
    skipStagesAfterUnstable()
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  stages {
    stage('Echo') {
      steps {
        script {
          echo "$SHA"
        }
      }
    }
  }
  post {
    always {
      node(null) {
        cleanWs()
      }
    }
  }
}
