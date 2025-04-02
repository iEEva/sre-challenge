#!/bin/bash

# Wait for the pod to be ready
until minikube kubectl -- get pod -l app=wordpress-nginx -n wordpress -o jsonpath='{.items[0].metadata.name}' | grep -q .; do
  echo "[nginx-exporter] Waiting for pod..."
  sleep 5
done

# Get pod name via minikube
POD=$(minikube kubectl -- get pod -l app=wordpress-nginx -n wordpress -o jsonpath='{.items[0].metadata.name}')
minikube kubectl -- port-forward pod/$POD -n wordpress 9113:9113
