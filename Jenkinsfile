pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'nodejs16'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        
    }
    
    stages {
        stage('clean workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('checkout from git') {
            steps {
                git branch: 'main', url: 'https://github.com/Devnikops/youtube-clone-app.git'
            }            
        }

        stage('sonarqube analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Youtube-CICD \ -Dsonar.projectKey=Youtube-CICD '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker'){   
                      sh "docker build -t youtube-clone ."
                      sh "docker tag youtube-clone nikhil999999/youtube-clone:latest "
                      sh "docker push nikhil999999/youtube-clone:latest "
                    }
                }
            }
        }

        stage {
            steps('Trivy Image Scan') {
                sh "trivy image nikhil999999/youtube-clone:latest > trivyimage.txt"
            }
        }
    }
}