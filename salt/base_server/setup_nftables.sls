{% set ssh_port = pillar.get('base_server:ssh_port', 22) %}
{% set allowed_ports = pillar.get('base_server:allowed_ports', ['22/tcp']) %}

install_nftables:
  pkg.installed:
    - name: nftables

disable_ufw:
  service.dead:
    - name: ufw
    - enable: False

remove_ufw:
  pkg.removed:
    - name: ufw
    - require:
      - service: disable_ufw

deploy_nftables_config:
  file.managed:
    - name: /etc/nftables.conf
    - source: salt://base_server/files/nftables.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - context:
        ssh_port: {{ ssh_port }}
        allowed_ports: {{ allowed_ports }}
    - require:
      - pkg: install_nftables

nftables_service:
  service.running:
    - name: nftables
    - enable: True
    - watch:
      - file: deploy_nftables_config
    - require:
      - file: deploy_nftables_config

reload_nftables:
  cmd.run:
    - name: nft -f /etc/nftables.conf
    - onchanges:
      - file: deploy_nftables_config

verify_nftables:
  cmd.run:
    - name: nft list ruleset
    - require:
      - service: nftables_service