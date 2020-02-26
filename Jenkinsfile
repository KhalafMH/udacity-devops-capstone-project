tags = []
deploymentTag = ""
deploymentNamespace = ""

//noinspection GroovyAssignabilityCheck
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
                    if ("${env.BRANCH_NAME}" == "master") {
                        tags = ["${env.prefix}/$repoName:latest", "${env.prefix}/$repoName:${env.GIT_COMMIT}"]
                        deploymentTag = tags[1]
                        deploymentNamespace = "prod"
                    } else {
                        tags = ["${env.prefix}/$repoName:${env.BRANCH_NAME}-${env.GIT_COMMIT}"]
                        deploymentTag = tags[0]
                        deploymentNamespace = "dev"
                    }
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
        stage("Deploy New Version") {
            steps {
                withAWS(region: 'us-east-1', credentials: 'aws-jenkins') {
                    script {
                        def context = "${env.contextPrefix}/${env.clusterName}"
                        def kubeApply = { manifest ->
                            "kubectl apply --context=$context -n $deploymentNamespace -f $manifest"
                        }
                        def replace = { input, output ->
                            def content = new File(input).text.replace('$IMAGE', deploymentTag)
                            new File(output).write(content)
                        }
                        sh script: "aws eks update-kubeconfig --name ${env.clusterName}", label: "Update kubeconfig"
                        replace("deployment/app.yaml", "/tmp/app.yaml")
                        replace("deployment/service.yaml", "/tmp/service.yaml")
                        sh script: kubeApply("/tmp/app.yaml"), label: "Apply app.yaml"
                        sh script: kubeApply("/tmp/service.yaml"), label: "Apply service.yaml"
                    }
                }
            }
        }
    }
}