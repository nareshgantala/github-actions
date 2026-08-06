# Stage 1: Download and extract the GitHub Actions runner
FROM redhat/ubi10 AS builder
WORKDIR /tmp/runner
RUN curl -o actions-runner-linux-x64-2.336.0.tar.gz -L \
    https://github.com/actions/runner/releases/download/v2.336.0/actions-runner-linux-x64-2.336.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.336.0.tar.gz && \
    rm -f ./actions-runner-linux-x64-2.336.0.tar.gz

# Stage 2: Final runtime image (clean, no build artifacts)
FROM redhat/ubi10

# Add Docker CE repo and install Docker CLI only
RUN dnf install -y --nodocs dnf-plugins-core && \
    dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo && \
    dnf install -y --nodocs --setopt=install_weak_deps=False \
    docker-ce-cli \
    && dnf clean all

RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf install -y --nodocs --setopt=install_weak_deps=False \
    nodejs golang git mysql8.4 \
    java-21-openjdk-devel maven \
    python3 python3-pip \
    libicu &&  \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/log/dnf* /var/log/hawkey* /tmp/*

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y --nodocs https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm && \
    dnf install -y --nodocs azure-cli && \
    dnf clean all && \
    rm -rf /var/cache/dnf /tmp/*

RUN useradd -m runner
WORKDIR /home/runner/actions-runner

# Copy only the extracted runner files (no tarball in any layer)
COPY --from=builder /tmp/runner/ ./
RUN chown -R runner:runner /home/runner/actions-runner

COPY setup.sh ./setup.sh
RUN chmod +x ./setup.sh

USER runner
CMD ["bash", "-c", "./setup.sh"]