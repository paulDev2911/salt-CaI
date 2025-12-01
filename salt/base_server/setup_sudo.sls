install_sudo:
  pkg.installed:
    - name: sudo

ensure_sudo_group_exists:
  group.present:
    - name: sudo
    - system: True

configure_sudoers:
  file.managed:
    - name: /etc/sudoers
    - source: salt://base_server/files/sudoers.j2
    - user: root
    - group: root
    - mode: '0440'
    - template: jinja
    - require:
      - pkg: install_sudo
      - group: ensure_sudo_group_exists

sysadmin_user:
  user.present:
    - name: sysadmin
    - password: {{ pillar.get('base_server:sysadmin_password_hash') }}
    - hash_password: False
    - shell: /bin/bash
    - home: /home/sysadmin
    - createhome: True
    - fullname: System Administrator
    - groups:
      - sudo
    - require:
      - group: ensure_sudo_group_exists
      - file: configure_sudoers