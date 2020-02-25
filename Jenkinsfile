tags = []

pipeline {
    agent any

    environment {
        prefix = "402258575725.dkr.ecr.us-east-1.amazonaws.com"
        clusterName = "capstone-project-cluster"
        contextPrefix = "arn:aws:eks:us-east-1:402258575725:cluster"
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
                        tags = ["${env.prefix}/$repoName:latest", "${env.prefix}/$repoName:${env.GIT_COMMIT}"]
                    else
                        tags = ["${env.prefix}/$repoName:${env.BRANCH_NAME}-${env.GIT_COMMIT}"]
                    for (def tag : tags) {
                        docker.build(tag)
                    }
                }
            }
        }
        stage("Push Docker Image") {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-jenkins') {
                    sh script: ecrLogin(), label: "docker login"
                    script {
                        for (def tag : tags) {
                            sh script: "docker push $tag", label: "Push docker image: $tag"
                        }
                    }
                }
            }
        }
        stage("Prepare Kubernetes Context") {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-jenkins') {
                    sh "aws eks update-kubeconfig --name ${env.clusterName}"
                }
            }
        }
        stage("List cluster pods") {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-jenkins') {
                    script {
                        def context = "${env.contextPrefix}/${env.clusterName}"
                        sh "kubectl --context $context get pods --all-namespaces"
                    }
                }
            }
        }
    }
}