prowlarr_config_directory:
  file.directory:
    - name: /opt/prowlarr/config
    - user: 1000
    - group: 1000
    - mode: 755
    - makedirs: True

prowlarr_stop_old:
  cmd.run:
    - name: docker stop prowlarr && docker rm prowlarr || true
    - onlyif: docker ps -a | grep -q prowlarr

prowlarr_pull_image:
  cmd.run:
    - name: docker pull lscr.io/linuxserver/prowlarr:latest
    - require:
      - file: prowlarr_config_directory

prowlarr_container:
  cmd.run:
    - name: |
        docker run -d \
          --name prowlarr \
          --network media-net \
          -e PUID=1000 \
          -e PGID=1000 \
          -e TZ=Europe/Berlin \
          -p 9696:9696 \
          -v /opt/prowlarr/config:/config \
          --restart unless-stopped \
          lscr.io/linuxserver/prowlarr:latest
    - unless: docker ps | grep -q prowlarr
    - require:
      - cmd: prowlarr_pull_image
      - file: prowlarr_config_directory