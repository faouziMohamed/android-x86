#!/bin/bash

# Path: kubernetes/README.md
# How to deploy the Kubernetes cluster


NS_NAME=ns-android-x86
SVC_NAME=android-x86
CONF_FILE="${HOME}/.kube/conf-android-x86.yaml"
DEPLOY_FILE=kubernetes/android-x86-deploy-svc.yaml

# Read name of conf file from script arguments
if [ -z $1 ]; then
    echo -e "\e[35mNo config file specified, using default: ${CONF_FILE}\e[0m" 
else
    CONF_FILE=$1
fi

# Read name of deploy file from script arguments
if [ -z $2 ]; then
    echo -e "\e[35mNo deploy file specified, using default: ${DEPLOY_FILE}\e[0m" 
else
    DEPLOY_FILE=$2
fi

# Check if the config file exists
if [ ! -f $CONF_FILE ]; then
    echo -e "\e[31mConfig file not found: '\e[1m${CONF_FILE}\e[0;31m', aborting...\e[0m"
    exit 1
fi

# Check if the deploy file exists
if [ ! -f $DEPLOY_FILE ]; then
    echo -e "\e[31mDeploy file not found: '\e[1m${DEPLOY_FILE}\e[0;31m', aborting...\e[0m"
    exit 1
fi

# Create a namespace for the cluster for the configMap created in the previous step
kubectl create namespace $NS_NAME --kubeconfig $CONF_FILE 2>/dev/null
kubectl config set-context --current --namespace $NS_NAME --kubeconfig $CONF_FILE

# Deploy and expose the cluster as a service with the config file
kubectl apply -f $DEPLOY_FILE --kubeconfig $CONF_FILE --namespace $NS_NAME

while !(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') &>/dev/null; do
    echo "Waiting for the service to be ready..."
    sleep 5
done

# Get the service
echo -e "\nCreated service:"
kubectl get svc $SVC_NAME -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME
echo

echo "Created deployment:"
kubectl get deploy $SVC_NAME -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME

echo

# Get the cluster IP and port

# Get the ip from the EXTERNAL-IP column
echo "Cluster IP:"
EXTERNAL_IP=$(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
OPENED_PORT=$(kubectl get svc $SVC_NAME -o jsonpath='{.spec.ports[0].port}')

echo -e "Service available on VNC client at \e[1;32m${EXTERNAL_IP}:${OPENED_PORT}\e[0m"

# stop deploy and service
# kubectl delete -f $DEPLOY_FILE --kubeconfig $CONF_FILE --namespace $NS_NAME
