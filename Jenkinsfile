pipeline {
  agent any
  options {
    skipStagesAfterUnstable()
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  stages {
    stage('Echo') {
      echo "echo"
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
