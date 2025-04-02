#!/bin/bash
minikube kubectl -- port-forward svc/kube-monitoring-kube-prome-prometheus -n monitoring 30001:9090
