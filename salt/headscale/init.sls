{% set headscale_version = pillar.get('headscale:version', '0.23.0') %}
{% set headscale_arch = grains['osarch'] if grains['osarch'] == 'amd64' else 'arm64' %}

headscale_download:
  file.managed:
    - name: /tmp/headscale.deb
    - source: https://github.com/juanfont/headscale/releases/download/v{{ headscale_version }}/headscale_{{ headscale_version }}_linux_{{ headscale_arch }}.deb
    - skip_verify: True
    - unless: dpkg -l | grep -q "headscale.*{{ headscale_version }}"

headscale_install:
  cmd.run:
    - name: apt install -y ./headscale.deb
    - cwd: /tmp
    - require:
      - file: headscale_download
    - unless: dpkg -l | grep -q "headscale.*{{ headscale_version }}"

headscale_config:
  file.managed:
    - name: /etc/headscale/config.yaml
    - source: salt://headscale/files/config.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: headscale_install

headscale_acl:
  file.managed:
    - name: /etc/headscale/acl.json
    - source: salt://headscale/files/acl.json
    - user: headscale
    - group: headscale
    - mode: 640
    - require:
      - cmd: headscale_install

headscale_service:
  service.running:
    - name: headscale
    - enable: True
    - watch:
      - file: headscale_config
      - file: headscale_acl
    - require:
      - cmd: headscale_install
      - file: headscale_acl