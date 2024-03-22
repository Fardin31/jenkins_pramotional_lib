def call(body) {
    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()
pipeline {
    agent any

    parameters {
        choice(name: 'account', choices: ['dev', 'qa', 'stage', 'prod'], description: 'Select the environment.')
        string(name: 'commit_id', defaultValue: 'latest', description: 'Provide commit id.')
    }

    environment {
        //Commnon
        ACCOUNT = "${params.account}"
        COMMITID = "${params.commit_id}"
        DOCKER_REGISTRY_URL = "https://registry.hub.docker.com/fardin31"

        //FOR DEV
        DEV_IMAGE_NAME = "fardin31/dev"
        DEV_CREDENTIALS = "dev_dh_cred"
        DEV_CONFIG      =  "dev_kube_config"

        //FOR QA
        QA_IMAGE_NAME = "fardin31/qa"
        QA_CREDENTIALS = "qa_dh_cred"
        QA_CONFIG       =  "qa_kube_config"

        //FOR STAGE
        STAGE_IMAGE_NAME = "fardin31/stage"
        STAGE_CREDENTIALS = "stage_dh_cred"
        STAGE_CONFIG    =   "stage_kube_config"

        //FOR PROD
        PROD_IMAGE_NAME = "fardin31/prod"
        PROD_CREDENTIALS = "prod_dh_cred"
        PROD_CONFIG     =  "prod_kube_config"
    }

    stages {
        stage('Docker Image Build IN Dev') {
            when {
                expression {
                    params.account == 'dev'
                }
            } 
            steps {
                echo "Building Docker Image Logging in to Docker Hub & Pushing the Image" 
                script {
                    def app = docker.build("${DEV_IMAGE_NAME}:${env.COMMITID}")
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/${ACCOUNT}", "${env.DEV_CREDENTIALS}") {
                        app.push()
                    }
                }
                sh 'echo Image Pushed to DEV'
                sh 'echo Deleting Local docker DEV Image'
                sh "docker rmi ${DEV_IMAGE_NAME}:${env.COMMITID}"
            }
        }

        stage('Pull Tag push to QA') {
            when {
                expression {
                    params.account == 'qa'
                }
            } 
            steps {
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/${ACCOUNT}", "${env.QA_CREDENTIALS}") {
                        docker.image("${DEV_IMAGE_NAME}:${env.COMMITID}").pull()
                    }
                }
                sh 'echo Image pulled from DEV'
                sh 'echo Tagging Docker image from Dev to QA'
                sh "docker tag ${DOCKER_REGISTRY_URL}/dev:${env.COMMITID} ${QA_IMAGE_NAME}:${env.COMMITID}" 
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/qa", "${env.QA_CREDENTIALS}") {
                        docker.image("${QA_IMAGE_NAME}:${env.COMMITID}").push()
                    }
                }
                sh 'echo Image Pushed to QA'
                sh 'echo Deleting Local docker Images'
                sh "docker rmi ${DOCKER_REGISTRY_URL}/qa:${env.COMMITID}"
            }
        }

        stage('Pull Tag push to stage') {
            when {
                expression {
                    params.account == 'stage'
                }
            } 
            steps {
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/qa", "${env.QA_CREDENTIALS}") {
                        docker.image("${QA_IMAGE_NAME}:${env.COMMITID}").pull()
                    }
                }
                sh 'echo Image pulled from QA'
                sh 'echo Tagging Docker image from QA to Stage'
                sh "docker tag ${QA_IMAGE_NAME}:${env.COMMITID} ${STAGE_IMAGE_NAME}:${env.COMMITID}" 
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/stage", "${env.STAGE_CREDENTIALS}") {
                        docker.image("${STAGE_IMAGE_NAME}:${env.COMMITID}").push()
                    }
                }
                sh 'echo Image Pushed to STAGE'
                sh 'echo Deleting Local docker Images'
                sh "docker rmi ${STAGE_IMAGE_NAME}:${env.COMMITID}"
            }
        }

        stage('Pull Tag push to Prod') {
            when {
                expression {
                    params.account == 'prod'
                }
            }  
            steps {
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/stage", "${env.STAGE_CREDENTIALS}") {
                        docker.image("${STAGE_IMAGE_NAME}:${env.COMMITID}").pull()
                    }
                }
                sh 'echo Image pulled from QA'
                sh 'echo Taggig Docker image from stage to prod'
                sh "docker tag ${STAGE_IMAGE_NAME}:${env.COMMITID} ${PROD_IMAGE_NAME}:${env.COMMITID}" 
                script {
                    docker.withRegistry("${DOCKER_REGISTRY_URL}/stage", "${env.PROD_CREDENTIALS}") {
                        docker.image("${PROD_IMAGE_NAME}:${env.COMMITID}").push()
                    }
                }
                sh 'echo Image Pushed to Prod'
                sh 'echo Deleting Local docker Images'
                sh "docker rmi ${PROD_IMAGE_NAME}:${env.COMMITID}"
            }
        }
    }
     stage('DEPLOY TO K8S DEV') {
            when {
                expression {
                    params.account == 'dev'
                }
            }
            steps {

                deployOnK8s(env.DEV_CONFIG , env.ACCOUNT , env.COMMITID)

            }
        }
        stage('DEPLOY TO K8S QA') {
            when {
                expression {
                    params.account == 'qa'
                }
            }
            steps {

                deployOnK8s(env.QA_CONFIG , env.ACCOUNT , env.COMMITID)

            }
        }
        stage('DEPLOY TO K8S STAGE') {
            when {
                expression {
                    params.account == 'stage'
                }
            }
            steps {

                deployOnK8s(env.STAGE_CONFIG , env.ACCOUNT , env.COMMITID)

            }
        }
        stage('DEPLOY TO K8S PROD') {
            when {
                expression {
                    params.account == 'prod'
                }
            }
            steps {

                deployOnK8s(env.PROD_CONFIG , env.ACCOUNT , env.COMMITID)

            }
        }

    }
def deployOnK8s(String KUBE_CONFIG, String ACCOUNT, String COMMIT) {

    withKubeConfig(credentialsId: "${KUBE_CONFIG}", restrictKubeConfigAccess: true) {

        sh 'echo Deploying application on ${ACCOUNT} K8S cluster'
        sh 'echo Replacing K8S manifests files with sed....'
        sh "sed -i -e 's/{{ACCOUNT}}/${ACCOUNT}/g' -e 's/{{COMMITID}}/${COMMIT}/g' KUBE/*"
        sh 'echo K8S manifests files after replace with sed ...'
        sh 'cat KUBE/deployment.yaml'
        sh 'kubectl apply -f KUBE/.'
	    
    }
	
}
    post { 
        always { 
            echo 'Deleting Project now !! '
            deleteDir()
        }
    }
}
