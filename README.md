# RKE2-TF-AWS-GOV-Istio
A Terraform Wiz example forking to test out RKE2 on AWS Gov Cloud with Istio

Deploying Rancher RKE2 Kubernetes to AWS GovCloud with Istio involves several steps, including setting up your AWS environment, deploying RKE2, and configuring Istio for service mesh capabilities. Below is a high-level guide with key instructions and code snippets to achieve this.

### Prerequisites

1. **AWS GovCloud Account**: Ensure you have access to AWS GovCloud.
2. **AWS CLI Configured**: Set up AWS CLI with your GovCloud credentials.
3. **Terraform**: For infrastructure automation.
4. **RKE2 CLI**: Rancher's RKE2 CLI tool for Kubernetes deployment.
5. **Kubectl**: Kubernetes command-line tool.
6. **Helm**: Package manager for Kubernetes.
7. **Istioctl**: CLI tool for managing Istio.


First, create a Terraform configuration to set up the required AWS infrastructure (saved as main.tf in this repo)


### 1. **Set Up AWS Infrastructure with Terraform** RTFM - Terraform Init, Plan and Apply Yolo Shit




### ### 2. **Install RKE2 on EC2 Instances**

SSH into the EC2 instances created by Terraform and install RKE2.

#### Install RKE2 on Server Node
```bash
sudo curl -sfL https://get.rke2.io | sudo sh -
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

# Copy the kubeconfig to a location for kubectl to use
sudo cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
sudo chmod 600 ~/.kube/config
```

#### Install RKE2 on Agent Nodes
```bash
sudo curl -sfL https://get.rke2.io | sudo sh -
sudo systemctl enable rke2-agent.service
sudo systemctl start rke2-agent.service

# Modify the agent config file to point to the server
sudo mkdir -p /etc/rancher/rke2/
echo "server: https://<RKE2_SERVER_PRIVATE_IP>:9345" | sudo tee /etc/rancher/rke2/config.yaml

# Start the agent service
sudo systemctl restart rke2-agent.service
```

### 3. **Install Istio Service Mesh**

After setting up the RKE2 Kubernetes cluster, install Istio.

#### Install Istio CLI (Istioctl)
```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
```

#### Install Istio on RKE2
```bash
istioctl install --set profile=demo -y
```

#### Label the Namespace for Automatic Sidecar Injection
```bash
kubectl label namespace default istio-injection=enabled
```

### 4. **Deploy a Sample Application with Istio**

Deploy a sample application (like Bookinfo) to test Istio's service mesh.

```bash
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

### 5. **Access the Application**

Find the external IP of the Istio ingress gateway:

```bash
kubectl get svc istio-ingressgateway -n istio-system
```

Navigate to the external IP to access the application.


