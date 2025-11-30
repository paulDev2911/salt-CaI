include:
  - roles.basic_server_setup.update_upgrade
  - roles.basic_server_setup.install_basic_packages
  - roles.basic_server_setup.ntp_time_sync
  - roles.basic_server_setup.set_hostname
  - roles.basic_server_setup.users
  - roles.basic_server_setup.add_ssh_key
  - roles.basic_server_setup.setup_sudo
  - roles.basic_server_setup.setup_ssh
  - roles.basic_server_setup.setup_nftables
  - roles.basic_server_setup.setup_fail2ban
  - roles.basic_server_setup.sysctl_hardening
  - roles.basic_server_setup.service_hardening
#  - roles.basic_server_setup.setup_auditd
  - roles.basic_server_setup.setup_logging
  - roles.basic_server_setup.unattended_services