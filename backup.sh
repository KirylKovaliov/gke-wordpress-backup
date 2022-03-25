#!/bin/bash

set -e

# Utility functions
get_log_date () {
    date +[%Y-%m-%d\ %H:%M:%S]
}
get_file_date () {
    date +%Y%m%d%H%M%S
}


mkdir -p /app/backup


echo "$(get_log_date) MySql backup started"
# mysql dump
mysqldump -h $MYSQL_HOST -d $MYSQL_DATABASE  -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD > /app/backup/$MYSQL_DATABASE.sql

echo "$(get_log_date) Getting k8s credentials"
# get k8s credentials
gcloud container clusters get-credentials $GKE_CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GKE_CLUSTER_PROJECT

# copy pod files
POD_NAME=$(kubectl get pods --selector="$K8S_WORDPRESS_SELECTOR" --field-selector="status.phase=Running" -n $K8S_WORDPRESS_NAMESPACE --no-headers -o custom-columns=":metadata.name")
echo "$(get_log_date) Copy files from Pod: $POD_NAME"
kubectl cp $K8S_WORDPRESS_NAMESPACE/$POD_NAME:$WORDPRESS_PATH /app/backup

BACKUP_FILENAME="$(get_file_date)_wordpress.tar.gz"
echo "$(get_log_date) Compressing $BACKUP_FILENAME"
tar -czf $BACKUP_FILENAME /app/backup/*

echo "$(get_log_date) Upload to google storage $BACKUP_FILENAME"
gsutil cp $BACKUP_FILENAME gs://$GCP_BUCKET_NAME/$BACKUP_FILENAME 2>&1