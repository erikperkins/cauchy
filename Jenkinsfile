pipeline {
  agent {
    kubernetes {
      yaml """
        apiVersion: v1
        kind: Pod
        metadata:
          name: kaniko
          namespace: jenkins
        spec:
          containers:
            - name: elixir
              image: elixir:1.14.3-slim
              imagePullPolicy: Always
              command:
                - sleep
              args:
                - 1d
            - name: kaniko
              image: gcr.io/kaniko-project/executor:debug
              imagePullPolicy: Always
              command:
                - sleep
              args:
                - 1d
              volumeMounts:
               - name: kaniko
                 mountPath: /kaniko/.docker
          volumes:
            - name: kaniko
              secret:
                secretName: kaniko
      """
    }
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  environment {
      REPOSITORY = 'erikperkins'
      IMAGE = 'cauchy'
      TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
  }

  stages {
    stage('Test') {
      steps {
        container(name: 'elixir') {
          sh "mix local.hex --force"
          sh "mix local.rebar --force"
          sh "mix deps.get"
          sh "mix test --no-color"
        }
      }
    }
    stage('Build') {
      environment {
        DOCKERFILE = 'services/docker/prod/Dockerfile'
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh """#!/busybox/sh
            /kaniko/executor \
              --context `pwd` \
              --dockerfile ${DOCKERFILE} \
              --destination ${REPOSITORY}/${IMAGE}:${TAG} \
              --destination ${REPOSITORY}/${IMAGE}:latest
          """
        }
      }
    }
  }
}
