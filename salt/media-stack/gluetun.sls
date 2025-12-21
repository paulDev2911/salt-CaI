# /srv/salt/media-stack/gluetun.sls

gluetun_network:
  docker_network.present:
    - name: media-net
    - driver: bridge

gluetun_directory:
  file.directory:
    - name: /opt/gluetun
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

gluetun_container:
  docker_container.running:
    - name: gluetun
    - image: qmcgaw/gluetun:latest
    - cap_add:
      - NET_ADMIN
    - devices:
      - /dev/net/tun
    - environment:
      - VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=wireguard
      - VPN_ENDPOINT_IP={{ pillar['mullvad_media']['endpoint'].split(':')[0] }}
      - VPN_ENDPOINT_PORT={{ pillar['mullvad_media']['endpoint'].split(':')[1] }}
      - WIREGUARD_PRIVATE_KEY={{ pillar['mullvad_media']['private_key'] }}
      - WIREGUARD_PUBLIC_KEY={{ pillar['mullvad_media']['public_key'] }}
      - WIREGUARD_ADDRESSES={{ pillar['mullvad_media']['addresses'] }}
      - TZ=Europe/Berlin
      - FIREWALL_VPN_INPUT_PORTS=8112
      - HTTPPROXY=off
      - SHADOWSOCKS=off
    - ports:
      - "8888:8888/tcp"
      - "8388:8388/tcp"
      - "8388:8388/udp"
    - networks:
      - media-net
    - restart_policy: unless-stopped
    - volumes:
      - /opt/gluetun:/gluetun
    - require:
      - docker_network: gluetun_network
      - file: gluetun_directory