# SSH Key Management for Users
# Converted from Ansible role: roles/basic_server_setup/tasks/add_ssh_key.yml

{% set ansible_ssh_key = pillar.get('basic_server_setup:ansible_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') %}
{% set sysadmin_ssh_key = pillar.get('basic_server_setup:sysadmin_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') %}

# Ansible user SSH configuration
# Step 1: Ensure .ssh directory exists for ansible user
ansible_ssh_dir:
  file.directory:
    - name: /home/ansible/.ssh
    - user: ansible
    - group: ansible
    - mode: '0700'
    - makedirs: True

# Step 2: Add authorized key for ansible user
ansible_ssh_key:
  ssh_auth.present:
    - user: ansible
    - name: {{ ansible_ssh_key }}
    - require:
      - file: ansible_ssh_dir

# Step 3: Ensure correct permissions on authorized_keys
ansible_authorized_keys_permissions:
  file.managed:
    - name: /home/ansible/.ssh/authorized_keys
    - user: ansible
    - group: ansible
    - mode: '0600'
    - replace: False
    - require:
      - ssh_auth: ansible_ssh_key

# Sysadmin user SSH configuration
# Step 4: Ensure .ssh directory exists for sysadmin user
sysadmin_ssh_dir:
  file.directory:
    - name: /home/sysadmin/.ssh
    - user: sysadmin
    - group: sysadmin
    - mode: '0700'
    - makedirs: True

# Step 5: Add authorized key for sysadmin user
sysadmin_ssh_key:
  ssh_auth.present:
    - user: sysadmin
    - name: {{ sysadmin_ssh_key }}
    - require:
      - file: sysadmin_ssh_dir

# Step 6: Ensure correct permissions on authorized_keys
sysadmin_authorized_keys_permissions:
  file.managed:
    - name: /home/sysadmin/.ssh/authorized_keys
    - user: sysadmin
    - group: sysadmin
    - mode: '0600'
    - replace: False
    - require:
      - ssh_auth: sysadmin_ssh_key