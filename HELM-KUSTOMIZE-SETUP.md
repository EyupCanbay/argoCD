# Helm + Kustomize + ArgoCD Entegrasyonu

Bu yapılandırma ArgoCD'nin şu sırayla çalışmasını sağlar:
1. **Helm Chart Render** → Helm chart'ı işler
2. **Kustomize Patch** → InitContainer ekler
3. **Deploy** → Cluster'a deploy eder

## Yapı

```
Helm Chart → Kustomize Overlay → ArgoCD → Kubernetes Cluster
```

## Dosya Yapısı

```
kustomize/overlays/prod-with-helm/
├── kustomization.yaml        # Helm chart'ı dahil eder
├── initcontainer-patch.yaml  # InitContainer ekler
└── values.yaml               # Helm values override

argocd/applications/
└── helm-kustomize-application.yaml  # ArgoCD app tanımı
```

## Nasıl Çalışır?

### 1. Kustomize Helm'i Çağırır
`kustomization.yaml` içinde `helmCharts` section'ı Helm chart'ı render eder:
```yaml
helmCharts:
  - name: grade-submission
    releaseName: prod-release
    chartPath: helm/grade-submission
    valuesFile: values.yaml
```

### 2. Kustomize InitContainer Ekler
`initcontainer-patch.yaml` strategic merge patch olarak uygulanır:
```yaml
patches:
  - path: initcontainer-patch.yaml
    target:
      kind: Deployment
      name: prod-release-grade-submission-api
```

### 3. ArgoCD Deploy Eder
ArgoCD application Kustomize overlay'i kullanır ve cluster'a deploy eder.

## Kurulum Adımları

### Adım 1: Git Repository'yi Güncelleyin
```bash
git add .
git commit -m "Add Helm + Kustomize + ArgoCD integration"
git push origin main
```

### Adım 2: ArgoCD Application'ı güncelleyin
`argocd/applications/helm-kustomize-application.yaml` dosyasında:
- `repoURL`: Kendi Git repo URL'inizi yazın
- `targetRevision`: Branch adınızı yazın (main/master)

### Adım 3: Namespace Oluşturun (isteğe bağlı)
```bash
kubectl create namespace production
```

### Adım 4: ArgoCD Application'ı Deploy Edin
```bash
kubectl apply -f argocd/applications/helm-kustomize-application.yaml
```

### Adım 5: ArgoCD UI'dan Kontrol Edin
```bash
# ArgoCD port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Browser'da aç: https://localhost:8080
# Login: admin / <argocd-initial-admin-secret>
```

## Manuel Test (Local)

### 1. Kustomize ile Build Et ve Görüntüle
```bash
cd kustomize/overlays/prod-with-helm

# Helm plugin ile kustomize build
kustomize build --enable-helm .

# Veya kubectl ile
kubectl kustomize --enable-helm .
```

**NOT**: Kustomize'ın Helm desteği için Kustomize v4.1.0+ gereklidir.

### 2. Manuel Deploy (Test için)
```bash
kubectl kustomize --enable-helm . | kubectl apply -f -
```

### 3. InitContainer Loglarını Kontrol Et
```bash
# Pod'u bul
kubectl get pods -n production

# InitContainer loglarına bak
kubectl logs <pod-name> -n production -c init-setup
```

## InitContainer Özelleştirme

`initcontainer-patch.yaml` içinde istediğiniz init işlemlerini ekleyebilirsiniz:

```yaml
initContainers:
- name: init-setup
  image: busybox:1.35
  command: ['sh', '-c']
  args:
    - |
      echo "Database migration başlatılıyor..."
      # Database migration komutları
      # Config dosyası oluşturma
      # Dependency check
```

### Örnek: Database Migration InitContainer
```yaml
initContainers:
- name: db-migration
  image: migrate/migrate:v4.15.2
  command:
    - migrate
    - -path=/migrations
    - -database=$(DATABASE_URL)
    - up
  env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: url
```

## Alternatif Yaklaşım: ArgoCD Plugin

Eğer Kustomize'ın Helm desteği çalışmazsa, ArgoCD'nin kendi Helm + Kustomize kombinasyonunu kullanabilirsiniz:

```yaml
spec:
  source:
    repoURL: https://github.com/KULLANICI_ADINIZ/REPO_ADINIZ.git
    targetRevision: main
    
    # Helm chart'ı belirt
    chart: helm/grade-submission
    
    helm:
      valueFiles:
        - ../../kustomize/overlays/prod-with-helm/values.yaml
    
    # Kustomize post-render olarak çalışır
    kustomize:
      patches:
        - path: kustomize/overlays/prod-with-helm/initcontainer-patch.yaml
```

## Troubleshooting

### Helm Chart Bulunamıyor
```bash
# Chart path'ini kontrol et
ls -la helm/grade-submission/

# Chart.yaml var mı?
cat helm/grade-submission/Chart.yaml
```

### InitContainer Patchi Uygulanmıyor
```bash
# Deployment adını doğru yazdığınızdan emin olun
kubectl get deployments -n production

# Patch'i manuel test et
kubectl kustomize --enable-helm kustomize/overlays/prod-with-helm/ | grep -A 20 initContainers
```

### ArgoCD Sync Hatası
```bash
# ArgoCD app durumunu kontrol et
argocd app get grade-submission-helm-kustomize

# Detaylı log
argocd app logs grade-submission-helm-kustomize
```

## Avantajları

✅ **Helm Chart'ların Esnekliği**: Parametrik yapı  
✅ **Kustomize'ın Gücü**: Environment-specific patch'ler  
✅ **GitOps**: ArgoCD ile otomatik sync  
✅ **Tek Kaynak**: Git repo tek gerçek kaynak  
✅ **Rollback**: ArgoCD üzerinden kolay rollback  

## Sonraki Adımlar

1. **Secrets Yönetimi**: Sealed Secrets veya External Secrets ekleyin
2. **Monitoring**: Prometheus/Grafana entegrasyonu
3. **Multiple Environments**: Dev, staging, prod overlay'leri
4. **App of Apps Pattern**: Tüm uygulamaları tek yerden yönetin
