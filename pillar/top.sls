base:
  '*':
    - services.base_server
  
  'pihole-*':
    - services.pihole
  
  'prod-authentik':
    - services.authentik
    - secrets.homelab
  
  'prod-pomerium':
    - services.pomerium
    - secrets.pomerium