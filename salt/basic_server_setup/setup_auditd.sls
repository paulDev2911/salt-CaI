# Auditd Security Auditing Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/setup_auditd.yml

{% set max_log_file = pillar.get('basic_server_setup:auditd_max_log_file', 8) %}
{% set max_log_file_action = pillar.get('basic_server_setup:auditd_max_log_file_action', 'ROTATE') %}
{% set space_left = pillar.get('basic_server_setup:auditd_space_left', 75) %}
{% set space_left_action = pillar.get('basic_server_setup:auditd_space_left_action', 'SYSLOG') %}
{% set admin_space_left = pillar.get('basic_server_setup:auditd_admin_space_left', 50) %}
{% set admin_space_left_action = pillar.get('basic_server_setup:auditd_admin_space_left_action', 'SUSPEND') %}
{% set disk_full_action = pillar.get('basic_server_setup:auditd_disk_full_action', 'SUSPEND') %}
{% set disk_error_action = pillar.get('basic_server_setup:auditd_disk_error_action', 'SUSPEND') %}

# Step 1: Install auditd packages (Debian/Ubuntu only)
{% if grains['os_family'] == 'Debian' %}
install_auditd_packages:
  pkg.installed:
    - pkgs:
      - auditd
      - audispd-plugins
{% endif %}

# Step 2: Ensure auditd configuration directory exists
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

# Step 3: Deploy custom audit rules from template
deploy_audit_rules:
  file.managed:
    - name: /etc/audit/rules.d/custom.rules
    - source: salt://basic_server_setup/files/auditd-rules.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0640'
    - backup: minion
    - require:
      - file: auditd_rules_directory

# Step 4: Configure auditd.conf from template
configure_auditd:
  file.managed:
    - name: /etc/audit/auditd.conf
    - source: salt://basic_server_setup/files/auditd.conf.j2
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

# Step 5: Load audit rules FIRST (before starting service)
load_audit_rules_initial:
  cmd.run:
    - name: augenrules --load
    - require:
      - file: deploy_audit_rules
      - pkg: install_auditd_packages

# Step 6: Enable and start auditd service
auditd_service:
  service.running:
    - name: auditd
    - enable: True
    - reload: False
    - require:
      - cmd: load_audit_rules_initial
      - file: configure_auditd

# Step 7: Get auditd status (for verification)
get_auditd_status:
  cmd.run:
    - name: auditctl -s
    - require:
      - service: auditd_service