# Create ansible group
ansible_group:
  group.present:
    - name: ansible

# Create ansible user
ansible_user:
  user.present:
    - name: ansible
    - password: {{ pillar.get('basic_server_setup:ansible_password_hash', '$6$rounds=656000$YourHashedPasswordHere$ExampleHashForTestingPleaseReplaceWithRealHash') }}
    - groups:
      - sudo
      - ansible
    - shell: /bin/bash
    - home: /home/ansible
    - createhome: True
    - require:
      - group: ansible_group

# Create sysadmin user
sysadmin_user:
  user.present:
    - name: sysadmin
    - password: {{ pillar.get('basic_server_setup:sysadmin_password_hash', '$6$rounds=656000$YourHashedPasswordHere$ExampleHashForTestingPleaseReplaceWithRealHash') }}
    - groups:
      - sudo
    - shell: /bin/bash
    - home: /home/sysadmin
    - createhome: True

# Ensure .ssh directory for ansible
ansible_ssh_dir:
  file.directory:
    - name: /home/ansible/.ssh
    - user: ansible
    - group: ansible
    - mode: 700
    - require:
      - user: ansible_user

# Ensure .ssh directory for sysadmin
sysadmin_ssh_dir:
  file.directory:
    - name: /home/sysadmin/.ssh
    - user: sysadmin
    - group: sysadmin
    - mode: 700
    - require:
      - user: sysadmin_user

# Add SSH key for ansible
ansible_ssh_key:
  ssh_auth.present:
    - user: ansible
    - name: {{ pillar.get('basic_server_setup:ansible_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') }}
    - require:
      - file: ansible_ssh_dir

# Add SSH key for sysadmin
sysadmin_ssh_key:
  ssh_auth.present:
    - user: sysadmin
    - name: {{ pillar.get('basic_server_setup:sysadmin_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') }}
    - require:
      - file: sysadmin_ssh_dir

# Configure sudo for sudo group
sudo_config:
  file.line:
    - name: /etc/sudoers
    - mode: ensure
    - content: "%sudo ALL=(ALL:ALL) ALL"
    - match: "^%sudo"