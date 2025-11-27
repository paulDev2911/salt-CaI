# Enhanced Logging Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/setup_logging.yml

{% set journald_max_use = pillar.get('basic_server_setup:journald_max_use', '500M') %}
{% set journald_retention = pillar.get('basic_server_setup:journald_retention', '1month') %}
{% set remote_server = pillar.get('basic_server_setup:rsyslog_remote_server', '') %}
{% set remote_port = pillar.get('basic_server_setup:rsyslog_remote_port', 514) %}

# Step 1: Install rsyslog (Debian/Ubuntu only)
{% if grains['os_family'] == 'Debian' %}
install_rsyslog:
  pkg.installed:
    - name: rsyslog
{% endif %}

# Step 2: Deploy custom rsyslog configuration from template
configure_rsyslog_hardening:
  file.managed:
    - name: /etc/rsyslog.d/50-hardening.conf
    - source: salt://basic_server_setup/files/rsyslog-hardening.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - context:
        remote_server: {{ remote_server }}
        remote_port: {{ remote_port }}
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_rsyslog
{% endif %}

# Step 3: Configure logrotate for security logs from template
configure_logrotate_security:
  file.managed:
    - name: /etc/logrotate.d/security
    - source: salt://basic_server_setup/files/logrotate-security.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'

# Step 4: Set proper permissions on log directories
set_varlog_permissions:
  file.directory:
    - name: /var/log
    - user: root
    - group: adm
    - mode: '0750'
    - recurse:
      - mode

set_audit_log_permissions:
  file.directory:
    - name: /var/log/audit
    - user: root
    - group: adm
    - mode: '0750'
    - makedirs: True

# Step 5: Enable and start rsyslog service
rsyslog_service:
  service.running:
    - name: rsyslog
    - enable: True
    - watch:
      - file: configure_rsyslog_hardening
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_rsyslog
{% endif %}

# Step 6: Configure journald retention settings
configure_journald_system_max_use:
  file.replace:
    - name: /etc/systemd/journald.conf
    - pattern: '^#?SystemMaxUse=.*'
    - repl: 'SystemMaxUse={{ journald_max_use }}'
    - append_if_not_found: True
    - backup: False

configure_journald_max_retention:
  file.replace:
    - name: /etc/systemd/journald.conf
    - pattern: '^#?MaxRetentionSec=.*'
    - repl: 'MaxRetentionSec={{ journald_retention }}'
    - append_if_not_found: True
    - backup: False

configure_journald_forward_to_syslog:
  file.replace:
    - name: /etc/systemd/journald.conf
    - pattern: '^#?ForwardToSyslog=.*'
    - repl: 'ForwardToSyslog=yes'
    - append_if_not_found: True
    - backup: False

# Step 7: Restart journald when configuration changes
restart_journald:
  service.running:
    - name: systemd-journald
    - watch:
      - file: configure_journald_system_max_use
      - file: configure_journald_max_retention
      - file: configure_journald_forward_to_syslog