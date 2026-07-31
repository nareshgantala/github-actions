install:
	echo "install docker"
	sudo dnf remove docker \
					docker-client \
					docker-client-latest \
					docker-common \
					docker-latest \
					docker-latest-logrotate \
					docker-logrotate \
					docker-engine \
					podman \
					runc

	sudo dnf -y install dnf-plugins-core
	sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
	sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	sudo systemctl enable --now docker
up:
	git pull
	sudo docker compose down	
	sudo docker compose up -d --build

down:
	sudo docker compose down

logs:
	sudo docker compose logs -f

	