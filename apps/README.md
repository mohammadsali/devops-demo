## Application Onboarding with ArgoCD (apps)

1. **Create a Namespace for the Application:**
   - 
     ```sh
          kubectl create namespace nginx
     ```

2. **Prepare Application Manifests:**
   - Place your manifests (e.g., `deployment.yaml`, `service.yaml`) in `apps/nginx/`.

3. **Create ArgoCD Application Manifest:**
   
   - Apply with:
     ```sh
     kubectl apply -f apps/nginx/argocd-app.yaml -n argocd
     ```

5. **Monitor and Sync:**
   - Use the ArgoCD UI to monitor, sync, and manage your application.

---