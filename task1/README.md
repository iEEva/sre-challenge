## Folder Descriptions

### Info
- Contains general access info, notes, port mappings, and useful URLs.
- Helps keep track of local services and setup commands.

---

### 📂 Yamls

All Kubernetes resource definitions used to define and manage cluster components.

**Includes:**
- `wordpress.yaml` – WordPress deployment using Apache
- `wordpress-nginx.yaml` – WordPress deployment using NGINX + PHP-FPM
- `mysql.yaml` – MySQL database pod and service
- `nginx-config.yaml` – NGINX config with `/nginx_status` for metrics
- `nginx-exporter-service.yaml` – Exposes Prometheus NGINX metrics
- `nginx-exporter-servicemonitor.yaml` – Enables Prometheus scraping
- `grafana.yaml` – Grafana deployment configuration

> Grafana was originally installed using Helm:  
> `helm install kube-monitoring prometheus-community/kube-prometheus-stack --namespace monitoring`  
> and later exported via:
> ```bash
> helm template grafana prometheus-community/kube-prometheus-stack \
>   --namespace monitoring \
>   --set grafana.enabled=true \
>   --set prometheus.enabled=false \
>   --set alertmanager.enabled=false > Yamls/grafana.yaml
> ```

---

### Forwarders

Scripts and services to persist `kubectl port-forward` connections on reboot.

**Includes:**
- Shell scripts:
  - `grafana-portforward.sh`
  - `prometheus-portforward.sh`
  - `wordpress-portforward.sh`
  - `nginx-exporter-portforward.sh`

**Purpose:**
- Enable stable access to services via:
  - Grafana → `http://localhost:30000`
  - Prometheus → `http://localhost:30001`
  - WordPress → `http://localhost:30081`, `http://localhost:30082`
  - NGINX Exporter → `http://localhost:9113`

---

## Why These Technologies Were Chosen

### WordPress
- Popular open-source CMS — ideal for containerization.
- Matches our infrastructure (e.g. what SREs work with).
- Familiarity with WordPress management is relevant to the role.

### 🌐 NGINX
- Lightweight, fast, production-grade web server.
- Serves WordPress via PHP-FPM (for the NGINX deployment).
- Exposes metrics via `/nginx_status` for Prometheus scraping.

### MySQL
- Relational database required by WordPress.
- Easily deployed as a Kubernetes Pod.

### Grafana
- Visualizes metrics from Prometheus and NGINX exporter.
- Widely used in real infrastructure.
- Highly customizable dashboards and alerting.
- Used in our own infrastructure — good practical alignment.

### Prometheus
- Pull-based metrics collection system.
- Scrapes from:
  - NGINX exporter
  - `metrics-server` for cluster-level metrics
  - Any custom endpoints (e.g. PHP-FPM)
- A core monitoring tool in many SRE environments.

---

## Summary

These tools were chosen to simulate a small, production-style environment with:
- Web hosting (WordPress + Apache/NGINX)
- Database services (MySQL)
- Monitoring and observability (Prometheus + Grafana)
- Real-world SRE tools and practices

> The stack replicates a mini infrastructure like we may encounter at work — giving hands-on practice with the same technologies.
