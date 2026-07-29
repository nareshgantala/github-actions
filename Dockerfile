FROM redhat/ubi10
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && dnf install -y nodejs
RUN dnf install -y golang git mysql8.4
RUN dnf install -y java-21-openjdk java-21-openjdk-devel maven mysql8.4
RUN dnf install -y python3 python3-pip