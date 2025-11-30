install_sudo:
  pkg.installed:
    - name: sudo

configure_sudo_group:
  file.replace:
    - name: /etc/sudoers
    - pattern: '^%sudo\s+ALL=.*'
    - repl: '%sudo ALL=(ALL:ALL) ALL'
    - append_if_not_found: True
    - require:
      - pkg: install_sudo

validate_sudoers:
  cmd.run:
    - name: visudo -cf /etc/sudoers
    - onchanges:
      - file: configure_sudo_group

ansible_user_sudo_group:
  user.present:
    - name: ansible
    - groups:
      - sudo
    - remove_groups: False
    - require:
      - file: configure_sudo_group

sysadmin_user_sudo_group:
  user.present:
    - name: sysadmin
    - groups:
      - sudo
    - remove_groups: False
    - require:
      - file: configure_sudo_group

final_validate_sudoers:
  cmd.run:
    - name: visudo -c
    - require:
      - file: configure_sudo_group
      - user: ansible_user_sudo_group
      - user: sysadmin_user_sudo_group