# Forwarders Folder

This folder contains port-forwarding scripts that make Kubernetes services accessible locally — even after a reboot or Minikube restart.

Each script wraps a `kubectl port-forward` command and maps Kubernetes services or pods to fixed `localhost` ports for easier access.

---

## Folder Contents

### Shell Scripts (`*.sh`)

Scripts that establish and persist port-forwarding connections:

- `wordpress-portforward.sh`  
  → Forwards WordPress (Apache or NGINX) to ports:  
  `http://localhost:30081` / `http://localhost:30082`

- `grafana-portforward.sh`  
  → Forwards Grafana to:  
  `http://localhost:30000`

- `prometheus-portforward.sh`  
  → Forwards Prometheus to:  
  `http://localhost:30001`

- `nginx-exporter-portforward.sh`  
  → Forwards NGINX Prometheus Exporter metrics to:  
  `http://localhost:9113`

---

## Features and Behavior

Each script includes logic to:

- **Wait for Minikube to start** before attempting the port-forward  
- **Dynamically select the correct pod name** using Kubernetes label selectors  
- Run continuously or under a `systemd` service to persist across reboots  
