# devops-demo

This repository contains everything you need to set up an EKS cluster on AWS, deploy ArgoCD, and onboard applications using GitOps.

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
   - Make sure ArgoCD is disabled (`enable_argocd = false`) for the first apply.

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