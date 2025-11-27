# User Management for Salt
# Converted from Ansible role: roles/basic_server_setup/tasks/create_user.yml
# NOTE: No 'ansible' user needed - Salt uses salt-minion service

{% set sysadmin_password_hash = pillar.get('basic_server_setup:sysadmin_password_hash', '$6$rounds=656000$YourHashedPasswordHere$ExampleHash') %}
{% set sysadmin_ssh_key = pillar.get('basic_server_setup:sysadmin_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') %}

# Step 1: Ensure sysadmin user exists
sysadmin_user:
  user.present:
    - name: sysadmin
    - password: {{ sysadmin_password_hash }}
    - hash_password: False  # Password is already hashed
    - groups:
      - sudo
    - shell: /bin/bash
    - home: /home/sysadmin
    - createhome: True
    - fullname: System Administrator
    - empty_password: False

# Step 2: Ensure .ssh directory exists for sysadmin
sysadmin_ssh_dir:
  file.directory:
    - name: /home/sysadmin/.ssh
    - user: sysadmin
    - group: sysadmin
    - mode: '0700'
    - makedirs: True
    - require:
      - user: sysadmin_user

# Step 3: Add SSH key for sysadmin
sysadmin_ssh_key:
  ssh_auth.present:
    - user: sysadmin
    - name: {{ sysadmin_ssh_key }}
    - require:
      - file: sysadmin_ssh_dir

# Step 4: Ensure correct permissions on authorized_keys
sysadmin_authorized_keys_permissions:
  file.managed:
    - name: /home/sysadmin/.ssh/authorized_keys
    - user: sysadmin
    - group: sysadmin
    - mode: '0600'
    - replace: False
    - require:
      - ssh_auth: sysadmin_ssh_key