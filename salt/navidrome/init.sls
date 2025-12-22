include:
  - docker
  - caddy_navidrome
  - navidrome.mount_storage
  - navidrome.install_headscale_client

# Create Navidrome directories
navidrome_directory:
  file.directory:
    - name: {{ pillar['navidrome']['install_dir'] }}
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True

navidrome_data_directory:
  file.directory:
    - name: {{ pillar['navidrome']['data_dir'] }}
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
    - require:
      - file: navidrome_directory

# Deploy docker-compose.yml
navidrome_compose_file:
  file.managed:
    - name: {{ pillar['navidrome']['compose_file'] }}
    - source: salt://navidrome/files/docker-compose.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: navidrome_directory
      - sls: docker
      - sls: navidrome.mount_storage

# Pull Docker image
navidrome_docker_pull:
  cmd.run:
    - name: docker compose pull
    - cwd: {{ pillar['navidrome']['install_dir'] }}
    - require:
      - file: navidrome_compose_file

# Start Navidrome
navidrome_docker_up:
  cmd.run:
    - name: docker compose up -d
    - cwd: {{ pillar['navidrome']['install_dir'] }}
    - require:
      - cmd: navidrome_docker_pull
    - onchanges:
      - file: navidrome_compose_file

# Deploy Caddy config
navidrome_caddy_config:
  file.managed:
    - name: /etc/caddy/Caddyfile
    - source: salt://navidrome/files/Caddyfile.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'

# Reload Caddy
navidrome_caddy_reload:
  cmd.run:
    - name: systemctl reload caddy
    - onchanges:
      - file: navidrome_caddy_config