base:
  '*':
    - base_server
  
  'prod-authentik':
    - docker
    - authentik

  'oracle-*':
    - docker
    - nextcloud
  
  'prod-pomerium':
    - docker
    - pomerium

  'oracle-headscale':
    - base_server
    - headscale