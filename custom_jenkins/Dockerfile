FROM jenkins/jenkins:lts

USER root

# Install Docker + gcloud
RUN apt-get update -y && \
    apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    python3 \
    python3-venv \
    python3-pip && \
    # Docker repo
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian trixie stable" \
    > /etc/apt/sources.list.d/docker.list && \
    # GCloud repo
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/google-cloud.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    # Install everything
    apt-get update -y && \
    apt-get install -y docker-ce docker-ce-cli containerd.io google-cloud-sdk && \
    apt-get clean

RUN ln -s /usr/bin/python3 /usr/bin/python

# Docker group
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# Docker volume
RUN mkdir -p /var/lib/docker
VOLUME /var/lib/docker

USER jenkins