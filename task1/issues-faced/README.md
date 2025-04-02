WordPress + NGINX on Minikube with Monitoring (Grafana + Prometheus)

This project sets up a local WordPress site running behind NGINX on Minikube, with Apache as an alternative. It also includes a full observability stack using Prometheus and Grafana. Below is a summary of issues encountered during setup and how each one was resolved.

✅ Setup Overview

Kubernetes: Minikube (WSL-based setup)

Web servers:

WordPress with NGINX (http://localhost:30082)

WordPress with Apache (http://localhost:30081)

Database: MySQL in a separate pod

Monitoring stack:

Prometheus (http://localhost:30001)

Grafana (http://localhost:30000)

NGINX Exporter for metrics

🧩 Issues & Solutions

1. Minikube showing random NodePorts when exposing services

Problem: minikube service <name> returned links like http://127.0.0.1:45605

Solution: Used NodePort type in services and exposed ports manually (e.g., 30081, 30082)

2. Port-forwarding not persistent after restart

Problem: kubectl port-forward commands stop after reboot

Solution: Created systemd services to run port-forward scripts at startup

3. Database connection errors in WordPress

Problem: WordPress showed Error establishing a database connection

Root Causes & Fixes:

Incorrect or missing wp-config.php file: Fixed by creating and mounting it via ConfigMap

MySQL pod not ready: Added wait logic and tested connectivity using nc

Environment variables not parsed correctly: Avoided Docker-style env fallbacks like getenv_docker()

4. wp-config.php gets reset after pod restart

Solution:

Created a fixed wp-config.php and stored it in a Kubernetes ConfigMap

Mounted it in the WordPress deployment using subPath

5. NGINX Exporter metrics not showing in Grafana

Problem: Dashboard was empty despite importer (ID: 12708)

Solution:

Verified /nginx_status in NGINX config

Deployed NGINX exporter sidecar

Created a Service and a ServiceMonitor to let Prometheus auto-discover it

6. Permanent redirect from port 30082 to 30081

Problem: NGINX-based WordPress was redirecting to Apache port

Solution: Added WP_HOME and WP_SITEURL to wp-config.php with the correct port

7. netcat not found in WordPress containers

Problem: Used apt install -y netcat, which failed

Solution: Installed specifically netcat-openbsd

8. Manual changes to WordPress reset after restart

Problem: All updates to WordPress settings/config were lost

Solution Suggestion: Use Persistent Volumes for /var/www/html to retain uploads, themes, config, etc.

9. Grafana port-forward service fails on reboot

Problem: Systemd service fails if Minikube isn’t started first

Solution:

Manually start Minikube before the service

Optionally add a check to the ExecStart script to wait for Minikube

📁 YAML Files

This repo includes:

wordpress.yaml – Apache-based WordPress deployment

wordpress-nginx.yaml – NGINX + PHP-FPM WordPress pod

nginx-config.yaml – Custom NGINX config with /nginx_status

mysql.yaml – MySQL deployment

wp-config-apache.php – Fixed config file for Apache WordPress

nginx-exporter-service.yaml – Service for Prometheus to scrape NGINX metrics

nginx-exporter-servicemonitor.yaml – ServiceMonitor for Prometheus

🚀 Final Notes

This setup works fully offline (localhost)

Supports complete observability with metrics

Easily extendable with Ingress, Persistent Volumes, Secrets, CI/CD, etc.

Author: x7giftailor
