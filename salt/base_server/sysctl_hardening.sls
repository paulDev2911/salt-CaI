{% set ip_forward = pillar.get('base_server:sysctl_ip_forward', 0) %}
{% set ipv6_forwarding = pillar.get('base_server:sysctl_ipv6_forwarding', 0) %}
{% set ignore_ping = pillar.get('base_server:sysctl_ignore_ping', 0) %}
{% set swappiness = pillar.get('base_server:sysctl_swappiness', 10) %}
{% set vfs_cache_pressure = pillar.get('base_server:sysctl_vfs_cache_pressure', 50) %}
{% set inotify_max_watches = pillar.get('base_server:sysctl_inotify_max_watches', 524288) %}
{% set inotify_max_instances = pillar.get('base_server:sysctl_inotify_max_instances', 512) %}
{% set conntrack_max = pillar.get('base_server:sysctl_conntrack_max', 262144) %}
{% set sysrq = pillar.get('base_server:sysctl_sysrq', 0) %}

backup_sysctl_conf:
  file.copy:
    - name: /etc/sysctl.conf.backup
    - source: /etc/sysctl.conf
    - force: False
    - preserve: True
    - user: root
    - group: root
    - mode: '0644'
    - onlyif: test -f /etc/sysctl.conf

sysctl_hardening_config:
  file.managed:
    - name: /etc/sysctl.d/99-hardening.conf
    - source: salt://base_server/files/sysctl-hardening.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - context:
        ip_forward: {{ ip_forward }}
        ipv6_forwarding: {{ ipv6_forwarding }}
        ignore_ping: {{ ignore_ping }}
        swappiness: {{ swappiness }}
        vfs_cache_pressure: {{ vfs_cache_pressure }}
        inotify_max_watches: {{ inotify_max_watches }}
        inotify_max_instances: {{ inotify_max_instances }}
        conntrack_max: {{ conntrack_max }}
        sysrq: {{ sysrq }}

apply_sysctl_hardening:
  cmd.run:
    - name: sysctl -p /etc/sysctl.d/99-hardening.conf
    - onchanges:
      - file: sysctl_hardening_config

{% set critical_sysctls = [
    'net.ipv4.ip_forward',
    'net.ipv4.conf.all.accept_source_route',
    'net.ipv4.icmp_echo_ignore_broadcasts',
    'kernel.randomize_va_space'
] %}

{% for item in critical_sysctls %}
verify_sysctl_{{ item | replace('.', '_') }}:
  cmd.run:
    - name: sysctl {{ item }}
    - require:
      - cmd: apply_sysctl_hardening
{% endfor %}