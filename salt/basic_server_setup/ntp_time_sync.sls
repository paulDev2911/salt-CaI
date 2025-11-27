# Timezone and NTP Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/ntp_time_sync.yml

{% set timezone = pillar.get('basic_server_setup:timezone', 'Europe/Berlin') %}
{% set ntp_servers = pillar.get('basic_server_setup:ntp_servers', '0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org') %}

# Step 1: Set system timezone
set_timezone:
  timezone.system:
    - name: {{ timezone }}
    - utc: True

# Step 2: Install systemd-timesyncd (Debian/Ubuntu only)
{% if grains['os_family'] == 'Debian' %}
install_timesyncd:
  pkg.installed:
    - name: systemd-timesyncd
{% endif %}

# Step 3: Configure NTP servers
{% if grains['os_family'] == 'Debian' %}
configure_timesyncd:
  file.replace:
    - name: /etc/systemd/timesyncd.conf
    - pattern: '^#?NTP=.*'
    - repl: 'NTP={{ ntp_servers }}'
    - append_if_not_found: True
    - require:
      - pkg: install_timesyncd
{% endif %}

# Step 4: Enable and start systemd-timesyncd service
{% if grains['os_family'] == 'Debian' %}
enable_timesyncd:
  service.running:
    - name: systemd-timesyncd
    - enable: True
    - watch:
      - file: configure_timesyncd
    - require:
      - pkg: install_timesyncd
{% endif %}