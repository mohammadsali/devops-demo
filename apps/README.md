## Application Onboarding with ArgoCD (apps)

1. **Create a Namespace for the Application:**
   - 
     ```sh
          kubectl create namespace demoapp
     ```

2. **Prepare Application Manifests:**
   - Place your manifests (e.g., `deployment.yaml`, `service.yaml`) in `apps/nginx/`.

3. **Create ArgoCD Application Manifest:**
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

6. **Monitor and Sync:**
   - Use the ArgoCD UI to monitor, sync, and manage your application.

7. **Access NGINX:**
   - Get the external address:
     ```sh
     kubectl get svc -n demoapp
     ```
   - Open the EXTERNAL-IP in your browser to see the custom message.

8. **Update the Message:**
   - Edit `configmap.yaml` and push changes to your repo.
   - ArgoCD will auto-sync and update the NGINX pods with the new message.

---
