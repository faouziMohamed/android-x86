# How to deploy the image in a cluster with kubernetes

In this demo we'll use:

- `android-x86` as service and deployment name
- `conf-android-x86.yaml` as kubectl config file
- `android-x86-deploy-svc.yaml` as a deployment and Service config file

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- A kubernetes cluster from the cloud provider of your choice
- A vnc client

## Deploy

```bash
  # Assumptions on files and name being used
  SVC_NAME=android-x86
  CONF_FILE=${HOME}/.kube/conf-android-x86.yaml
  DEPLOY_FILE=kubernetes/android-x86-deploy-svc.yaml
```

1. Add the config file in the `~/.kube` directory and rename it to `conf-android-x86.yaml`

1. Merge the config file with the current one (`~/.kube/config`) if it exists

   ```bash
     if [ -f ${HOME}/.kube/config ]; then
         CONTEXT=$(kubectl config view --kubeconfig $CONF_FILE | grep "current-context" | cut -d ":" -f 2 | tr -d " ")
         echo -e "\e[34mMerging config files...\e[0m"
         cp ${HOME}/.kube/config ${HOME}/.kube/config.bak

         KUBECONFIG=${HOME}/.kube/config:$CONF_FILE kubectl config view --flatten > /tmp/kubeconfig
         mv /tmp/kubeconfig ${HOME}/.kube/config

         kubectl config use-context $CONTEXT
     fi
   ```

1. Deploy and expose the cluster as a service with the config file

   ```bash
     kubectl apply -f $DEPLOY_FILE

     while !(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}') &>/dev/null; do
         echo "Waiting for the service to be ready..."
         sleep 5
     done
   ```

## Inspection

### Check the pods

```bash
  # Get the pods
  kubectl get pods -o wide
```

### Check the service and the cluster

```bash
  # Get the service
  kubectl get svc $SVC_NAME -o wide
  echo
  # Get the deployment
  kubectl get deploy $SVC_NAME -o wide
```

### Get the cluster IP and port

Wait until the cluster is ready and get the IP (The node type is `LoadBalancer`)

```bash
  kubectl get svc -o wide --kubeconfig $CONF_FILE --namespace $NS_NAME

  echo "Cluster IP:"
  EXTERNAL_IP=$(kubectl get svc $SVC_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  OPENED_PORT=$(kubectl get svc $SVC_NAME -o jsonpath='{.spec.ports[0].port}')

  echo -e "Service available on VNC client at \e[1;32m${EXTERNAL_IP}:${OPENED_PORT}\e[0m"
```

<!-- Create a scipt summarizing the steps above -->
