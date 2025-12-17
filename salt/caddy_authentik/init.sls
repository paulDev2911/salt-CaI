# Caddy für Authentik VM

caddy_prerequisites:
  pkg.installed:
    - pkgs:
      - debian-keyring
      - debian-archive-keyring
      - apt-transport-https
      - curl

caddy_gpg_key:
  cmd.run:
    - name: curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg

caddy_repo:
  cmd.run:
    - name: curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    - unless: test -f /etc/apt/sources.list.d/caddy-stable.list

caddy_install:
  pkg.installed:
    - name: caddy
    - require:
      - cmd: caddy_repo

caddy_service:
  service.running:
    - name: caddy
    - enable: True