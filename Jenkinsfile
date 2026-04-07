pipeline {
    agent any

    environment {
        GCP_PROJECT = "mlops-project-491208"
        REGION = "us-central1"
        CLUSTER_NAME = "ml-app-cluster"

        IMAGE_NAME = "ml-project"
        IMAGE_TAG = "${BUILD_NUMBER}"

        REPOSITORY = "ml-repo"

        GCLOUD_PATH = "/var/jenkins_home/google-cloud-sdk/bin"

        DOCKER_IMAGE = "${REGION}-docker.pkg.dev/${GCP_PROJECT}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                echo "Setting up Python environment..."

                python3 -m venv venv
                . venv/bin/activate

                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('DVC Pull Data') {
            steps {
                sh '''
                echo "Pulling dataset with DVC..."

                . venv/bin/activate

                dvc pull --force
                '''
            }
        }

        stage('Train Model') {
            steps {
                sh '''
                echo "Training ML model..."

                . venv/bin/activate

                export PYTHONPATH=$PYTHONPATH:$(pwd)

                python pipeline/training_pipeline.py
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."

                export PATH=$PATH:${GCLOUD_PATH}

                docker build -t ${DOCKER_IMAGE} .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    retry(3) {
                        sh '''
                        echo "Pushing Docker image..."

                        export PATH=$PATH:${GCLOUD_PATH}

                        gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

                        docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                echo "Deploying to Kubernetes..."

                export PATH=$PATH:${GCLOUD_PATH}

                export PATH=$PATH:/usr/local/bin:/usr/bin:/var/jenkins_home/google-cloud-sdk/bin

                export USE_GKE_GCLOUD_AUTH_PLUGIN=True

                which kubectl

                kubectl version --client

                gcloud container clusters get-credentials ${CLUSTER_NAME} --region ${REGION}

                kubectl apply -f deployment.yaml

                kubectl set image deployment/ml-app \
                ml-app-container=${DOCKER_IMAGE}

                kubectl rollout status deployment/ml-app
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully!"
        }

        failure {
            echo "Pipeline failed!"
        }
    }
}