base:
  '*':
    - services.base_server
    - secrets.shared

  'prod-authentik':
    - services.authentik
    - secrets.homelab

  'oracle-*':
    - secrets.oraclevirt