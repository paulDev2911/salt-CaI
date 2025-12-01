{% set timezone = pillar.get('base_server:timezone', 'Europe/Berlin') %}
{% set ntp_servers = pillar.get('base_server:ntp_servers', '0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org') %}

set_timezone:
  timezone.system:
    - name: {{ timezone }}
    - utc: True

{% if grains['os_family'] == 'Debian' %}
install_timesyncd:
  pkg.installed:
    - name: systemd-timesyncd
{% endif %}

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