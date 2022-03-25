#!/bin/sh

docker build . --tag gke-wordpress-back:latest
docker tag gke-wordpress-back gcr.io/lead-tool-generator/gke-wordpress-back:latest
gcloud docker -- push gcr.io/lead-tool-generator/gke-wordpress-back:latest
