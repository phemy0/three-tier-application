pipeline {
    agent any   // run directly on Jenkins server

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch to build')
    }

    tools {
        nodejs "NodeJS 18"   // configure this in Global Tool Configuration
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH_NAME}",
                    url: 'https://github.com/myorg/node-app.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build & Test') {
            steps {
                sh '''
                    npm ci
                    npm test
                '''
            }
        }

        stage('SonarQube') {
            steps {
                withSonarQubeEnv('MySonarQubeServer') {
                    sh """
                        npx sonar-scanner \
                          -Dsonar.projectKey=node-app \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://100.53.185.191:9000 \
                          -Dsonar.login=${credentials('sonarqube_id')}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
                        IMAGE_NAME="myrepo/myimage"
                        IMAGE_TAG="${TIMESTAMP}-build${BUILD_NUMBER}"
                        docker build -t $IMAGE_NAME:$IMAGE_TAG .
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
