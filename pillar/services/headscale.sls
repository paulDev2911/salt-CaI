# Base Server Configuration for Headscale VM
base_server:
  hostname: headscale-server
  ssh_port: 22
  ssh_allow_users:
    - ubuntu
    - sysadmin
  
  allowed_ports:
    - 22/tcp
    - 80/tcp    # Let's Encrypt
    - 443/tcp   # Headscale HTTPS
    - 3478/udp  # STUN
  
  allow_reboot: false
  unattended_upgrades_automatic_reboot: false
  log_format: json

# Headscale Service Configuration
headscale:
  version: 0.27.1
  
  server_url: https://headscale.example.com:443
  listen_addr: 0.0.0.0:8080
  metrics_listen_addr: 127.0.0.1:9090
  grpc_listen_addr: 0.0.0.0:50443
  
  acme_email: your-email@example.com
  tls_hostname: headscale.example.com
  
  dns:
    base_domain: tailnet.example.com
    nameservers:
      - 1.1.1.1
      - 1.0.0.1
    extra_records:
      - name: nextcloud.tailnet.example.com
        type: A
        value: 100.64.0.10
      - name: authentik.tailnet.example.com
        type: A
        value: 100.64.0.11
      - name: pomerium.tailnet.example.com
        type: A
        value: 100.64.0.12
  
  acl_policy_path: /etc/headscale/acl.json
  
  log_level: info
  log_format: json
  
  oidc:
    only_start_if_available: true
    issuer: https://authentik.example.com/application/o/headscale/
    client_id: headscale
    client_secret_path: /etc/headscale/oidc_secret
    expiry: 180d
    scope:
      - openid
      - profile
      - email
    allowed_domains:
      - example.com
  
  randomize_client_port: false
  taildrop_enabled: true
