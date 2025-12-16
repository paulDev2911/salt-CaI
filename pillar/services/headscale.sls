headscale:
  version: 0.27.1
  
  server_url: https://headscale.ilpaa.xyz:443
  listen_addr: 0.0.0.0:8080
  metrics_listen_addr: 127.0.0.1:9090
  grpc_listen_addr: 0.0.0.0:50443
  
  tls_hostname: headscale.ilpaa.xyz
  
  dns:
    base_domain: tailnet.ilpaa.xyz
    nameservers:
      - 1.1.1.1
      - 1.0.0.1
  
  acl_policy_path: /etc/headscale/acl.json
  
  log_level: info
  log_format: json
  
  randomize_client_port: false
  taildrop_enabled: true