# 📁 Project Structure Overview

This project contains a Minikube-based WordPress deployment with monitoring and observability features.  
Files are organized into clearly separated folders to improve readability, maintainability, and portability.

---

## 📂 Folder Descriptions

### 📁 Info

Documentation, setup notes, and reference materials used during the deployment process.

**Contents:**
- Authentication and access info

---

### 📁 Yamls

All Kubernetes resource definitions — used to define and manage cluster components.

**Contents:**
- `wordpress.yaml` – WordPress deployment using Apache
- `wordpress-nginx.yaml` – WordPress deployment using NGINX + PHP-FPM
- `mysql.yaml` – MySQL database pod and service
- `nginx-config.yaml` – NGINX config with `/nginx_status` for metrics
- `nginx-exporter-service.yaml` – Exposes Prometheus NGINX metrics
- `nginx-exporter-servicemonitor.yaml` – Enables Prometheus scraping
- `grafana.yaml` – Standalone Grafana deployment configuration (was installed via Helm initially) 
It was installed via Helm ( helm install kube-monitoring prometheus-community/kube-prometheus-stack --namespace monitoring )
and exported via:
helm template grafana prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=true \
  --set prometheus.enabled=false \
  --set alertmanager.enabled=false > Yamls/grafana.yaml

---

### 📁 Forwarders

Scripts to persist `kubectl port-forward` connections on reboot.

**Contents:**
- Shell scripts:  
  - `grafana-portforward.sh`  
  - `prometheus-portforward.sh`  
  - `wordpress-portforward.sh`
- Service files:  
  - `grafana-portforward.service`, etc.

These enable permanent access to services via:
- Grafana → `http://localhost:30000`
- Prometheus → `http://localhost:30001`
- WordPress → `http://localhost:30081`, `http://localhost:30082`
- NGINX Exporter → `http://localhost:9113`

---
