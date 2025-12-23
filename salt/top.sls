base:
  '*':
    - base_server
  
  'prod-pomerium':
    - docker
    - headscale-client
    - pomerium

  'oracle-headscale':
    - base_server
    - headscale
  
  'mediaserver':
    - media-stack
  
  'hetzner-navidrome':
  - headscale-client
  - navidrome