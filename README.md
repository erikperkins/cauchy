## AWS Bootstrap

### Virtual Private Cloud
On the AWS `Create VPC` page, choose `VPC and more`. This will set up public and private
subnets in multiple availability zones, along with the required route tables and internet
gateway. Choose at least two availability zones, since this is the minimum required by EKS. 
Choose one NAT gateway per availability zone. An S3 gateway is not required, since this 
project hosts its own MinIO object storage. Enable DNS hostnames and DNS resolution.

The default CIDR blocks chosen by AWS give 4096 IP addresses per subnet:

**VPC**
- 10.0.0.0/16

**Subnets**
- Public: 10.0.0.0/20
- Private: 10.0.16.0/20
- Public: 10.0.128.0/20
- Private: 10.0.144.0/20

### Elastic Kubernetes Service
Create an EKS cluster in the VPC, including *both* the public and private subnets in the VPC.
Select the default security group for the VPC. Choose `Public and private` cluster endpoint access,
so that services deployed on the cluster can be accessed from the Internet. Select the default EKS
addons, with their default versions.

### EBS CSI Configuration
Once the cluster has started, add the Amazon EBS CSI driver in order to create persistent volumes
within the cluster. Persistent volume claims will fail if this is not enabled.

Set up [IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html),
and set up [AWS EBS CSI driver IAM role](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html).
Then add the AWS EBS CSI driver addon to the cluster in the AWS EKS console UI. There should be an 
option under `Select IAM role` to select the IAM role created in the instructions above; choose this. 
Do it before the EBS CSI addon is installed. Install the EBS CSI addon before provisioning any 
compute.

### Cluster Compute
Add a node group of `t3.small` spot instances; 12 - 16 nodes should be adequate for this microservice 
architecture. Place the node group *only* in the private subnets of the VPC.

### Local `kubectl` configuration
Update the local `kubectl` config with the cluster information.
```
$ aws eks update-kubeconfig --region us-west-2 --name cauchy
$ kubectl config view
```
### Elastic Load Balancer
In order for services in the cluster to communicate with the outside, ingresses must be enabled. This 
project uses `ingress-nginx`. Run
```
$ cd navier
$ kubectl apply -f ingress-nginx
```
This will automatically create an AWS Elastic Load Balancer, and a set of services which handle incoming 
traffic from the Internet. 

### Route 53
Once the load balancer is provisioned, copy its DNS name and append it to the `A` and
`CNAME` records for this project on Route 53.
* A record: `cauchy.link`
* CNAME record: `*.cauchy.link`

### TLS
Once `ingress-nginx` has been installed, next use Helm to install `cert-manager`. Configure
`cert-manager` to issue valid certificates by running
```
$ kubectl apply -f cert-manager/clusterissuer.yml
```

### Kafka
Apply the `navier/kafka/zookeeper.yml` manifest before applying the `navier/kafka/broker.yml` manifest.

Create Kafka resources before creating resources in the `mer` or `pascal` namespaces, since these
microservices expect Kafka to exist.
``
### Secrets
Secrets need to be created in several namespaces for various services, in order to allow access to 
GitHub and MinIO.

### Kaniko Secret
Create a secret for Kaniko in order to push Docker images to Dockerhub
```
$  kubectl create secret generic kaniko --namespace argo-events --from-file config.json
```
where `config.json` has the structure
```
echo "<dockerhub username>:<dockerhub token>" | base64
{"auths":{"https://index.docker.io/v1/":{"auth":"<base64 encoded username and token>"}}}
```

### Argo Events
A race condition can occur when applying manifests in `argo-events`. Running
```
$ kubectl apply --recursive -f navier/argo-events
```
should solve the race condition.

Note that `navier/argo-events/sensors/minio-sensor.yml` will expect the bucket `orders` to exist 
in the MinIO file system. If the bucket does not exist, the EventSource pod will enter a 
CrashLoopBackoff state.

## Helm

### Spark Operator
```
$ cd kubernetes/spark
$ helm install spark-operator ./helm --values=helm/override.yml --namespace spark
```

### Sentry
```
$ cd kubernetes/sentry
$ helm install sentry ./helm -f helm/override.ywl \
    --set filestore.s3.accessKey=<minio username> \
    --set filestore.s3.secretKey=<minio password> \
    --namespace sentry

* When running upgrades, make sure to give back the `system.secretKey` value.
kubectl -n sentry get configmap sentry-sentry -o json | grep -m1 -Po '(?<=system.secret-key: )[^\\]*'
```