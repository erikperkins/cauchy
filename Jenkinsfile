pipeline {
  agent any
  environment {
    imageName = 'erikperkins/cauchy'
    SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    registryCredential = 'dockerhub-credentials'
    dockerImage = ''
    defaultContext= "arn:aws:eks:us-west-2:822987764804:cluster/kluster"
  }
  options {
    skipStagesAfterUnstable()
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  stages {
    stage('Clone') {
      agent any
      steps {
        script {
          checkout scm
        }
      }
    }
    stage('Build') {
      agent any
      steps {
        script {
          dockerImage = docker.build(imageName)
        }
      }
    }
    stage('Test') {
      agent any
      steps {
        script {
          echo 'Testing...'
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
        cleanWs()
      }
    }
  }
}
