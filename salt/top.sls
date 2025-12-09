base:
  '*':
    - base_server
  
  'prod-authentik':
    - docker
    - authentik

  'oracle-*':
    - docker
    - nextcloud