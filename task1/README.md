## Folder Descriptions

### Ports
| Purpose | Description |
|---------|-------------|
| Access Info | Contains general notes, port mappings, service URLs, and access-related details. |
| Use Case | Helps track local service endpoints and handy startup commands. |

### Yamls (Kubernetes Resource Definitions)
All Kubernetes YAML definitions used to deploy and manage application components.

| File Name                            | Description |
|-------------------------------------|-------------|
| `wordpress.yaml`                    | WordPress deployment using Apache. |
| `wordpress-nginx.yaml`              | WordPress deployment using NGINX + PHP-FPM. |
| `mysql.yaml`                        | MySQL Pod and Service definition. |
| `nginx-config.yaml`                 | NGINX config exposing `/nginx_status` for metrics. |
| `nginx-exporter-service.yaml`       | Service that exposes NGINX Prometheus Exporter. |
| `nginx-exporter-servicemonitor.yaml`| Prometheus `ServiceMonitor` for scraping NGINX metrics. |
| `grafana.yaml`                      | Grafana deployment config (exported from Helm). |

> Grafana was originally installed using Helm:
> ```bash
> helm install kube-monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
> ```
> And later exported via:
> ```bash
> helm template grafana prometheus-community/kube-prometheus-stack \
>   --namespace monitoring \
>   --set grafana.enabled=true \
>   --set prometheus.enabled=false \
>   --set alertmanager.enabled=false > Yamls/grafana.yaml
> ```

### Forwarders
Scripts that automate and persist `kubectl port-forward` connections even after reboot.

| Included Scripts                   | Description |
|-----------------------------------|-------------|
| `grafana-portforward.sh`          | Forwards Grafana to `http://localhost:30000`. |
| `prometheus-portforward.sh`       | Forwards Prometheus to `http://localhost:30001`. |
| `wordpress-portforward.sh`        | WordPress (Apache) at `http://localhost:30081`. |
| `wordpress-nginx-portforward.sh`  | WordPress (NGINX) at `http://localhost:30082`. |
| `nginx-portforward.sh`            | Forwards standalone NGINX (custom port). |
| `nginx-exporter-portforward.sh`   | Exposes NGINX Prometheus Exporter at `http://localhost:9113`. |

## Why These Technologies Were Chosen

| Technology | Why It Was Chosen |
|------------|-------------------|
| WordPress | Popular CMS, container-friendly, highly relevant to infra/SRE roles. |
| NGINX | Lightweight, fast, and integrates well with PHP-FPM for WordPress. Offers `/nginx_status` endpoint for Prometheus metrics. |
| MySQL | Required by WordPress; easy to deploy and monitor in Kubernetes. |
| Grafana | Industry-standard for dashboards, alerting, and metric visualization. Used across real-world infra setups. |
| Prometheus | Pull-based monitoring, scrapes metrics from exporters and internal components. A key monitoring tool in most SRE stacks. |

## Summary
This setup was built to simulate a production-style environment with:

- Web hosting (WordPress + Apache/NGINX)  
- Database (MySQL)  
- Monitoring & Observability (Prometheus + Grafana)  
- I assume these tools to be practical tools used by real SRE teams

> This stack replicates a realistic infrastructure for practical learning, configuration, and debugging and also helping to prepare for real-case operational scenarios.

## Issues Faced and Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `/nginx_status` not configured | NGINX did not expose the internal metrics endpoint needed by the exporter. | Added `/nginx_status` in `nginx-config.yaml` using `stub_status` |
| Prometheus not scraping NGINX exporter | No ServiceMonitor or incorrect exporter URL. | Used `-nginx.scrape-uri=http://localhost/nginx_status` and added a `ServiceMonitor` |
| No graphs shown in Grafana | Forgot that Grafana needs Prometheus queries to show data. | Ran proper queries like `nginx_active_connections` manually in Grafana |
| WordPress DB connection error | WordPress pod started before MySQL was ready. | Added `wait-for-mysql.sh` init container to wait for MySQL `3306` using `nc -zv` |
| WordPress blank pages | Misconfigured `wp-config.php` (e.g. missing quotes, syntax errors). | Fixed syntax issues by correcting lines in `wp-config.php` |
