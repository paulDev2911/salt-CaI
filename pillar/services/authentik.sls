authentik:
  version: "2024.12.1"
  
  # Domain/URL Configuration
  domain: authentik.tailnet.ilpaa.xyz
  
  # Installation paths
  install_dir: /opt/authentik
  compose_file: /opt/authentik/docker-compose.yml
  env_file: /opt/authentik/.env
  
  # Database Configuration
  postgres:
    db_name: authentik
    user: authentik
    
  # Redis Configuration  
  redis:
    cache_db: 0
    
  # Ports (internal - Caddy proxies to these)
  ports:
    http: 9000
    https: 9443
    
  # Worker Configuration
  workers: 2
  
  # Email Configuration (non-secret parts)
  email:
    from: "authentik@ilpaa.xyz"
    host: smtp.eu.mailgun.org
    port: 587
    use_tls: true
    use_ssl: false
    timeout: 10
    
  # Allowed hosts
  allowed_hosts:
    - authentik.tailnet.ilpaa.xyz
    
  # Caddy Configuration
  caddy:
    enabled: true
    internal_url: "http://localhost:9000"