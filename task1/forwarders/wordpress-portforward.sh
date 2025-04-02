#!/bin/bash
minikube kubectl -- port-forward service/wordpress 30081:80 -n wordpress
