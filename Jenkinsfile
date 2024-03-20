pipeline {
    agent any
    stages {
        stage('Docker Image Build IN Dev') {
            when {
                branch 'dev'
            }
            steps {
                echo "Building Docker Image Logging in to Docker Hub & Pushing the Image" 
                script {
                    def app = docker.build("fardin31/dev:v1")
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/dev', 'dev_dh_cred') {
                    app.push()
                    }
                }
                sh 'echo Image Pushed to DEV'
                sh 'echo Deleting Local docker DEV Image'
            }
        }
        stage('Pull Tag push to QA') {
            when {
                branch 'qa'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/dev', 'dev_dh_cred') {
                    docker.image("fardin31/dev:v1").pull()
                    }
                }
                sh 'echo Image pulled from DEV'
                sh 'echo Taggig Docker image from Dev to QA'
                sh "docker tag fardin31/dev:v1  fardin31/qa:v1" 
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/qa', 'qa_dh_cred') {
                    docker.image("fardin31/qa:v1").push()
                    }
                }
                sh 'echo Image Pushed to QA'
                sh 'echo Deleting Local docker Images'
            }
        }
        stage('Pull Tag push to stage') {
            when {
                branch 'stage'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/qa', 'qa_dh_cred') {
                    docker.image("fardin31/qa:v1").pull()
                    }
                }
                sh 'echo Image pulled from QA'
                sh 'echo Taggig Docker image from QA to Stage'
                sh "docker tag fardin31/qa:v1  fardin31/stage:v1" 
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/stage', 'stage_dh_cred') {
                    docker.image("fardin31/stage:v1").push()
                    }
                }
                sh 'echo Image Pushed to STAGE'
                sh 'echo Deleting Local docker Images'
            }
        }
        stage('Pull Tag push to Prod') {
            when {
                branch 'prod'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/stage', 'stage_dh_cred') {
                    docker.image("fardin31/stage:v1").pull()
                    }
                }
                sh 'echo Image pulled from QA'
                sh 'echo Taggig Docker image from stage to prod'
                sh "docker tag fardin31/stage:v1  fardin31/prod:v1" 
                script {
                    docker.withRegistry('https://registry.hub.docker.com/fardin31/stage', 'prod_dh_cred') {
                    docker.image("fardin31/prod:v1").push()
                    }
                }
                sh 'echo Image Pushed to Prod'
                sh 'echo Deleting Local docker Images'
            }
        }
    }
    post { 
        always { 
            echo 'Deleting Project now !! '
            deleteDir()
        }
    }
}

