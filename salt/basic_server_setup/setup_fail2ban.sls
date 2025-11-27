# Fail2Ban Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/setup_fail2ban.yml

{% set ssh_port = pillar.get('basic_server_setup:ssh_port', 22) %}
{% set bantime = pillar.get('basic_server_setup:fail2ban_bantime', '1h') %}
{% set findtime = pillar.get('basic_server_setup:fail2ban_findtime', '10m') %}
{% set maxretry = pillar.get('basic_server_setup:fail2ban_maxretry', 5) %}
{% set email = pillar.get('basic_server_setup:fail2ban_email', '') %}

# Step 1: Install Fail2Ban (Debian/Ubuntu only)
{% if grains['os_family'] == 'Debian' %}
install_fail2ban:
  pkg.installed:
    - name: fail2ban
{% endif %}

# Step 2: Create Fail2Ban jail.d directory
fail2ban_jail_directory:
  file.directory:
    - name: /etc/fail2ban/jail.d
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_fail2ban
{% endif %}

# Step 3: Deploy Fail2Ban default jail configuration
fail2ban_default_config:
  file.managed:
    - name: /etc/fail2ban/jail.d/custom.local
    - source: salt://basic_server_setup/files/fail2ban-jail.local.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - context:
        bantime: {{ bantime }}
        findtime: {{ findtime }}
        maxretry: {{ maxretry }}
        email: {{ email }}
        hostname: {{ grains['host'] }}
    - require:
      - file: fail2ban_jail_directory

# Step 4: Deploy Fail2Ban SSH jail configuration
fail2ban_sshd_config:
  file.managed:
    - name: /etc/fail2ban/jail.d/sshd.local
    - source: salt://basic_server_setup/files/fail2ban-sshd.local.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - context:
        ssh_port: {{ ssh_port }}
        bantime: {{ bantime }}
        findtime: {{ findtime }}
        maxretry: {{ maxretry }}
    - require:
      - file: fail2ban_jail_directory

# Step 5: Enable and start Fail2Ban service
fail2ban_service:
  service.running:
    - name: fail2ban
    - enable: True
    - watch:
      - file: fail2ban_default_config
      - file: fail2ban_sshd_config
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_fail2ban
{% endif %}

# Step 6: Wait for Fail2Ban to fully start
wait_for_fail2ban:
  cmd.run:
    - name: sleep 3
    - onchanges:
      - service: fail2ban_service

# Step 7: Get Fail2Ban status (for verification)
get_fail2ban_status:
  cmd.run:
    - name: fail2ban-client status
    - require:
      - service: fail2ban_service