{% set target_arch = 'amd64' if grains['osarch'] == 'x86_64' else 'arm64' if grains['osarch'] == 'aarch64' else 'armhf' if grains['osarch'] == 'armv7l' else 'amd64' %}

# Remove unofficial Docker packages
remove_unofficial_docker_packages:
  pkg.removed:
    - pkgs:
      - docker.io
      - docker-compose
      - docker-doc
      - podman-docker

# Install required packages
docker_prerequisites:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
    - require:
      - pkg: remove_unofficial_docker_packages

# Add Docker GPG key
docker_gpg_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/{{ grains['os']|lower }}/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/docker-archive-keyring.gpg
    - require:
      - pkg: docker_prerequisites

# Add Docker repository
docker_repo:
  pkgrepo.managed:
    - name: deb [arch={{ target_arch }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/{{ grains['os']|lower }} {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - require:
      - cmd: docker_gpg_key

# Install Docker packages
docker_packages:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    - require:
      - pkgrepo: docker_repo

# Ensure Docker service is running
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_packages

# Ensure containerd service is running
containerd_service:
  service.running:
    - name: containerd
    - enable: True
    - require:
      - pkg: docker_packages