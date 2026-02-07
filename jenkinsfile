cat jenkinsfile
pipeline {
    agent {
        docker {
            image 'alqoseemi/runner-node-docker:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch to build')
    }

    stages {

        stage('Checkout') {
            steps {
                git url: "https://${credentials('github-username')}:${credentials('github-cred')}@github.com/myorg/node-app.git",
                    branch: "${params.BRANCH_NAME}"
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
                          -Dsonar.login=${credentials('sonarqube-id')}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
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


