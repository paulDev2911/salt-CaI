{% set minion_id = grains['id'] %}
{% set preauth_key = pillar.get('preauthkeys', {}).get(minion_id ~ '_pre', '') %}
{% set headscale_url = pillar.get('headscale', {}).get('server_url', 'https://headscale.ilpaa.xyz') %}

# Install prerequisites
headscale_client_prereqs:
  pkg.installed:
    - pkgs:
      - curl
      - gnupg

# Add Tailscale repo GPG key
tailscale_gpg_key:
  cmd.run:
    - name: curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    - unless: test -f /usr/share/keyrings/tailscale-archive-keyring.gpg
    - require:
      - pkg: headscale_client_prereqs

# Add Tailscale repo
tailscale_repo:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/ubuntu jammy main
    - file: /etc/apt/sources.list.d/tailscale.list
    - require:
      - cmd: tailscale_gpg_key

# Install Tailscale
tailscale_install:
  pkg.installed:
    - name: tailscale
    - require:
      - pkgrepo: tailscale_repo

# Enable tailscaled service
tailscale_service:
  service.running:
    - name: tailscaled
    - enable: True
    - require:
      - pkg: tailscale_install

{% if preauth_key %}
# Connect to Headscale with preauth key
tailscale_connect:
  cmd.run:
    - name: tailscale up --login-server={{ headscale_url }} --authkey={{ preauth_key }} --accept-routes
    - unless: tailscale status | grep -q "{{ headscale_url }}"
    - require:
      - service: tailscale_service

# Verify connection
tailscale_verify:
  cmd.run:
    - name: tailscale status
    - require:
      - cmd: tailscale_connect
{% else %}
# No preauth key found - manual connection required
tailscale_manual_warning:
  test.show_notification:
    - text: |
        WARNING: No preauth key found for minion '{{ minion_id }}'.
        Expected key: preauthkeys.{{ minion_id }}_pre
        
        Manual connection required:
        sudo tailscale up --login-server={{ headscale_url }}
    - require:
      - service: tailscale_service
{% endif %}