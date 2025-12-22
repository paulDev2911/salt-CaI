# Install Headscale (Tailscale-compatible) Client

headscale_client_prereqs:
  pkg.installed:
    - pkgs:
      - curl
      - gnupg

tailscale_gpg_key:
  cmd.run:
    - name: curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    - unless: test -f /usr/share/keyrings/tailscale-archive-keyring.gpg
    - require:
      - pkg: headscale_client_prereqs

tailscale_repo:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/ubuntu jammy main
    - file: /etc/apt/sources.list.d/tailscale.list
    - require:
      - cmd: tailscale_gpg_key

tailscale_install:
  pkg.installed:
    - name: tailscale
    - require:
      - pkgrepo: tailscale_repo

tailscale_service:
  service.running:
    - name: tailscaled
    - enable: True
    - require:
      - pkg: tailscale_install

# Manual step: Connect to Headscale
tailscale_connect_info:
  test.show_notification:
    - text: |
        Tailscale installed. Connect to Headscale manually:
        sudo tailscale up --login-server=https://headscale.ilpaa.xyz
    - require:
      - service: tailscale_service