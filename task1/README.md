###📁 Project Structure Overview

This project contains a Minikube-based WordPress deployment with monitoring and observability features. Files are organized into clearly separated folders to improve readability, maintainability, and portability.

📂 Folders & Their Purpose

###📁 Info

This folder contains documentation, notes, and supporting reference materials used during the deployment and configuration process.

Typical contents:

Setup instructions

Commands and debug tips

References for systemd services or networking

Authentication info or access instructions

###📁 Yamls

This folder holds all Kubernetes YAML files used to define and manage the cluster resources.

Typical contents:

wordpress.yaml – WordPress deployment using Apache

wordpress-nginx.yaml – WordPress deployment using NGINX + FPM

mysql.yaml – MySQL database pod and service

nginx-config.yaml – ConfigMap for custom NGINX config

nginx-exporter-service.yaml – Exposes Prometheus NGINX metrics

nginx-exporter-servicemonitor.yaml – Enables Prometheus to scrape exporter metrics

Any supporting ConfigMaps, Secrets, or Service definitions

###📁 Forwarders

This folder includes scripts and systemd service definitions to make port-forwarding persistent across restarts.

Typical contents:

Shell scripts like grafana-portforward.sh, wordpress-portforward.sh

Corresponding systemd service units: grafana-portforward.service, etc.

These ensure consistent access to local services like:

Grafana (localhost:30000)

Prometheus (localhost:30001)

WordPress (localhost:30081 / 30082)

NGINX exporter (localhost:9113)

