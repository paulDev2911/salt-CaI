{% set nv = pillar.get('navidrome', {}) %}
{% set nv_secrets = pillar.get('navidrome', {}) %}
{% set storage = nv.get('storage', {}) %}

# Install CIFS utilities
cifs_utils_install:
  pkg.installed:
    - name: cifs-utils

# Create mount point
storage_mount_point:
  file.directory:
    - name: {{ storage.mount_point }}
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True

# Create credentials file for CIFS
storage_credentials_file:
  file.managed:
    - name: /root/.storage-credentials
    - user: root
    - group: root
    - mode: '0600'
    - contents: |
        username={{ nv_secrets.storage_username }}
        password={{ nv_secrets.storage_password }}
    - require:
      - pkg: cifs_utils_install

# Add to /etc/fstab
storage_fstab_entry:
  mount.mounted:
    - name: {{ storage.mount_point }}
    - device: //{{ storage.host }}{{ storage.remote_path }}
    - fstype: cifs
    - opts: credentials=/root/.storage-credentials,uid=1000,gid=1000,iocharset=utf8,file_mode=0644,dir_mode=0755
    - dump: 0
    - pass_num: 0
    - persist: True
    - mkmnt: True
    - require:
      - file: storage_credentials_file
      - file: storage_mount_point

# Verify mount
verify_storage_mount:
  cmd.run:
    - name: mount | grep {{ storage.mount_point }}
    - require:
      - mount: storage_fstab_entry