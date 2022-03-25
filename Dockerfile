FROM ubuntu:20.04

ENV MYSQL_HOST=127.0.0.1
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=test
ENV MYSQL_DATABASE=bitnami_wordpress


ENV GKE_CLUSTER_NAME=lgt-prod
ENV GKE_CLUSTER_ZONE=us-central1-a
ENV GKE_CLUSTER_PROJECT=lead-tool-generator

ENV GCP_BUCKET_NAME=lgt_wordpress_backups

ENV K8S_WORDPRESS_NAMESPACE=leadguru-wordpress-prod
ENV K8S_WORDPRESS_SELECTOR="app.kubernetes.io/name=wordpress"

ENV WORDPRESS_PATH=/bitnami/wordpress

ENV GOOGLE_APPLICATION_CREDENTIALS=/var/secrets/google/cred.json
ENV PATH $PATH:/var/gcloud/google-cloud-sdk/bin

RUN apt-get update && apt-get install -y curl python mysql-client

# Install kubectl
COPY --from=lachlanevenson/k8s-kubectl:v1.23.4 /usr/local/bin/kubectl /usr/local/bin/kubectl

# copy credentials
COPY cred.json ${GOOGLE_APPLICATION_CREDENTIALS}

# Installing gcloud utils
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz \
  && mkdir -p /var/gcloud \
  && tar -C /var/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /var/gcloud/google-cloud-sdk/install.sh

RUN gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}


WORKDIR /app
COPY ./backup.sh /app

RUN chmod +x /app/backup.sh

CMD bash /app/backup.sh