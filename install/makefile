all : docker


docker:
	sudo usermod -aG docker $(USER) && newgrp docker
	sed -n '44,$$p' setup.sh | bash