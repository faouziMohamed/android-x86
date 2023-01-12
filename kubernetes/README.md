# How to deploy the Kubernetes cluster

In this demo we'll use:

- `ns-android-x86` as namespace in kubernetes
- `android-x86` as service and deployment name
- `conf-android-x86.yaml` as configMap file
- `android-x86-deploy-svc.yaml` as config file for deployment and Service

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- A kubernetes cluster from the cloud provider of your choice
- A vnc client

## Deploy

```bash
# Variables
NS_NAME=ns-android-x86
SVC_NAME=android-x86
CONF_FILE="${HOME}/.kube/conf-android-x86.yaml"
DEPLOY_FILE=kubernetes/android-x86-deploy-svc.yaml
```

1. - Add the config file in the `~/.kube` directory and rename it to `conf-android-x86.yaml`

1. Create a namespace for the cluster for the configMap created in the previous step

```bash
kubectl create namespace $NS_NAME --kubeconfig $CONF_FILE
kubectl config set-context --current --namespace $NS_NAME --kubeconfig $CONF_FILE
```

1. Deploy and expose the cluster as a service with the config file

```bash
kubectl apply -f $DEPLOY_FILE --kubeconfig $CONF_FILE --namespace $NS_NAME
```

## Inspection

### Check the pods

```bash
# Get the pods
kubectl get pods --kubeconfig $CONF_FILE --namespace $NS_NAME -o wide
```

### Check the service and the cluster

```bash
# Get the service
kubectl get svc $SVC_NAME -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME
echo
# Get the deployment
kubectl get deploy $SVC_NAME -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME
```

1. Get the cluster IP and port
   Wait until the cluster is ready and get the IP (The node type is `LoadBalancer`)

```bash
kubectl get svc -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME

# Get the ip from the EXTERNAL-IP column
kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}' && echo

# Get the port from the PORT(S) column. The expected port is 5999
kubectl get svc $SVC_NAME -o jsonpath='{.spec.ports[0].port}' && echo
```

<!-- Create a scipt summarizing the steps above -->
