{% set sysadmin_password_hash = pillar.get('base_server:sysadmin_password_hash', '$6$rounds=656000$YourHashedPasswordHere$ExampleHash') %}

sysadmin_user:
  user.present:
    - name: sysadmin
    - password: {{ sysadmin_password_hash }}
    - hash_password: False
    - groups:
      - sudo
    - shell: /bin/bash
    - home: /home/sysadmin
    - createhome: True
    - fullname: System Administrator
    - empty_password: False