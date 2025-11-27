# Sudo Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/setup_sudo.yml

# Step 1: Ensure sudo package is installed
install_sudo:
  pkg.installed:
    - name: sudo

# Step 2: Configure sudo group with password requirement
configure_sudo_group:
  file.replace:
    - name: /etc/sudoers
    - pattern: '^%sudo\s+ALL=.*'
    - repl: '%sudo ALL=(ALL:ALL) ALL'
    - append_if_not_found: True
    - require:
      - pkg: install_sudo

# Step 3: Validate sudoers file after modification
validate_sudoers:
  cmd.run:
    - name: visudo -cf /etc/sudoers
    - onchanges:
      - file: configure_sudo_group

# Step 4: Ensure ansible user is in sudo group
ansible_user_sudo_group:
  user.present:
    - name: ansible
    - groups:
      - sudo
    - remove_groups: False
    - require:
      - file: configure_sudo_group

# Step 5: Ensure admin user is in sudo group
sysadmin_user_sudo_group:
  user.present:
    - name: sysadmin
    - groups:
      - sudo
    - remove_groups: False
    - require:
      - file: configure_sudo_group

# Step 6: Final validation of sudo configuration
final_validate_sudoers:
  cmd.run:
    - name: visudo -c
    - require:
      - file: configure_sudo_group
      - user: ansible_user_sudo_group
      - user: sysadmin_user_sudo_group