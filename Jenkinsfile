pipeline {
  agent any
  environment {
    imageName = 'erikperkins/cauchy'
    SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    registryCredential = 'dockerhub-credentials'
    testImage = ''
    dockerImage = ''
    defaultContext = "arn:aws:eks:us-west-2:822987764804:cluster/kluster"
  }
  options {
    skipStagesAfterUnstable()
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  stages {
    stage('Test') {
      agent any
      steps {
        script {
          testImage = docker.build("$imageName:test", "-f services/docker/test/Dockerfile .")
          sh "docker run -t --rm $imageName:test mix test --no-color"
        }
      }
    }
    stage('Build') {
      agent any
      steps {
        script {
          dockerImage = docker.build(imageName, "-f services/docker/prod/Dockerfile .")
        }
      }
    }
    stage('Deliver') {
      agent any
      steps {
        script {
          docker.withRegistry('', registryCredential) {
            dockerImage.push("$SHA")
          }
        }
      }
    }
    stage('Deploy') {
      when { branch 'master' }
      steps {
        script {
          withKubeConfig([credentialsId: "kube-config", contextName: defaultContext]) {
            sh "kubectl set image deployment/cauchy cauchy=erikperkins/cauchy:$SHA"
          }
        }
      }
    }
  }
  post {
    always {
      node(null) {
        sh "docker image rm $imageName:$SHA"
        sh "docker image rm $imageName:test"
        cleanWs()
      }
    }
  }
}
