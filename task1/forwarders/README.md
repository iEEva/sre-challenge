# Forwarders Folder

This folder contains port-forwarding scripts that make Kubernetes services accessible locally — even after a reboot or Minikube restart.

Each script wraps a `kubectl port-forward` command and maps Kubernetes services or pods to fixed `localhost` ports for easier access.

---

## Folder Contents

### Shell Scripts

| Script Name                   | Description                                       | Local Access URL(s)                        |
|------------------------------|---------------------------------------------------|--------------------------------------------|
| `wordpress-portforward.sh`   | Forwards WordPress (Apache or NGINX)              | `http://localhost:30081` / `http://localhost:30082` |
| `grafana-portforward.sh`     | Forwards Grafana                                  | `http://localhost:30000`                   |
| `prometheus-portforward.sh`  | Forwards Prometheus                               | `http://localhost:30001`                   |
| `nginx-exporter-portforward.sh` | Forwards NGINX Prometheus Exporter metrics    | `http://localhost:9113`                    |

---

## Features and Behavior

| Feature                                 | Description                                                                 |
|----------------------------------------|-----------------------------------------------------------------------------|
| Minikube readiness check               | Scripts wait until Minikube is running before attempting port-forwarding.  |
| Dynamic pod name detection             | Uses `kubectl` label selectors to find the correct pod dynamically.        |
| Persistent operation                   | Scripts can run continuously or be managed by `systemd` to survive reboots. |

