FROM redhat/ubi10
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && dnf install -y nodejs
RUN dnf install -y golang git mysql8.4
RUN dnf install -y java-21-openjdk java-21-openjdk-devel maven mysql8.4
RUN dnf install -y python3 python3-pip
RUN useradd -m runner
WORKDIR /home/runner/actions-runner
RUN curl -o actions-runner-linux-x64-2.336.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.336.0/actions-runner-linux-x64-2.336.0.tar.gz
RUN tar xzf ./actions-runner-linux-x64-2.336.0.tar.gz
USER runner
RUN ./config.sh --url https://github.com/naresh-gantala-roboshop-project/roboshop-cart --token BIFZDOK4E6NYHWHJI3SDL4DKNICN4 --unattended --replace
CMD ["bash" "-c" "run.sh"]