📦 Yamls Folder

-  This folder contains all Kubernetes YAML configuration files used to deploy and manage the WordPress environment, monitoring stack, and supporting services in a Minikube-based cluster.

-  Each YAML file defines Kubernetes resources like Deployments, Services, ConfigMaps, Secrets, and ServiceMonitors to ensure reproducible and declarative infrastructure.

📁 Folder Contents

📝 Application Deployments

-  wordpress.yaml – WordPress deployment using Apache (http://localhost:30081)

-  wordpress-nginx.yaml – WordPress deployment using NGINX + PHP-FPM (http://localhost:30082)

-  mysql.yaml – MySQL database pod and service used by WordPress

⚙️ NGINX Configuration & Monitoring

-  nginx-config.yaml – ConfigMap defining custom NGINX config (default.conf) with /nginx_status endpoint

-  nginx-deployment.yaml – Standalone NGINX deployment (for testing or proxy use)

-  nginx-ingress.yaml – Optional Ingress resource for routing external traffic

📊 Monitoring Resources

-  grafana.yaml – Standalone Grafana deployment configuration (was installed via helm also)

-  nginx-exporter-service.yaml – Kubernetes Service for NGINX Prometheus Exporter (port 9113)

-  nginx-exporter-servicemonitor.yaml – Prometheus ServiceMonitor that scrapes metrics from the exporter
