# /srv/salt/media-stack/gluetun.sls
{% set mullvad = pillar['mullvad_media'] %}
{% set endpoint_ip = mullvad['endpoint'].split(':')[0] %}
{% set endpoint_port = mullvad['endpoint'].split(':')[1] %}

# Create directory
gluetun_directory:
  file.directory:
    - name: /opt/gluetun
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

# Create docker network
gluetun_network_create:
  cmd.run:
    - name: docker network create media-net || true
    - unless: docker network inspect media-net

# Stop old container if exists
gluetun_stop_old:
  cmd.run:
    - name: docker stop gluetun && docker rm gluetun || true
    - onlyif: docker ps -a | grep -q gluetun

# Pull image
gluetun_pull_image:
  cmd.run:
    - name: docker pull qmcgaw/gluetun:latest
    - require:
      - file: gluetun_directory

# Run container
gluetun_container:
  cmd.run:
    - name: |
        docker run -d \
          --name gluetun \
          --cap-add=NET_ADMIN \
          --device=/dev/net/tun \
          -e VPN_SERVICE_PROVIDER=custom \
          -e VPN_TYPE=wireguard \
          -e VPN_ENDPOINT_IP={{ endpoint_ip }} \
          -e VPN_ENDPOINT_PORT={{ endpoint_port }} \
          -e WIREGUARD_PRIVATE_KEY={{ mullvad['private_key'] }} \
          -e WIREGUARD_PUBLIC_KEY={{ mullvad['public_key'] }} \
          -e WIREGUARD_ADDRESSES={{ mullvad['addresses'] }} \
          -e TZ=Europe/Berlin \
          -e FIREWALL_VPN_INPUT_PORTS=8112 \
          -e HTTPPROXY=off \
          -e SHADOWSOCKS=off \
          -p 8888:8888/tcp \
          -p 8388:8388/tcp \
          -p 8388:8388/udp \
          -p 8112:8112/tcp \
          -v /opt/gluetun:/gluetun \
          --network media-net \
          --restart unless-stopped \
          qmcgaw/gluetun:latest
    - unless: docker ps | grep -q gluetun
    - require:
      - cmd: gluetun_network_create
      - cmd: gluetun_pull_image
      - file: gluetun_directory

# Wait for container to be healthy
gluetun_wait_healthy:
  cmd.run:
    - name: sleep 5
    - require:
      - cmd: gluetun_container