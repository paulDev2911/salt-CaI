include:
  - docker

nextcloud_directory:
  file.directory:
    - name: /opt/nextcloud
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

nextcloud_compose:
  file.managed:
    - name: /opt/nextcloud/docker-compose.yml
    - source: salt://nextcloud/files/docker-compose.yml.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: nextcloud_directory

nextcloud_start:
  cmd.run:
    - name: docker-compose up -d
    - cwd: /opt/nextcloud
    - require:
      - file: nextcloud_compose