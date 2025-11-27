authentik:
  dir: /opt/authentik

  # Offizielle docker-compose Datei
  compose_url: https://docs.goauthentik.io/docker-compose.yml

  # Woher die .env kommt
  env_source: salt://authentik/files/authentik.env

  # Permissions
  mode_dir: "0755"
  mode_env: "0600"
  mode_compose: "0644"
