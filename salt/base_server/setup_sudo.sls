install_sudo:
  pkg.installed:
    - name: sudo

ensure_sudo_group_exists:
  group.present:
    - name: sudo
    - system: True

configure_sudo_group:
  file.line:
    - name: /etc/sudoers
    - content: '%sudo ALL=(ALL:ALL) ALL'
    - mode: ensure
    - after: '^root.*ALL'
    - require:
      - pkg: install_sudo
      - group: ensure_sudo_group_exists

sysadmin_user:
  user.present:
    - name: sysadmin
    - shell: /bin/bash
    - home: /home/sysadmin
    - createhome: True
    - password: {{ pillar.get('sysadmin:password_hash') }}
    - groups:
      - sudo
    - require:
      - group: ensure_sudo_group_exists
      - file: configure_sudo_group