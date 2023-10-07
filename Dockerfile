# .devcontainer/Dockerfile
FROM arm64v8/ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        vim \
        zsh \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Install the GCP CLI
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh
RUN rm -rf /tmp/google-cloud-sdk.tar.gz 

# Add the gcloud cli to path 
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install steampipe
RUN curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh > /tmp/steampipe-install.sh
RUN chmod 755 /tmp/steampipe-install.sh
RUN /bin/sh -c /tmp/steampipe-install.sh

# download the GCP insights dashboard
RUN git clone https://github.com/turbot/steampipe-mod-gcp-insights.git 

# Set up non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    apt-get update && apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
ENV PATH $PATH:/usr/local/bin/steampipea

# install plugins 
RUN steampipe plugin install steampipe 
RUN steampipe plugin install gcp

RUN cd steampipe-mod-gcp-insights/
CMD steampipe dashboard 