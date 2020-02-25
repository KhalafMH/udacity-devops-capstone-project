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
                    def repoName = env.JOB_NAME.split("/")[0]
                    if ("${env.BRANCH_NAME}" == "master")
                        tags = ["${env.prefix}/$repoName:latest", "${env.prefix}/$repoName:${env.BUILD_ID}"]
                    else
                        tags = ["${env.prefix}/$repoName:${env.BRANCH_NAME}-${env.BUILD_ID}"]
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
                            sh "docker push $tag"
                        }
                    }
                }
            }
        }
    }
}