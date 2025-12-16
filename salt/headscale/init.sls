{% set headscale_version = pillar.get('headscale:version', '0.23.0') %}
{% set headscale_arch = grains['osarch'] if grains['osarch'] == 'amd64' else 'arm64' %}

headscale_download:
  file.managed:
    - name: /tmp/headscale.deb
    - source: https://github.com/juanfont/headscale/releases/download/v{{ headscale_version }}/headscale_{{ headscale_version }}_linux_{{ headscale_arch }}.deb
    - skip_verify: False
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
    - source: salt://headscale/files/config.yaml.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: headscale_install

headscale_service:
  service.running:
    - name: headscale
    - enable: True
    - watch:
      - file: headscale_config
    - require:
      - cmd: headscale_install