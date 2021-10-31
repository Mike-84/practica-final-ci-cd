

pipeline {
    agent {
        label 'master'
    }

    stages {
        stage('Frontend: instalar dependencias'){
            steps {
                script {
                    sh '''
                    cd frontend
                    npm install
                    '''
                }
            }
        }

        stage('Frontend: ejecutar linters'){
            steps {
                script {
                    sh '''
                    cd frontend
                    npm run lint
                    '''
                }
            }
        }

        stage ('Tests frontend'){
            parallel {
              stage('test unitario') {
                  steps {
                      script {
                          sh '''
                          cd frontend
                          npm run unit
                          '''
                      }

                  }
              }
              stage('test de integración') {
                  steps {
                      script {
                          sh '''
                          cd frontend
                          npm run e2e
                          '''
                      }
                  }
              }
            }
        }

        stage ('contenido estático y nginx') {
            steps {
                script {
                    sh '''
                    cd frontend
                    npm run build
                    '''
                }
            }
        }

        stage('Publicar imagen frontend a nexus') {
            steps{
              script{
                sh "cd frontend"
                sh "docker build --no-cache -t frontend-test:1.0.0 ."
                sh "docker login -u admin -p admin localhost:8082"
                sh "docker image tag frontend-test:1.0.0 localhost:8082/frontend-test:1.0.0"
                sh "docker image push localhost:8082/frontend-test:1.0.0"
              }
            }
        }



        stage('Backend: ejecutar linters flake8 y hadolint') {
            steps {
                script {
                    sh "cd backend"
                    sh "docker run -i --rm -v ${pwd}:/apps alpine/flake8:3.5.0 --max-line-length=120 *.py"
                    sh '''
                    cd backend
                    docker run --rm -i hadolint/hadolint < Dockerfile
                    '''
                }
            }
        }

        stage('Backend: test unitarios') {
            steps {
                script {
                    sh '''
                    cd backend
                    docker build --no-cache -t backend-test -f Dockerfile.test ."
                    '''
                    sh "docker run -i --name backend-test backend-test"
                    sh "docker cp backend-test:/app/test_results.xml ./test_results.xml"
                    sh "docker rm backend-test"
                    sh "cat test_results.xml"
                }
            }
        }

        stage('Publicar imagen backend a nexus') {
            steps{
              script{
                  sh "cd backend"
                  sh "docker build --no-cache -t backend-test:1.0.0 ."
                  sh "docker login -u admin -p admin localhost:8082"
                  sh "docker image tag backend-test:1.0.0 localhost:8082/backend-test:1.0.0"
                  sh "docker image push localhost:8082/backend-test:1.0.0"
              }
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        }
    }
}
