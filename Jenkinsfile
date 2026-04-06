pipeline {
    agent any

    environment {
        VENV_DIR = 'venv'
        GCP_PROJECT = 'mlops-project-491208'
        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"
        IMAGE_NAME = "ml-project"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage("Clone Repository") {
            steps {
                script {
                    echo "Cloning repository..."
                    checkout scmGit(
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            credentialsId: 'github-token',
                            url: 'https://github.com/ndiaye429/anime-recommadation-system.git'
                        ]]
                    )
                }
            }
        }

        stage("Check GCP Authentication") {
            steps {
                sh '''
                export PATH=$PATH:${GCLOUD_PATH}

                echo "Checking GCP authentication..."
                gcloud auth list
                gcloud config list
                '''
            }
        }

        stage("Create Virtual Environment") {
            steps {
                sh '''
                echo "Creating Python virtual environment..."

                python -m venv ${VENV_DIR}

                . ${VENV_DIR}/bin/activate

                pip install --upgrade pip

                pip install -e .

                pip install dvc python-dotenv
                '''
            }
        }

        stage("DVC Pull") {
            steps {
                sh '''
                echo "Pulling data from DVC..."

                . ${VENV_DIR}/bin/activate

                dvc pull
                '''
            }
        }

        stage("Train Model") {
            steps {
                sh '''
                echo "Training ML model..."

                . ${VENV_DIR}/bin/activate

                export PYTHONPATH=$PYTHONPATH:$(pwd)

                export $(cat .env | xargs)

                python pipeline/training_pipeline.py
                '''
            }
        }

        stage("Build Docker Image") {
            steps {
                sh '''
                echo "Building Docker image..."

                export PATH=$PATH:${GCLOUD_PATH}

                gcloud config set project ${GCP_PROJECT}

                docker build -t gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage("Push Docker Image") {
            steps {
                sh '''
                echo "Pushing Docker image..."

                export PATH=$PATH:${GCLOUD_PATH}

                gcloud auth configure-docker --quiet

                docker push gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                sh '''
                echo "Deploying to Kubernetes..."

                export PATH=$PATH:${GCLOUD_PATH}

                export USE_GKE_GCLOUD_AUTH_PLUGIN=True

                gcloud container clusters get-credentials ml-app-cluster \
                --region us-central1

                kubectl set image deployment/ml-project \
                ml-project=gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}

                kubectl rollout status deployment/ml-project
                '''
            }
        }

    }
}