authentik:
  dir: /opt/authentik

  compose_url: https://docs.goauthentik.io/docker-compose.yml

  env_source: salt://authentik/files/authentik.env

  mode_dir: "0755"
  mode_env: "0600"
  mode_compose: "0644"
