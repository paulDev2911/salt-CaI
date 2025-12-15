include:
  - base_server
  - docker

# Firewall: Port 443 öffnen
pomerium_firewall_port:
  file.append:
    - name: /etc/nftables.conf
    - text: |
        # Pomerium HTTPS
        tcp dport 443 accept
    - require:
      - sls: base_server

pomerium_project_dir:
  file.directory:
    - name: {{ pillar['pomerium']['project_dir'] }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

pomerium_config_file:
  file.managed:
    - name: {{ pillar['pomerium']['config_file'] }}
    - source: salt://pomerium/files/config.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: pomerium_project_dir

pomerium_docker_compose_file:
  file.managed:
    - name: {{ pillar['pomerium']['compose_file'] }}
    - source: salt://pomerium/files/docker-compose.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: pomerium_project_dir

pomerium_docker_up:
  cmd.run:
    - name: docker compose up -d
    - cwd: {{ pillar['pomerium']['project_dir'] }}
    - require:
      - file: pomerium_config_file
      - file: pomerium_docker_compose_file
      - sls: docker