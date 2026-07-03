## Install ArgoCD on your Cluster
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd --namespace argocd --version 7.7.0
```

## Access ArgoCD UI

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Retrieve Credentials

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

To verify, you can get all grades with:
```bash
curl http://localhost:<port>/grades
```

-------------------------------------------------------------------------------------------


argocd of password = -UnTKgVi1sZ8Xzsj