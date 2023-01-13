#!/bin/bash

# Path: kubernetes/README.md
# How to deploy the Kubernetes cluster


SVC_NAME=android-x86
CONF_FILE= # "${HOME}/.kube/conf-android-x86.yaml"
DEPLOY_FILE=kubernetes/android-x86-deploy-svc.yaml

KUBE_CONFIG=
DEPLOY_CONFIG=
while [ $# -gt 0 ]; do
    case "$1" in
        -k|--kubeconfig)
            KUBE_CONFIG=$2
            shift
            ;;
        -d|--deployconfig)
            DEPLOY_CONFIG=$2
            shift
            ;;
        *)
            echo -e "\e[31mUnknown argument: '$1', skipping...\e[0m"
            shift
            ;;
    esac
    shift
done

if [ -z $KUBE_CONFIG ]; then
    echo -e "\e[31mNo config file specified, aborting...\e[0m"
    exit 1
else
    CONF_FILE=$KUBE_CONFIG
fi

if [ -z $DEPLOY_CONFIG ]; then
    echo -e "\e[35mNo deploy file specified, using default: \e[3;33m${DEPLOY_FILE}\e[0m\n" 
    trap "echo 'aborting...'; exit 1" INT
    read -p "Press enter to continue or Ctrl+C to abort"
else
    DEPLOY_FILE=$DEPLOY_CONFIG
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

# Merge the config file with the current one (if it exists)
if [ -f ${HOME}/.kube/config ]; then
    CONTEXT=$(kubectl config view --kubeconfig $CONF_FILE | grep "current-context" | cut -d ":" -f 2 | tr -d " ")
    echo -e "\e[34mMerging config files...\e[0m"
    cp ${HOME}/.kube/config ${HOME}/.kube/config.bak

    KUBECONFIG=${HOME}/.kube/config:$CONF_FILE kubectl config view --flatten > /tmp/kubeconfig
    mv /tmp/kubeconfig ${HOME}/.kube/config

    kubectl config use-context $CONTEXT
fi

# Deploy and expose the cluster as a service with the config file
kubectl apply -f $DEPLOY_FILE 

while !(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') &>/dev/null; do
    echo "Waiting for the service to be ready..."
    sleep 5
done

# Get the service
echo -e "\nCreated service:"
kubectl get svc $SVC_NAME -o wide 
echo

echo "Created deployment:"
kubectl get deploy $SVC_NAME -o wide 
echo



# Get the cluster IP and port
# Get the ip from the EXTERNAL-IP column
echo "Cluster IP and port:"
EXTERNAL_IP=$(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
OPENED_PORT=$(kubectl get svc $SVC_NAME -o jsonpath='{.spec.ports[0].port}')

echo -e "Service available on VNC client at \e[1;32m${EXTERNAL_IP}:${OPENED_PORT}\e[0m"

# stop deploy and service
# kubectl delete -f $DEPLOY_FILE 
