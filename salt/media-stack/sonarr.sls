sonarr_config_directory:
  file.directory:
    - name: /opt/sonarr/config
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

sonarr_tv_directory:
  file.directory:
    - name: /opt/sonarr/tv
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

sonarr_stop_old:
  cmd.run:
    - name: docker stop sonarr && docker rm sonarr || true
    - onlyif: docker ps -a | grep -q sonarr

sonarr_pull_image:
  cmd.run:
    - name: docker pull lscr.io/linuxserver/sonarr:latest
    - require:
      - file: sonarr_config_directory

sonarr_container:
  cmd.run:
    - name: |
        docker run -d \
          --name sonarr \
          --network media-net \
          -e PUID=1000 \
          -e PGID=1000 \
          -e TZ=Europe/Berlin \
          -p 8989:8989 \
          -v /opt/sonarr/config:/config \
          -v /opt/sonarr/tv:/tv \
          -v /opt/qbittorrent/downloads:/downloads \
          --restart unless-stopped \
          lscr.io/linuxserver/sonarr:latest
    - unless: docker ps | grep -q sonarr
    - require:
      - cmd: sonarr_pull_image
      - file: sonarr_config_directory
      - file: sonarr_tv_directory