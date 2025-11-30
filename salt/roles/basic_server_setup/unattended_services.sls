{% set auto_reboot = pillar.get('basic_server_setup:unattended_upgrades_automatic_reboot', False) %}
{% set reboot_time = pillar.get('basic_server_setup:unattended_upgrades_automatic_reboot_time', '03:00') %}
{% set email = pillar.get('basic_server_setup:unattended_upgrades_mail', '') %}
{% set dry_run = pillar.get('basic_server_setup:unattended_upgrades_dry_run', False) %}

{% if grains['os_family'] == 'Debian' %}
install_unattended_upgrades:
  pkg.installed:
    - pkgs:
      - unattended-upgrades
      - apt-listchanges
{% endif %}

configure_50unattended_upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - contents: |
        // Managed by Salt - DO NOT EDIT MANUALLY
        Unattended-Upgrade::Allowed-Origins {
            "${distro_id}:${distro_codename}";
            "${distro_id}:${distro_codename}-security";
            "${distro_id}ESMApps:${distro_codename}-apps-security";
            "${distro_id}ESM:${distro_codename}-infra-security";
            "${distro_id}:${distro_codename}-updates";
        };
        
        Unattended-Upgrade::DevRelease "false";
        Unattended-Upgrade::AutoFixInterruptedDpkg "true";
        Unattended-Upgrade::MinimalSteps "true";
        
        {% if auto_reboot %}
        Unattended-Upgrade::Automatic-Reboot "true";
        Unattended-Upgrade::Automatic-Reboot-Time "{{ reboot_time }}";
        {% else %}
        Unattended-Upgrade::Automatic-Reboot "false";
        {% endif %}
        
        Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
        Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
        Unattended-Upgrade::Remove-Unused-Dependencies "true";
        
        {% if email %}
        Unattended-Upgrade::Mail "{{ email }}";
        Unattended-Upgrade::MailReport "on-change";
        {% else %}
        Unattended-Upgrade::Mail "";
        {% endif %}
        
        Unattended-Upgrade::SyslogEnable "true";
        Unattended-Upgrade::SyslogFacility "daemon";
        Unattended-Upgrade::Verbose "false";
        Unattended-Upgrade::Debug "false";
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_unattended_upgrades
{% endif %}

configure_20auto_upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
    - user: root
    - group: root
    - mode: '0644'
    - backup: minion
    - contents: |
        // Managed by Salt - DO NOT EDIT MANUALLY
        APT::Periodic::Update-Package-Lists "1";
        APT::Periodic::Download-Upgradeable-Packages "1";
        APT::Periodic::AutocleanInterval "7";
        APT::Periodic::Unattended-Upgrade "1";
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_unattended_upgrades
{% endif %}

unattended_upgrades_log_directory:
  file.directory:
    - name: /var/log/unattended-upgrades
    - user: root
    - group: root
    - mode: '0755'
    - makedirs: True

unattended_upgrades_service:
  service.running:
    - name: unattended-upgrades
    - enable: True
    - watch:
      - file: configure_50unattended_upgrades
      - file: configure_20auto_upgrades
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_unattended_upgrades
{% endif %}

{% if dry_run %}
unattended_upgrade_dryrun:
  cmd.run:
    - name: unattended-upgrade --dry-run --debug
    - require:
      - pkg: install_unattended_upgrades
      - service: unattended_upgrades_service
{% endif %}