{% if grains['os_family'] == 'Debian' %}
update_and_upgrade_system:
  pkg.uptodate:
    - refresh: True
    - dist_upgrade: True
    - retry:
        attempts: 3
        interval: 10

cleanup_packages:
  cmd.run:
    - name: apt-get autoclean -y && apt-get autoremove -y
    - onchanges:
      - pkg: update_and_upgrade_system

{% if pillar.get('base_server:allow_reboot', False) %}
reboot_if_required:
  system.reboot:
    - onlyif: test -f /var/run/reboot-required
    - at_time: +1
    - require:
      - pkg: update_and_upgrade_system
{% else %}
notify_reboot_needed:
  test.show_notification:
    - text: "Reboot required but auto-reboot disabled. Run: sudo reboot"
    - onlyif: test -f /var/run/reboot-required
{% endif %}
{% endif %}