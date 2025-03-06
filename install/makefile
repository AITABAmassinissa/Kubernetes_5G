all : docker


docker:
	sudo usermod -aG docker $(USER) && sg docker true
	sed -n '44,$$p' setup.sh | bash