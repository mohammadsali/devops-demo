## DemoApp Onboarding with ArgoCD

This guide walks you through deploying a demo NGINX app to EKS using ArgoCD and GitOps.

### 1. Add Your Manifests
Put your Kubernetes manifests in `apps/nginx/`:
- `deployment.yaml` (mounts a custom index.html from a ConfigMap)
- `service.yaml` (exposes NGINX via LoadBalancer)
- `configmap.yaml` (contains your custom index.html)

### 2. Create the ArgoCD Application Manifest
Example (`argocd-app.yaml`):
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
Apply the manifest:
```sh
kubectl apply -f apps/nginx/argocd-app.yaml -n argocd
```

### 3. Access Your App
Get the external address:
```sh
kubectl get svc -n demoapp
```
Open the EXTERNAL-IP in your browser to see your custom NGINX page.

### 4. Update the Message
Edit `configmap.yaml` and push changes to your repo. ArgoCD will auto-sync and update the NGINX pods with the new message.

---