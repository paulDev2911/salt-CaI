base:
  '*':
    - services.base_server
    - secrets.base_server
      
  'prod-pomerium':
    - services.pomerium
    - secrets.pomerium
    - secrets.headscale-preauthkeys

  'oracle-headscale':
    - services.headscale
    - secrets.headscale

  'authentik-server':
    - services.authentik
    - secrets.authentik
    - secrets.headscale-preauthkeys

  'mediaserver':
    - secrets.mullvad-media
    - secrets.slskd
  
  'hetzner-navidrome':
    - services.navidrome
    - secrets.navidrome
    - secrets.headscale-preauthkeys