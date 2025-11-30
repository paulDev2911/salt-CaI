{# Pillar-Variablen laden #}
{% set auth_dir = pillar.get('authentik:dir', '/opt/authentik') %}
{% set compose_url = pillar.get('authentik:compose_url', 'https://docs.goauthentik.io/docker-compose.yml') %}
{% set env_source = pillar.get('authentik:env_source', 'salt://authentik/files/authentik.env') %}
{% set mode_dir = pillar.get('authentik:mode_dir', '0755') %}
{% set mode_env = pillar.get('authentik:mode_env', '0600') %}
{% set mode_compose = pillar.get('authentik:mode_compose', '0644') %}

update_apt_cache:
  pkg.refresh_db:
    - refresh: True
    - onlyif: test "$(salt-call --local grains.get os_family)" = "Debian"

include:
  - basic_server_setup
  - setup_docker

authentik_directories:
  file.directory:
    - names:
      - {{ auth_dir }}
      - {{ auth_dir }}/media
      - {{ auth_dir }}/custom-templates
      - {{ auth_dir }}/certs
    - mode: {{ mode_dir }}

authentik_compose_file:
  file.managed:
    - name: {{ auth_dir }}/docker-compose.yml
    - source: {{ compose_url }}
    - mode: {{ mode_compose }}

authentik_env_file:
  file.managed:
    - name: {{ auth_dir }}/.env
    - source: {{ env_source }}
    - mode: {{ mode_env }}

authentik_docker_pull:
  cmd.run:
    - name: docker compose -f {{ auth_dir }}/docker-compose.yml pull
    - cwd: {{ auth_dir }}
    - require:
      - file: authentik_compose_file
      - file: authentik_env_file

authentik_start:
  cmd.run:
    - name: docker compose -f {{ auth_dir }}/docker-compose.yml up -d
    - cwd: {{ auth_dir }}
    - require:
      - cmd: authentik_docker_pull
