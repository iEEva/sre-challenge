#!/bin/bash
minikube kubectl -- port-forward svc/kube-monitoring-grafana -n monitoring 30000:80
