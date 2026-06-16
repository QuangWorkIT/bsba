pipeline {
    agent any

    stages {
        stage('Checkout dev') {
            steps {
                git branch: 'dev',
                    url: 'https://github.com/QuangWorkIT/bsba.git'
            }
        }

        stage('Build Spring Boot') {
            steps {
                dir('bsba_be') {
                    sh './mvnw clean compile'
                }
            }
        }

        stage('Test Spring Boot') {
            steps {
                dir('bsba_be') {
                    sh './mvnw test'
                }
            }
        }
    }
}