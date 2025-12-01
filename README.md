# devops-demo


## Steps to Deploy EKS Cluster

1. **Prepare Terraform Modules:**
	 - VPC: `modules/vpc/`
	 - EKS: `modules/eks/`
	 - ArgoCD: `modules/argocd/` (do NOT install ArgoCD in the first run)

2. **Configure Cluster and Networking:**
	 - Edit `clusters/demo/main.tf` to set:
		 - Cluster name, version, VPC CIDR, subnets, instance types
		 - Admin IAM ARN (e.g., `arn:aws:iam::048753696790:user/admin-user-cli`)
		 - Restrict public access to your IP (e.g., `allowed_cidr = "142.112.179.154/32"`)

3. **Initialize Terraform:**
	 - In `clusters/demo/`, run:
		 ```sh
		 terraform init
		 ```

4. **Review the Plan:**
	 - In `clusters/demo/`, run:
		 ```sh
		 terraform plan
		 ```

5. **Apply Infrastructure (without ArgoCD):**
	 - In `clusters/demo/`, run:
		 ```sh
		 terraform apply --auto-approve
		 ```
	 - Ensure the ArgoCD module is disabled or not included in the first run (e.g., set `enable_argocd = false`).

6. **Update kubeconfig for EKS:**
	 - Run:
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

8. **Install ArgoCD (after access is confirmed):**
	 - Enable the ArgoCD module by setting `enable_argocd = true` in `clusters/demo/terraform.tfvars`.
	 - Alternatively, you can override the variable directly in the CLI:
		 ```sh
		 terraform apply -var="enable_argocd=true" --auto-approve
		 ```
	 - Run:
		 ```sh
		 terraform apply --auto-approve
		 ```
	 - Get the ArgoCD server LoadBalancer DNS:
		 ```sh
		 kubectl get svc -n argocd argocd-server
		 ```
	 - Access the UI in your browser using the external DNS (restricted to your IP).

## Setup Explanation

This setup uses Terraform to provision a secure AWS EKS cluster with GitOps automation via ArgoCD. Infrastructure is modular:

- **Networking:**
	- VPC, subnets, NAT, and route tables are defined in `modules/vpc/`.
- **EKS Cluster:**
	- Cluster, node groups, IAM roles/policies, and encryption are managed in `modules/eks/`.
	- Admin access is granted using AWS native access entries and policies, configured in `clusters/demo/main.tf`.
- **ArgoCD Deployment:**
	- ArgoCD is installed via `modules/argocd/` and exposed through a public load balancer (restricted to your IP).

## Application Onboarding with ArgoCD (apps)

1. **Create a Namespace for the Application:**
   - Example:
     ```yaml
     apiVersion: v1
     kind: Namespace
     metadata:
       name: nginx
     ```
   - Apply with:
     ```sh
     kubectl apply -f <namespace-manifest>.yaml
     # or
     kubectl create namespace nginx
     ```

2. **Set Up IAM Role for Service Account (IRSA) [if needed]:**
   - Create an IAM role in AWS with required policies.
   - Annotate a Kubernetes ServiceAccount with the IAM role ARN:
     ```yaml
     apiVersion: v1
     kind: ServiceAccount
     metadata:
       name: nginx-sa
       namespace: nginx
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name>
     ```
   - Reference the ServiceAccount in your Deployment manifest:
     ```yaml
     spec:
       serviceAccountName: nginx-sa
     ```

3. **Prepare Application Manifests or Helm Chart:**
   - Place your manifests (e.g., `deployment.yaml`, `service.yaml`) or Helm chart in `apps/<app-name>/`.

4. **Create ArgoCD Application Manifest:**
   - Example for Git-based onboarding:
     ```yaml
     apiVersion: argoproj.io/v1alpha1
     kind: Application
     metadata:
       name: nginx
       namespace: argocd
     spec:
       project: default
       source:
         repoURL: https://github.com/your-username/your-repo.git
         targetRevision: develop
         path: apps/nginx
       destination:
         server: https://kubernetes.default.svc
         namespace: nginx
       syncPolicy:
         automated:
           prune: true
           selfHeal: true
     ```
   - Apply with:
     ```sh
     kubectl apply -f apps/nginx/argocd-app.yaml -n argocd
     ```

5. **RBAC, Quotas, and Network Policies:**
   - (Optional) Set up RBAC, resource quotas, and network policies for the namespace as needed.

6. **Monitor and Sync:**
   - Use the ArgoCD UI to monitor, sync, and manage your application.

---

Add your application manifests and onboarding instructions in the `apps/` directory for each new app.

