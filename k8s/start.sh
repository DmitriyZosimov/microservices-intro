#!/bin/bash

echo "Start building the application..."
cd ..
./gradlew -q clean build -x test
echo "The application build is completed"

echo "Build docker images..."

cd resources-service
docker build -t resource-image -f ./Dockerfile .

cd ../songs-service
docker build -t song-image -f ./Dockerfile .

echo "Loading images..."
minikube image load resource-image:latest
minikube image load song-image:latest

echo "Starting k8s"
cd ../k8s
kubectl apply -f namespace.yaml
if kubectl get configmap db-config -n k8s-program; then
  echo "ConfigMap db-config already exists. Updating..."
  kubectl delete configmap db-config -n k8s-program
fi
kubectl create configmap db-config --from-env-file=../.env -n k8s-program

echo "Deploying resources..."
kubectl apply -f resources-service/ -f songs-service/ || { echo "Failed to deploy services"; exit 1; }
echo "Services have started!"

