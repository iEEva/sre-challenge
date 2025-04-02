#!/bin/bash
minikube kubectl -- port-forward pod/wordpress-nginx 30082:80 -n wordpress
