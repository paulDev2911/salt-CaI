base:
  '*':
    - services.base_server
    - secrets.base_server
      
  'prod-pomerium':
    - services.pomerium
    - secrets.pomerium

  'oracle-headscale':
    - services.headscale
    - secrets.headscale

  'authentik-server':
    - services.authentik
    - secrets.authentik

  'mediaserver':
    - secrets.mullvad-media
    - secrets.slskd
  
  'hetzner-navidrome':
    - services.navidrome
    - secrets.navidrome