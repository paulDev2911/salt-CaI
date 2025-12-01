include:
  - base_server.update_upgrade
  - base_server.install_basic_packages
  - base_server.ntp_time_sync
  - base_server.set_hostname
  - base_server.users
  - base_server.add_ssh_key
  - base_server.setup_sudo
  - base_server.setup_ssh
  - base_server.setup_nftables
  - base_server.setup_fail2ban
  - base_server.sysctl_hardening
  - base_server.service_hardening
#  - base_server.setup_auditd
  - base_server.setup_logging
  - base_server.unattended_services