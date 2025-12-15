base:
  '*':
    - services.base_server
    - secrets.base_server
  
  'pihole-*':
    - services.pihole
  
  'prod-authentik':
    - services.authentik
  
  'prod-pomerium':
    - services.pomerium
    - secrets.pomerium