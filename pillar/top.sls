base:
  '*':
    - roles.basic_server_setup
    - roles.setup_docker

  'pihole-*':
    - others.setup_pihole

  'prod-authentik':
    - production.prod-authentik
