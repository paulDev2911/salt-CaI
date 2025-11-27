# User Management for Salt
# Converted from Ansible role: roles/basic_server_setup/tasks/create_user.yml
# NOTE: No 'ansible' user needed - Salt uses salt-minion service

{% set sysadmin_password_hash = pillar.get('basic_server_setup:sysadmin_password_hash', '$6$rounds=656000$YourHashedPasswordHere$ExampleHash') %}

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