## Yamls Folder

This folder contains all Kubernetes YAML configuration files used to deploy and manage the WordPress environment, monitoring stack, and supporting services in a Minikube-based cluster.

Each YAML file defines Kubernetes resources like Deployments, Services, ConfigMaps, Secrets, and ServiceMonitors to ensure reproducible and declarative infrastructure.

### Folder Contents

#### Application Deployments

| File Name               | Description |
|-------------------------|-------------|
| `wordpress.yaml`        | WordPress deployment using Apache. Accessible at `http://localhost:30081`. |
| `wordpress-nginx.yaml`  | WordPress deployment using NGINX + PHP-FPM. Accessible at `http://localhost:30082`. |
| `mysql.yaml`            | MySQL Pod and Service, used by WordPress as its database backend. |

#### NGINX Configuration & Monitoring

| File Name               | Description |
|-------------------------|-------------|
| `nginx-config.yaml`     | ConfigMap for custom NGINX config (`default.conf`), includes `/nginx_status` endpoint for metrics. |
| `nginx-deployment.yaml` | Standalone NGINX deployment for testing or proxy scenarios. |
| `nginx-ingress.yaml`    | Optional Ingress resource to route external traffic to internal services. |

#### Monitoring Resources

| File Name                            | Description |
|-------------------------------------|-------------|
| `grafana.yaml`                      | Standalone Grafana deployment. Originally installed via Helm and exported as YAML. |
| `nginx-exporter-service.yaml`       | Service exposing the NGINX Prometheus Exporter on port `9113`. |
| `nginx-exporter-servicemonitor.yaml`| Prometheus ServiceMonitor resource to scrape metrics from the NGINX exporter. |
