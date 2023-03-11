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
  stages {

    stage('Test') {
      steps {
        container(name: 'jnlp') {
          sh """
            echo "Testing..."
          """
        }
      }
    }

    stage('Build') {
      environment {
        REPOSITORY = 'erikperkins'
        IMAGE = 'cauchy'
        DOCKERFILE = 'services/docker/prod/Dockerfile'
        SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh """#!/busybox/sh
            /kaniko/executor \
              --context `pwd` \
              --dockerfile ${DOCKERFILE} \
              --destination ${REPOSITORY}/${IMAGE}:${SHA}
          """
        }
      }
    }

    stage('Deploy') {
      // when { branch 'master' }
      steps {
        container(name: 'jnlp') {
          sh "echo `pwd`"
        }
      }
    }

  }
}
