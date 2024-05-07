FROM python
# 3.8.3-slim-buster
# google sdk (gcr) gcr.io/google.com/cloudsdktool/cloud-sdk:444.0.0


# Install utilities and kubectl dependencies
RUN apt-get update && \
    apt-get install -y apt-transport-https gnupg wget && \
    wget -qO- https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* 

# Install Google Cloud SDK
RUN apt-get update && \
    apt-get install -y curl && \
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-buster main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Configure gcloud
RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

RUN apt-get update && apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
    
# Create the .kube/config file
RUN mkdir -p /root/.kube && touch /root/.kube/config && chmod 777 /root/.kube/config

WORKDIR /

COPY . .

RUN pip install -r requirements.txt 
RUN chmod +x /entrypoint

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint"]

