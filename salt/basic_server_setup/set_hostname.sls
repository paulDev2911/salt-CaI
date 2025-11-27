# Hostname Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/set_hostname.yml

{% set hostname = pillar.get('basic_server_setup:hostname', grains['id']) %}

# Only configure hostname if explicitly set in pillar
{% if pillar.get('basic_server_setup:hostname') %}

# Step 1: Set system hostname
set_hostname:
  network.system:
    - enabled: True
    - hostname: {{ hostname }}
    - apply_hostname: True

# Step 2: Update /etc/hosts file from template
configure_hosts_file:
  file.managed:
    - name: /etc/hosts
    - source: salt://basic_server_setup/files/hosts.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - context:
        hostname: {{ hostname }}
    - require:
      - network: set_hostname

{% endif %}