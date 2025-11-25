basic_server_setup:
  # User passwords (hashed)
  ansible_password_hash: "$6$rounds=656000$YourHashedPasswordHere$ExampleHash"
  sysadmin_password_hash: "$6$rounds=656000$YourHashedPasswordHere$ExampleHash"
  
  # SSH Keys
  ansible_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com"
  sysadmin_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4CmTxpnK7REOofztoVcXXRyKp6iy1N5+tPcKOOt2Zt ph24311@tutamail.com"
  
  # SSH Config
  ssh_port: 22
  
  # Firewall
  allowed_ports:
    - 22/tcp