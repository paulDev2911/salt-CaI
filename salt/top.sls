base:
  '*':
    - base_server
    
  'pihole-*':
    - docker
    - pihole

  'prod-authentik':
    - docker
    - authentik