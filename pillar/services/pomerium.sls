pomerium:

  allowed_ports:
    - 443/tcp
    
  project_dir: /opt/pomerium_quickstart
  config_file: /opt/pomerium_quickstart/config.yaml
  compose_file: /opt/pomerium_quickstart/docker-compose.yaml
  
  authenticate_url: https://authenticate.pomerium.app
  verify_domain: verify.localhost.pomerium.io
  
  pomerium_image: pomerium/pomerium:latest
  verify_image: pomerium/verify:latest
  
  https_port: 443
  verify_port: 8000