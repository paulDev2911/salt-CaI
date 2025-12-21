{% set slskd = pillar['slskd'] %}

slskd_config_directory:
  file.directory:
    - name: /opt/slskd/config
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

slskd_downloads_directory:
  file.directory:
    - name: /opt/slskd/music
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

slskd_incomplete_directory:
  file.directory:
    - name: /opt/slskd/incomplete
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

slskd_update_gluetun:
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
          -e FIREWALL_VPN_INPUT_PORTS=8112,5030 \
          -e HTTPPROXY=off \
          -e SHADOWSOCKS=off \
          -p 8888:8888/tcp \
          -p 8388:8388/tcp \
          -p 8388:8388/udp \
          -p 8112:8112/tcp \
          -p 5030:5030/tcp \
          -p 5031:5031/tcp \
          -v /opt/gluetun:/gluetun \
          --network media-net \
          --restart unless-stopped \
          qmcgaw/gluetun:latest
    - onlyif: docker ps | grep gluetun | grep -qv 5030

slskd_wait_gluetun:
  cmd.run:
    - name: sleep 10
    - require:
      - cmd: slskd_update_gluetun

slskd_stop_old:
  cmd.run:
    - name: docker stop slskd && docker rm slskd || true
    - onlyif: docker ps -a | grep -q slskd

slskd_pull_image:
  cmd.run:
    - name: docker pull slskd/slskd:latest
    - require:
      - file: slskd_config_directory

slskd_container:
  cmd.run:
    - name: |
        docker run -d \
          --name slskd \
          --network container:gluetun \
          -e SLSKD_SLSK_USERNAME={{ pillar['slskd']['username'] }} \
          -e SLSKD_SLSK_PASSWORD={{ pillar['slskd']['password'] }} \
          -e SLSKD_NO_AUTH=true \
          -e SLSKD_SLSK_LISTEN_PORT=2234 \
          -e PUID=1000 \
          -e PGID=1000 \
          -v /opt/slskd/config:/app \
          -v /mnt/media/music:/music \
          -v /opt/slskd/incomplete:/incomplete \
          --restart unless-stopped \
          slskd/slskd:latest \
          --slsk-listen-port 2234 \
          --downloads /music \
          --incomplete /incomplete \
          --shared /music
    - unless: docker ps | grep -q slskd
    - require:
      - cmd: slskd_wait_gluetun
      - cmd: slskd_pull_image
      - file: slskd_config_directory
      - file: slskd_downloads_directory
      - file: slskd_incomplete_directory