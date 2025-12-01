# devops-demo

## Solution Overview

This repository shows how to build a robust, automated Kubernetes platform on AWS using EKS, Terraform, and ArgoCD.

The cluster is set up with Terraform, which takes care of all the AWS infrastructure—VPC, networking, IAM roles, and the EKS control plane. Everything is defined as code, so you can recreate or update the environment easily and consistently. Node groups, scaling, and access controls are all managed in the Terraform modules, making the setup secure and repeatable.

We use an S3 bucket as the Terraform backend to store the state file securely and reliably. To prevent concurrent changes and ensure safe operations, DynamoDB is used for state locking. This setup allows multiple team members to collaborate safely and keeps infrastructure changes consistent.

EKS cluster logging is enabled and integrated with AWS CloudWatch, so you can monitor cluster events, audit logs, and troubleshoot issues directly from the AWS console. This provides visibility into cluster operations and helps with compliance and debugging.

For simplicity in this demo, my public IP is added to the allowed list for accessing the EKS API and the ArgoCD UI. This makes it easy to test and manage the cluster from my laptop, but in a real production setup, you would restrict access further or use VPNs and private networking for better security.

After the cluster is running, ArgoCD is installed to bring in GitOps workflows. With ArgoCD, application manifests are stored in a Git repository and any changes are automatically synced to the cluster. This means deployments, updates, and rollbacks are all handled through Git, giving you a clear history and audit trail for every change.

For application onboarding, each app gets its own namespace and its manifests are organized in the repo. The demo app (NGINX) is deployed via ArgoCD, with its configuration managed through ConfigMaps. The app is exposed to the internet using an AWS LoadBalancer, and in production you can set up a custom DNS name for stable access.

This approach combines infrastructure-as-code and GitOps to deliver a secure, scalable, and easy-to-manage platform for cloud-native applications. Everything is automated, versioned, and ready for real-world use.

---

## EKS Cluster Setup

1. **Prepare Terraform Modules:**
   - VPC: `modules/vpc/`
   - EKS: `modules/eks/`
   - ArgoCD: `modules/argocd/` (skip ArgoCD on the first run)

2. **Configure Cluster and Networking:**
   - Edit `clusters/demo/main.tf` to set cluster name, version, VPC CIDR, subnets, instance types, and your admin IAM ARN.
   - Restrict public access to your IP (e.g., `allowed_cidr = "your ip/range"`).

3. **Initialize and Apply Terraform:**
   - In `clusters/demo/`, run:
     ```sh
     terraform init
     terraform plan
     terraform apply --auto-approve
     ```
   - Make sure ArgoCD is disabled (`enable_argocd = false` by default) for the first apply.

4. **Configure kubectl:**
   - Update your kubeconfig:
     ```sh
     aws eks update-kubeconfig --name devops-demo-eks --region ca-central-1
     ```

7. **Grant Kubernetes Access to Your IAM User:**
	 - Run these AWS CLI commands to create an access entry and associate the admin policy:
		 ```sh
		 aws eks create-access-entry \
			 --cluster-name devops-demo-eks \
			 --principal-arn arn:aws:iam::<ACCOUNT-ID>:user/admin-user-cli \
			 --type STANDARD

		 aws eks associate-access-policy \
			 --cluster-name devops-demo-eks \
			 --principal-arn arn:aws:iam::<ACCOUNT-ID>:user/admin-user-cli \
			 --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
			 --access-scope type=cluster
		 ```
	 - Replace `<ACCOUNT-ID>` with your AWS account ID.
	 - Wait a few minutes for the changes to propagate.
	 - Test access:
		 ```sh
		 kubectl get ns
		 ```

6. **Install ArgoCD:**
   - Enable the ArgoCD module (`enable_argocd = true`) and apply again:
     ```sh
     terraform apply --auto-approve
     # Or override the variable directly:
     terraform apply -var="enable_argocd=true" --auto-approve
     ```
   - Get the ArgoCD server LoadBalancer DNS:
     ```sh
     kubectl get svc -n argocd argocd-server
     ```
   - Access the ArgoCD UI in your browser using the external DNS (access is restricted to your IP).

---

## Application Onboarding with ArgoCD

1. **Create a Namespace for Your App:**
   ```sh
   kubectl create namespace demoapp
   ```

2. **Add Your App Manifests:**
   - Place your manifests (e.g., `deployment.yaml`, `service.yaml`, `configmap.yaml`) in `apps/nginx/`.

3. **Create the ArgoCD Application Manifest:**
   - Example (`argocd-app.yaml`):
     ```yaml
     apiVersion: argoproj.io/v1alpha1
     kind: Application
     metadata:
       name: demoapp
       namespace: argocd
     spec:
       project: default
       source:
         repoURL: https://github.com/your-username/your-repo.git
         targetRevision: develop
         path: apps/nginx
       destination:
         server: https://kubernetes.default.svc
         namespace: demoapp
       syncPolicy:
         automated:
           prune: true
           selfHeal: true
     ```
   - Apply with:
     ```sh
     kubectl apply -f apps/nginx/argocd-app.yaml -n argocd
     ```

4. **Monitor and Sync:**
   - Use the ArgoCD UI to monitor, sync, and manage your application.

5. **Access Your App:**
   - Get the external address:
     ```sh
     kubectl get svc -n demoapp
     ```
   - Open the EXTERNAL-IP in your browser to see your app.

6. **Update the App:**
   - Edit your manifests and push changes to your repo.
   - ArgoCD will auto-sync and update the pods with your changes.

---

For more details, see the `apps/README.md` in this repo.