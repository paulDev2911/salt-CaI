{% set sysadmin_ssh_key = pillar.get('basic_server_setup:sysadmin_ssh_key', 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com') %}

sysadmin_ssh_dir:
  file.directory:
    - name: /home/sysadmin/.ssh
    - user: sysadmin
    - group: sysadmin
    - mode: '0700'
    - makedirs: True

sysadmin_ssh_key:
  ssh_auth.present:
    - user: sysadmin
    - name: {{ sysadmin_ssh_key }}
    - require:
      - file: sysadmin_ssh_dir

sysadmin_authorized_keys_permissions:
  file.managed:
    - name: /home/sysadmin/.ssh/authorized_keys
    - user: sysadmin
    - group: sysadmin
    - mode: '0600'
    - replace: False
    - require:
      - ssh_auth: sysadmin_ssh_key