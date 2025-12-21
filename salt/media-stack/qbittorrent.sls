# /srv/salt/media-stack/qbittorrent.sls

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