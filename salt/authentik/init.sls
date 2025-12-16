authentik_dir:
  file.managed:
    - name: /opt/authentik
    - user: root
    - group: root
    - mode: 644

authentik_gen_pw:
    run.cmd:
      - name: echo "PG_PASS=$(openssl rand -base64 36 | tr -d '\n')" >> .env