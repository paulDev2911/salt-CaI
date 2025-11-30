{% set ssh_port = pillar.get('basic_server_setup:ssh_port', 22) %}
{% set ssh_listen_address = pillar.get('basic_server_setup:ssh_listen_address', '') %}
{% set permit_root_login = pillar.get('basic_server_setup:ssh_permit_root_login', 'no') %}
{% set max_auth_tries = pillar.get('basic_server_setup:ssh_max_auth_tries', 3) %}
{% set pubkey_authentication = pillar.get('basic_server_setup:ssh_pubkey_authentication', 'yes') %}
{% set password_authentication = pillar.get('basic_server_setup:ssh_password_authentication', 'no') %}
{% set x11_forwarding = pillar.get('basic_server_setup:ssh_x11_forwarding', 'no') %}
{% set client_alive_interval = pillar.get('basic_server_setup:ssh_client_alive_interval', 300) %}
{% set client_alive_count_max = pillar.get('basic_server_setup:ssh_client_alive_count_max', 3) %}
{% set accept_env = pillar.get('basic_server_setup:ssh_accept_env', True) %}
{% set enable_sftp = pillar.get('basic_server_setup:ssh_enable_sftp', True) %}
{% set allow_users = pillar.get('basic_server_setup:ssh_allow_users', ['ansible', 'sysadmin']) %}
{% set enable_banner = pillar.get('basic_server_setup:ssh_enable_banner', False) %}
{% set banner_path = pillar.get('basic_server_setup:ssh_banner_path', '/etc/ssh/banner.txt') %}

backup_sshd_config:
  file.copy:
    - name: /etc/ssh/sshd_config.backup
    - source: /etc/ssh/sshd_config
    - force: False
    - preserve: True
    - user: root
    - group: root
    - mode: '0600'

configure_sshd:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://roles/basic_server_setup/files/sshd_config.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0600'
    - backup: minion
    - context:
        ssh_port: {{ ssh_port }}
        ssh_listen_address: {{ ssh_listen_address }}
        permit_root_login: {{ permit_root_login }}
        max_auth_tries: {{ max_auth_tries }}
        pubkey_authentication: {{ pubkey_authentication }}
        password_authentication: {{ password_authentication }}
        x11_forwarding: {{ x11_forwarding }}
        client_alive_interval: {{ client_alive_interval }}
        client_alive_count_max: {{ client_alive_count_max }}
        accept_env: {{ accept_env }}
        enable_sftp: {{ enable_sftp }}
        allow_users: {{ allow_users }}
        enable_banner: {{ enable_banner }}
        banner_path: {{ banner_path }}
    - require:
      - file: backup_sshd_config

validate_sshd_config:
  cmd.run:
    - name: /usr/sbin/sshd -t -f /etc/ssh/sshd_config
    - onchanges:
      - file: configure_sshd

{% if enable_banner %}
deploy_ssh_banner:
  file.managed:
    - name: {{ banner_path }}
    - source: salt://roles/basic_server_setup/files/ssh_banner.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
{% endif %}

ssh_service:
  service.running:
    - name: ssh
    - enable: True
    - watch:
      - file: configure_sshd
    - require:
      - cmd: validate_sshd_config