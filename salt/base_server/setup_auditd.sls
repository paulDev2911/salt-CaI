{% set max_log_file = pillar.get('base_server:auditd_max_log_file', 8) %}
{% set max_log_file_action = pillar.get('base_server:auditd_max_log_file_action', 'ROTATE') %}
{% set space_left = pillar.get('base_server:auditd_space_left', 75) %}
{% set space_left_action = pillar.get('base_server:auditd_space_left_action', 'SYSLOG') %}
{% set admin_space_left = pillar.get('base_server:auditd_admin_space_left', 50) %}
{% set admin_space_left_action = pillar.get('base_server:auditd_admin_space_left_action', 'SUSPEND') %}
{% set disk_full_action = pillar.get('base_server:auditd_disk_full_action', 'SUSPEND') %}
{% set disk_error_action = pillar.get('base_server:auditd_disk_error_action', 'SUSPEND') %}

{% if grains['os_family'] == 'Debian' %}
install_auditd_packages:
  pkg.installed:
    - pkgs:
      - auditd
      - audispd-plugins
{% endif %}

auditd_rules_directory:
  file.directory:
    - name: /etc/audit/rules.d
    - user: root
    - group: root
    - mode: '0750'
    - makedirs: True
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_auditd_packages
{% endif %}

deploy_audit_rules:
  file.managed:
    - name: /etc/audit/rules.d/custom.rules
    - source: salt://base_server/files/auditd_rules.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0640'
    - backup: minion
    - require:
      - file: auditd_rules_directory

configure_auditd:
  file.managed:
    - name: /etc/audit/auditd.conf
    - source: salt://base_server/files/auditd.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0640'
    - backup: minion
    - context:
        max_log_file: {{ max_log_file }}
        max_log_file_action: {{ max_log_file_action }}
        space_left: {{ space_left }}
        space_left_action: {{ space_left_action }}
        admin_space_left: {{ admin_space_left }}
        admin_space_left_action: {{ admin_space_left_action }}
        disk_full_action: {{ disk_full_action }}
        disk_error_action: {{ disk_error_action }}
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_auditd_packages
{% endif %}

auditd_service:
  service.running:
    - name: auditd
    - enable: True
    - require:
      - pkg: install_auditd_packages
      - file: deploy_audit_rules
      - file: configure_auditd

reload_audit_rules:
  cmd.run:
    - name: service auditd restart
    - onchanges:
      - file: deploy_audit_rules
    - require:
      - service: auditd_service

get_auditd_status:
  cmd.run:
    - name: auditctl -s
    - require:
      - service: auditd_service