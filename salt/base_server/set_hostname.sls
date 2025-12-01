{% set hostname = pillar.get('base_server:hostname', grains['id']) %}

{% if pillar.get('base_server:hostname') %}

set_hostname:
  network.system:
    - enabled: True
    - hostname: {{ hostname }}
    - apply_hostname: True

configure_hosts_file:
  file.managed:
    - name: /etc/hosts
    - source: salt://base_server/files/hosts.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - context:
        hostname: {{ hostname }}
    - require:
      - network: set_hostname

{% endif %}