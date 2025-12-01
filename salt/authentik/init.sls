{# Pillar-Variablen laden #}
{% set auth_dir = pillar.get('authentik:dir', '/opt/authentik') %}
{% set compose_url = pillar.get('authentik:compose_url', 'https://goauthentik.io/docker-compose.yml') %}
{% set mode_dir = pillar.get('authentik:mode_dir', '0755') %}
{% set mode_env = pillar.get('authentik:mode_env', '0600') %}
{% set mode_compose = pillar.get('authentik:mode_compose', '0644') %}

include:
  - base_server
  - docker

authentik_directories:
  file.directory:
    - names:
      - {{ auth_dir }}
      - {{ auth_dir }}/media
      - {{ auth_dir }}/custom-templates
      - {{ auth_dir }}/certs
    - mode: {{ mode_dir }}
    - makedirs: True

generate_authentik_secrets:
  cmd.run:
    - name: |
        echo "PG_PASS=$(openssl rand -base64 36 | tr -d '\n')" > {{ auth_dir }}/.env
        echo "AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')" >> {{ auth_dir }}/.env
        echo "AUTHENTIK_ERROR_REPORTING__ENABLED=false" >> {{ auth_dir }}/.env
        chmod {{ mode_env }} {{ auth_dir }}/.env
    - creates: {{ auth_dir }}/.env
    - require:
      - file: authentik_directories

authentik_compose_file:
  file.managed:
    - name: {{ auth_dir }}/docker-compose.yml
    - source: {{ compose_url }}
    - skip_verify: True
    - mode: {{ mode_compose }}
    - require:
      - file: authentik_directories

authentik_docker_pull:
  cmd.run:
    - name: docker compose -f {{ auth_dir }}/docker-compose.yml pull
    - cwd: {{ auth_dir }}
    - require:
      - file: authentik_compose_file
      - cmd: generate_authentik_secrets

authentik_start:
  cmd.run:
    - name: docker compose -f {{ auth_dir }}/docker-compose.yml up -d
    - cwd: {{ auth_dir }}
    - require:
      - cmd: authentik_docker_pull