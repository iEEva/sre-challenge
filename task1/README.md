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

⚙️ Why These Technologies Were Chosen

📘 WordPress

A widely used, open-source content management system. Also, this is the CMS the SRE role is related to. 

🧱 NGINX

Used as a high-performance web server and reverse proxy. In this project:

Serves WordPress (via PHP-FPM)

Exposes NGINX metrics through /nginx_status for monitoring

Lightweight and production-ready

🗃️ MySQL

Relational database used by WordPress. Deployed as a Kubernetes pod for:

Local database persistence

Integration with WordPress via environment variables

📈 Grafana

Provides dashboards and visualization for metrics collected from NGINX, WordPress, and the cluster.

Highly customizable

Rich community dashboards

Easy integration with Prometheus

Used in our Infrastructure

📡 Prometheus

Open-source metrics collection and alerting toolkit. Monitors:

NGINX exporter (custom metrics)

Cluster metrics via metrics-server

WordPress performance

Together, these components form a mini production-grade stack. Probably something similar (at least a little) to we have
