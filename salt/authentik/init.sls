{% set ak = pillar.get('authentik', {}) %}
{% set ak_secrets = pillar.get('authentik', {}) %}

# Include Docker State
include:
  - docker
  - caddy_authentik

# Create Authentik directory
authentik_directory:
  file.directory:
    - name: {{ ak.install_dir }}
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True

# Create media directory
authentik_media_directory:
  file.directory:
    - name: {{ ak.install_dir }}/media
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
    - require:
      - file: authentik_directory

# Create custom templates directory
authentik_templates_directory:
  file.directory:
    - name: {{ ak.install_dir }}/custom-templates
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
    - require:
      - file: authentik_directory

# Create certs directory
authentik_certs_directory:
  file.directory:
    - name: {{ ak.install_dir }}/certs
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
    - require:
      - file: authentik_directory

# Generate .env file with secrets
authentik_env_file:
  file.managed:
    - name: {{ ak.env_file }}
    - user: root
    - group: root
    - mode: '0600'
    - contents: |
        # Authentik Configuration - Managed by Salt
        
        # PostgreSQL
        POSTGRES_PASSWORD={{ ak_secrets.postgres_password }}
        POSTGRES_USER={{ ak.postgres.user }}
        POSTGRES_DB={{ ak.postgres.db_name }}
        
        # Authentik
        AUTHENTIK_SECRET_KEY={{ ak_secrets.secret_key }}
        AUTHENTIK_ERROR_REPORTING__ENABLED=false
        AUTHENTIK_DISABLE_UPDATE_CHECK=true
        AUTHENTIK_DISABLE_STARTUP_ANALYTICS=true
        
        # Redis
        AUTHENTIK_REDIS__CACHE_DB={{ ak.redis.cache_db }}
        
        # Email (SMTP)
        AUTHENTIK_EMAIL__HOST={{ ak.email.host }}
        AUTHENTIK_EMAIL__PORT={{ ak.email.port }}
        AUTHENTIK_EMAIL__USERNAME={{ ak_secrets.email_username }}
        AUTHENTIK_EMAIL__PASSWORD={{ ak_secrets.email_password }}
        AUTHENTIK_EMAIL__USE_TLS={{ ak.email.use_tls | lower }}
        AUTHENTIK_EMAIL__USE_SSL={{ ak.email.use_ssl | lower }}
        AUTHENTIK_EMAIL__TIMEOUT={{ ak.email.timeout }}
        AUTHENTIK_EMAIL__FROM={{ ak.email.from }}
    - require:
      - file: authentik_directory

# Deploy docker-compose.yml
authentik_compose_file:
  file.managed:
    - name: {{ ak.compose_file }}
    - source: salt://authentik/files/docker-compose.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - file: authentik_directory
      - file: authentik_env_file

# Pull Docker images
authentik_docker_pull:
  cmd.run:
    - name: docker compose pull
    - cwd: {{ ak.install_dir }}
    - require:
      - file: authentik_compose_file
      - sls: docker

# Start Authentik
authentik_docker_up:
  cmd.run:
    - name: docker compose up -d
    - cwd: {{ ak.install_dir }}
    - require:
      - cmd: authentik_docker_pull
    - onchanges:
      - file: authentik_compose_file
      - file: authentik_env_file

# Deploy Caddy config for Authentik
authentik_caddy_config:
  file.managed:
    - name: /etc/caddy/Caddyfile
    - source: salt://authentik/files/Caddyfile.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - sls: caddy

# Reload Caddy
authentik_caddy_reload:
  cmd.run:
    - name: systemctl reload caddy
    - onchanges:
      - file: authentik_caddy_config