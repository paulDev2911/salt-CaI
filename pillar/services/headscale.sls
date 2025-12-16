base_server:
  hostname: headscale-server
  ssh_port: 22
  ssh_allow_users:
    - ubuntu
    - sysadmin
  
  allowed_ports:
    - 22/tcp
    - 80/tcp
    - 443/tcp
    - 3478/udp
  
  allow_reboot: false
  unattended_upgrades_automatic_reboot: false
  
  log_format: json