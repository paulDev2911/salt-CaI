qbittorrent_config_directory:
  file.directory:
    - name: /opt/qbittorrent/config
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

qbittorrent_downloads_directory:
  file.directory:
    - name: /opt/qbittorrent/downloads
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

qbittorrent_gluetun_port:
  cmd.run:
    - name: |
        docker stop gluetun
        docker rm gluetun
        docker run -d \
          --name gluetun \
          --cap-add=NET_ADMIN \
          --device=/dev/net/tun \
          -e VPN_SERVICE_PROVIDER=custom \
          -e VPN_TYPE=wireguard \
          -e VPN_ENDPOINT_IP={{ pillar['mullvad_media']['endpoint'].split(':')[0] }} \
          -e VPN_ENDPOINT_PORT={{ pillar['mullvad_media']['endpoint'].split(':')[1] }} \
          -e WIREGUARD_PRIVATE_KEY={{ pillar['mullvad_media']['private_key'] }} \
          -e WIREGUARD_PUBLIC_KEY={{ pillar['mullvad_media']['public_key'] }} \
          -e WIREGUARD_ADDRESSES={{ pillar['mullvad_media']['addresses'] }} \
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
    - onlyif: docker ps | grep gluetun | grep -qv 8112

# Wait for gluetun to be ready
qbittorrent_wait_gluetun:
  cmd.run:
    - name: sleep 10
    - require:
      - cmd: qbittorrent_gluetun_port

qbittorrent_stop_old:
  cmd.run:
    - name: docker stop qbittorrent && docker rm qbittorrent || true
    - onlyif: docker ps -a | grep -q qbittorrent

qbittorrent_pull_image:
  cmd.run:
    - name: docker pull lscr.io/linuxserver/qbittorrent:latest
    - require:
      - file: qbittorrent_config_directory

qbittorrent_container:
  cmd.run:
    - name: |
        docker run -d \
          --name qbittorrent \
          --network container:gluetun \
          -e PUID=1000 \
          -e PGID=1000 \
          -e TZ=Europe/Berlin \
          -e WEBUI_PORT=8112 \
          -v /opt/qbittorrent/config:/config \
          -v /opt/qbittorrent/downloads:/downloads \
          --restart unless-stopped \
          lscr.io/linuxserver/qbittorrent:latest
    - unless: docker ps | grep -q qbittorrent
    - require:
      - cmd: qbittorrent_wait_gluetun
      - cmd: qbittorrent_pull_image
      - file: qbittorrent_config_directory
      - file: qbittorrent_downloads_directory