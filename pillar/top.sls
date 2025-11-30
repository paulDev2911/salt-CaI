base:
  '*':
    - roles.basic_server_setup

  'pihole-*':
    - others.setup_pihole

  'prod-authentik':
    - production.prod-authentik
