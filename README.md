## Kubernetes Bootstrap
Set up [IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html),
and set up [AWS EBS CSI driver IAM role](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html).
Then add the AWS EBS CSI driver to the cluster in the AWS EKS console UI.

Update the local `kubectl` config with the cluster information.
```
$ aws eks update-kubeconfig --region us-west-2 --name kluster
$ kubectl config view
```

### Kaniko
Create a secret for Kaniko in order to push Docker images to Dockerhub
```
$  kubectl create secret generic kaniko --namespace argo-events --from-file config.json
```
where `config.json` has the structure
```
echo "<dockerhub username>:<dockerhub token>" | base64
{"auths":{"https://index.docker.io/v1/":{"auth":"<base64 encoded username and token>"}}}
```

## Helm

### Spark Operator
```
$ cd kubernetes/spark
$ helm install spark-operator ./helm --values=helm/override.yml --namespace spark
```
