base:
  '*':
    - services.base_server

  'pihole-*':
    - services.pihole

  'prod-authentik':
    - services.authentik