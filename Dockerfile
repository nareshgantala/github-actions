FROM redhat/ubi10
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && dnf install -y nodejs