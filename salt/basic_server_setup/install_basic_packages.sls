# Install Essential Packages - Multi-platform support
# Converted from Ansible role: roles/basic_server_setup/tasks/install_basic_packages.yml

# Debian/Ubuntu packages
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

# RedHat/CentOS packages
{% if grains['os_family'] == 'RedHat' %}
install_redhat_packages:
  pkg.installed:
    - pkgs: []
    - refresh: True
{% endif %}

# FreeBSD packages
{% if grains['os_family'] == 'FreeBSD' %}
install_freebsd_packages:
  pkg.installed:
    - pkgs: []
{% endif %}