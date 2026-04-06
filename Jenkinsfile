pipeline {
    agent any

       environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = 'mlops-project-491208'
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
        KUBECTL_AUTH_PLUGIN = "/usr/lib/google-cloud-sdk/bin"
    }

    stages {
        stage("Cloning from Github...."){
            steps {
                script {
                    echo "Cloning from Github...."
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-token', url: 'https://github.com/ndiaye429/anime-recommadation-system.git']])

                }
            }

        }
        
       stage("Making a virtual environment...."){
            steps{
                script{
                    echo 'Making a virtual environment...'
                    sh '''
                    python -m venv ${VENV_DIR}
                    . ${VENV_DIR}/bin/activate
                    pip install --upgrade pip
                    pip install -e .
                    pip install  dvc
                    '''
                }
            }
        }

            stage('DVC Pull'){
                steps{
                  sh '''
                         echo 'DVC Pul....'
                        . ${VENV_DIR}/bin/activate
                        dvc pull
                        '''
                    }
                }

            stage('Build and Push Docker Image') {
                steps {
                sh '''
                echo "Setting GCP project..."

                export PATH=$PATH:${GCLOUD_PATH}

                gcloud config set project ${GCP_PROJECT}

                echo "Configuring Docker authentication..."

                gcloud auth configure-docker --quiet

                echo "Building Docker image..."

                docker build -t gcr.io/${GCP_PROJECT}/ml-project:latest .

                echo "Pushing Docker image to Container Registry..."

                docker push gcr.io/${GCP_PROJECT}/ml-project:latest
                '''
            }
        }

          stage('Deploying to Kubernetes'){
                steps{
                    sh '''
                    echo 'Deploying to Kubernetes'
                    export PATH=$PATH:${GCLOUD_PATH}:${KUBECTL_AUTH_PLUGIN}
                    gcloud config set project ${GCP_PROJECT}
                    gcloud container clusters get-credentials ml-app-cluster --region us-central1
                    kubectl apply -f deployment.yaml
                    '''

            }
        }

    }
}