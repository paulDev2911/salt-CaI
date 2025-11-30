{% set hostname = pillar.get('basic_server_setup:hostname', grains['id']) %}

{% if pillar.get('basic_server_setup:hostname') %}

set_hostname:
  network.system:
    - enabled: True
    - hostname: {{ hostname }}
    - apply_hostname: True

configure_hosts_file:
  file.managed:
    - name: /etc/hosts
    - source: salt://basic_server_setup/files/hosts.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - context:
        hostname: {{ hostname }}
    - require:
      - network: set_hostname

{% endif %}