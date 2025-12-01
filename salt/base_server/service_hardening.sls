{% set disable_ipv6 = pillar.get('base_server:disable_ipv6', False) %}
{% set remove_packages = pillar.get('base_server:remove_packages_enabled', False) %}

{% set services_to_disable = [
    'avahi-daemon',
    'cups',
    'cups-browsed',
    'bluetooth',
    'ModemManager'
] %}

{% set services_to_mask = [
    'telnet',
    'rsh',
    'rlogin',
    'rexec',
    'ftp',
    'tftp'
] %}

{% set packages_to_remove = [
    'telnet',
    'rsh-client',
    'rsh-redone-client'
] %}

{% for service in services_to_disable %}
disable_{{ service | replace('-', '_') | replace('.', '_') }}:
  service.dead:
    - name: {{ service }}
    - enable: False
    - onlyif: systemctl list-unit-files | grep -q "^{{ service }}"
{% endfor %}

{% for service in services_to_mask %}
mask_{{ service | replace('-', '_') | replace('.', '_') }}:
  service.masked:
    - name: {{ service }}
    - onlyif: systemctl list-unit-files | grep -q "^{{ service }}"
{% endfor %}

{% if remove_packages and grains['os_family'] == 'Debian' %}
remove_insecure_packages:
  pkg.removed:
    - pkgs: {{ packages_to_remove | yaml }}
    - purge: True

autoremove_after_purge:
  cmd.run:
    - name: apt-get autoremove -y
    - onchanges:
      - pkg: remove_insecure_packages
{% endif %}

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