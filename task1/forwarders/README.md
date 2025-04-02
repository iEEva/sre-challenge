🔁 Forwarders Folder

This folder contains port-forwarding scripts and corresponding systemd service files that make Kubernetes services accessible locally — even after a reboot or Minikube restart.

These scripts wrap kubectl port-forward commands to expose key services such as WordPress, Grafana, Prometheus, and NGINX Exporter on fixed localhost ports.

📁 Folder Contents

🔧 Shell Scripts (*.sh)

Used to establish persistent port-forwarding connections:

wordpress-portforward.sh → Forwards WordPress (Apache or NGINX) to ports 30081 / 30082

grafana-portforward.sh → Forwards Grafana to localhost:30000

prometheus-portforward.sh → Forwards Prometheus to localhost:30001

nginx-exporter-portforward.sh → Forwards NGINX metrics to localhost:9113

Each script includes optional logic to:

Wait for Minikube to start

Dynamically fetch the correct pod name via label selectors
