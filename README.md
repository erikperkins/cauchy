# Cauchy

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Kubernetes Bootstrap
Set up [IAM OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html),
and set up [AWS EBS CSI driver IAM role](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html).
Then add the AWS EBS CSI driver to the cluster in the AWS EKS console UI.

Update the local `kubectl` config with the cluster information.
```
$ aws eks update-kubeconfig --region us-west-2 --name kluster
$ kubectl config view
```

## Jenkins
### Credentials
- Jenkins ssh key, SSH username with private key 
- kubectl config, Secret file, .kube/config file
- Kubernetes Jenkins secret, Secret text, secret for Jenkins service
- GitHub Jenkins App, GitHub App, GitHub app for Jenkins integration
- GitHub access token, Secret text, GitHub personal access token
- Dockerhub credentials, Username with password

### Clouds
- Blank kubernetes URL
- Namespace `jenkins`
- Jenkins URL `http://jenkins.jenkins.svc.cluster.local`
- Restrict pipeline support to authorized folders (enables kubernetes in pipelines)
- Pod template, label `jenkins-agent`, usage = "Use this node as much as possible"