radarr_config_directory:
  file.directory:
    - name: /opt/radarr/config
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

radarr_movies_directory:
  file.directory:
    - name: /opt/radarr/movies
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

radarr_stop_old:
  cmd.run:
    - name: docker stop radarr && docker rm radarr || true
    - onlyif: docker ps -a | grep -q radarr

radarr_pull_image:
  cmd.run:
    - name: docker pull lscr.io/linuxserver/radarr:latest
    - require:
      - file: radarr_config_directory

radarr_container:
  cmd.run:
    - name: |
        docker run -d \
          --name radarr \
          --network media-net \
          -e PUID=1000 \
          -e PGID=1000 \
          -e TZ=Europe/Berlin \
          -p 7878:7878 \
          -v /opt/radarr/config:/config \
          -v /opt/radarr/movies:/movies \
          -v /opt/qbittorrent/downloads:/downloads \
          --restart unless-stopped \
          lscr.io/linuxserver/radarr:latest
    - unless: docker ps | grep -q radarr
    - require:
      - cmd: radarr_pull_image
      - file: radarr_config_directory
      - file: radarr_movies_directory