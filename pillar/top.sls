base:
  '*':
    - services.base_server
    - secrets.base_server
      
  'prod-pomerium':
    - services.pomerium
    - secrets.pomerium