.PHONY: all install setup install-script clean help

# Default target
all: install setup install-script

# Install cgroup-tools package
install:
	@echo "Installing cgroup-tools package..."
	sudo apt-get update
	sudo apt-get install -y cgroup-tools

# Create Minecraft cgroup
setup:
	@echo "Setting up Minecraft cgroup..."
	@if [ ! -d /sys/fs/cgroup/minecraft ]; then \
		sudo mkdir -p /sys/fs/cgroup/minecraft; \
		echo "Created cgroup directory: /sys/fs/cgroup/minecraft"; \
	else \
		echo "Cgroup directory already exists: /sys/fs/cgroup/minecraft"; \
	fi

# Install mc-cpu script to /usr/local/bin
install-script:
	@echo "Installing mc-cpu script..."
	sudo cp mc-cpu /usr/local/bin/mc-cpu
	sudo chmod +x /usr/local/bin/mc-cpu
	@echo "Installed mc-cpu to /usr/local/bin/mc-cpu"

# Remove installed script
clean:
	@echo "Removing installed script..."
	sudo rm -f /usr/local/bin/mc-cpu
	@echo "Removed /usr/local/bin/mc-cpu"

# Display help
help:
	@echo "Minecraft CPU Control - Makefile Targets:"
	@echo "  make all          - Install packages, setup cgroup, and install script"
	@echo "  make install      - Install cgroup-tools package"
	@echo "  make setup        - Create /sys/fs/cgroup/minecraft cgroup"
	@echo "  make install-script - Install mc-cpu script to /usr/local/bin"
	@echo "  make clean        - Remove installed script"
	@echo "  make help         - Display this help message"
