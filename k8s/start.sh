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

echo "Starting Songs Service..."
cd ../k8s/songs-service
kubectl apply -f songs-service-namespace.yaml

if kubectl get configmap db-config -n songs-service; then
  echo "ConfigMap db-config already exists in songs-service. Updating..."
  kubectl delete configmap db-config -n songs-service
fi
kubectl create configmap db-config --from-env-file=../../.env -n songs-service
kubectl apply -f ./ || { echo "Failed to deploy Songs services"; exit 1; }

echo "Starting Resource Service..."
cd ../resources-service
kubectl apply -f resource-services-namespace.yaml
if kubectl get configmap db-config -n k8s-program; then
  echo "ConfigMap db-config already exists in k8s-program. Updating..."
  kubectl delete configmap db-config -n k8s-program
fi

kubectl create configmap db-config --from-env-file=../../.env -n k8s-program

kubectl apply -f ./ || { echo "Failed to deploy Resource services"; exit 1; }
echo "Services have started!"

