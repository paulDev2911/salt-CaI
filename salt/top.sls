base:
  '*':
    - base_server
  
  'prod-pomerium':
    - docker
    - pomerium

  'oracle-headscale':
    - base_server
    - headscale
  
  'mediaserver':
    - media-stack