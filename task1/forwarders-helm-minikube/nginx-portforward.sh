#!/bin/bash
minikube kubectl -- port-forward service/nginx 30080:80
