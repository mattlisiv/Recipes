node {
     //Define Project
     def project = 'kubernetes-jenkins-ci'
     def appName = 'rethinkdb'
     def feSvcName = "${appName}"
     def branch = env.BRANCH_NAME
     def imageTag = "gcr.io/${project}/${appName}:${appName}.1.0.0"

    //Checkout Code
    checkout scm

    stage 'Build image'
    sh("docker build -t ${imageTag} .")

    stage 'Push image to registry'
    sh("gcloud docker push ${imageTag}")

    stage 'Deploy Application'
    switch(env.BRANCH_NAME){
        case "master":
              // Change deployed image in canary to the one we just built
                sh("sed -i.bak 's#gcr.io/${project}/${appName}:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
                sh("kubectl --namespace=production apply -f k8s/services/")
                sh("kubectl --namespace=production apply -f k8s/production/")
                sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                break
         // Roll out a dev environment
            default:
                // Create namespace if it doesn't exist
                sh("kubectl get ns ${branch} || kubectl create ns ${branch}")
                // Don't use public load balancing for development branches
                sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/production/production.yaml")
                sh("sed -i.bak 's#gcr.io/${project}/${appName}:1.0.0#${imageTag}#' ./k8s/production/*.yaml")
                sh("kubectl --namespace=${branch} apply -f k8s/production/")
                echo 'To access your environment run `kubectl proxy`'
                echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${branch}/services/${feSvcName}:80/"
          }

    }