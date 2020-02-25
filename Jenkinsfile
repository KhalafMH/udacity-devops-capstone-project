tags = []

pipeline {
    agent any

    environment {
        prefix = "402258575725.dkr.ecr.us-east-1.amazonaws.com"
    }

    stages {
        stage("Lint HTML") {
            steps {
                sh 'tidy -q -e app/*.html'
            }
        }
        stage("Build Docker Image") {
            steps {
                script {
                    if ("$BRANCH_NAME" == "master")
                        tags = ["${env.prefix}/${env.JOB_NAME}:latest", "${env.prefix}/${env.JOB_NAME}:${env.CHANGE_ID}"]
                    else
                        tags = ["${env.prefix}/${env.JOB_NAME}:${env.BRANCH_NAME}-SNAPSHOT"]
                    for (def tag : tags) {
                        docker.build(tag)
                    }
                }
            }
        }
        stage("Push Docker Image") {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-jenkins') {
                    sh ecrLogin()
                    script {
                        for (def tag : tags) {
                            docker.push(tag)
                        }
                    }
                }
            }
        }
    }
}