{% if grains['os_family'] == 'Debian' %}
install_debian_packages:
  pkg.installed:
    - pkgs:
      - htop
      - tmux
      - nano
      - curl
      - wget
      - git
      - net-tools
      - unattended-upgrades
      - apt-listchanges
      - fail2ban
      - auditd
      - rsyslog
      - ufw
    - refresh: True
    - cache_valid_time: 3600
{% endif %}

{% if grains['os_family'] == 'RedHat' %}
install_redhat_packages:
  pkg.installed:
    - pkgs: []
    - refresh: True
{% endif %}

{% if grains['os_family'] == 'FreeBSD' %}
install_freebsd_packages:
  pkg.installed:
    - pkgs: []
{% endif %}