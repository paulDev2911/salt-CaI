# Caddy Installation und Konfiguration für Headscale

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
    - require:
      - pkg: caddy_prerequisites

caddy_repo:
  cmd.run:
    - name: curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    - unless: test -f /etc/apt/sources.list.d/caddy-stable.list
    - require:
      - cmd: caddy_gpg_key

caddy_apt_update:
  cmd.run:
    - name: apt update
    - onchanges:
      - cmd: caddy_repo

caddy_install:
  pkg.installed:
    - name: caddy
    - require:
      - cmd: caddy_apt_update

caddy_config:
  file.managed:
    - name: /etc/caddy/Caddyfile
    - source: salt://caddy/files/Caddyfile.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - pkg: caddy_install

caddy_service:
  service.running:
    - name: caddy
    - enable: True
    - watch:
      - file: caddy_config
    - require:
      - pkg: caddy_install
      - file: caddy_config
```

---

```
{% set hs = pillar.get('headscale', {}) %}
{% set domain = hs.caddy.get('domain', 'headscale.example.com') %}

{{ domain }} {
    reverse_proxy localhost:8080 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
}