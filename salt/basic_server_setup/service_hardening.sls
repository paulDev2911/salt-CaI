# Service Hardening - Disable Unnecessary Services
# Converted from Ansible role: roles/basic_server_setup/tasks/disable_unnecessary_services.yml

{% set disable_ipv6 = pillar.get('basic_server_setup:disable_ipv6', False) %}
{% set remove_packages = pillar.get('basic_server_setup:remove_packages_enabled', False) %}

# Services to stop and disable
{% set services_to_disable = [
    'avahi-daemon',
    'cups',
    'cups-browsed',
    'bluetooth',
    'ModemManager'
] %}

# Services to mask (prevent from ever starting)
{% set services_to_mask = [
    'telnet',
    'rsh',
    'rlogin',
    'rexec',
    'ftp',
    'tftp'
] %}

# Packages to remove
{% set packages_to_remove = [
    'telnet',
    'rsh-client',
    'rsh-redone-client'
] %}

# Step 1: Stop and disable unnecessary services
{% for service in services_to_disable %}
disable_{{ service | replace('-', '_') | replace('.', '_') }}:
  service.dead:
    - name: {{ service }}
    - enable: False
    # Don't fail if service doesn't exist
    - onlyif: systemctl list-unit-files | grep -q "^{{ service }}"
{% endfor %}

# Step 2: Mask highly insecure services (prevent them from ever starting)
{% for service in services_to_mask %}
mask_{{ service | replace('-', '_') | replace('.', '_') }}:
  service.masked:
    - name: {{ service }}
    # Don't fail if service doesn't exist
    - onlyif: systemctl list-unit-files | grep -q "^{{ service }}"
{% endfor %}

# Step 3: Remove unnecessary packages (only if enabled in pillar)
{% if remove_packages and grains['os_family'] == 'Debian' %}
remove_insecure_packages:
  pkg.removed:
    - pkgs: {{ packages_to_remove | yaml }}
    - purge: True

# Also run autoremove after package removal
autoremove_after_purge:
  cmd.run:
    - name: apt-get autoremove -y
    - onchanges:
      - pkg: remove_insecure_packages
{% endif %}

# Step 4: Disable IPv6 if configured (disabled by default)
{% if disable_ipv6 %}
disable_ipv6_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 1

disable_ipv6_default:
  sysctl.present:
    - name: net.ipv6.conf.default.disable_ipv6
    - value: 1

disable_ipv6_lo:
  sysctl.present:
    - name: net.ipv6.conf.lo.disable_ipv6
    - value: 1
{% endif %}