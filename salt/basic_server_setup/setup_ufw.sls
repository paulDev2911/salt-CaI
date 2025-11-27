# UFW Firewall Configuration
# Converted from Ansible role: roles/basic_server_setup/tasks/setup_ufw.yml

{% set ssh_port = pillar.get('basic_server_setup:ssh_port', 22) %}
{% set allowed_ports = pillar.get('basic_server_setup:allowed_ports', ['22/tcp']) %}
{% set allowed_ssh_ips = pillar.get('basic_server_setup:allowed_ssh_ips', ['any']) %}
{% set ufw_reset = pillar.get('basic_server_setup:ufw_reset', False) %}
{% set custom_service_rules = pillar.get('basic_server_setup:ufw_services', []) %}
{% set custom_advanced_rules = pillar.get('basic_server_setup:ufw_custom_rules', []) %}

# Step 1: Install UFW (Debian/Ubuntu only)
{% if grains['os_family'] == 'Debian' %}
install_ufw:
  pkg.installed:
    - name: ufw
{% endif %}

# Step 2: Reset UFW to default state (only if enabled in pillar)
{% if ufw_reset %}
reset_ufw:
  cmd.run:
    - name: echo "y" | ufw --force reset
  {% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_ufw
  {% endif %}
{% endif %}

# Step 3: Set default UFW policies
ufw_default_deny_incoming:
  cmd.run:
    - name: ufw default deny incoming
    - unless: ufw status verbose | grep -q "Default: deny (incoming)"
    {% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_ufw
    {% endif %}

ufw_default_allow_outgoing:
  cmd.run:
    - name: ufw default allow outgoing
    - unless: ufw status verbose | grep -q "Default: allow (outgoing)"
    {% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_ufw
    {% endif %}

# Step 4: Enable UFW logging
ufw_enable_logging:
  cmd.run:
    - name: ufw logging on
    - unless: ufw status verbose | grep -q "Logging: on"
{% if grains['os_family'] == 'Debian' %}
    - require:
      - pkg: install_ufw
{% endif %}

# Step 5: Allow SSH with rate limiting
{% if 'any' in allowed_ssh_ips %}
# Allow SSH from any source with rate limiting
allow_ssh_any:
  cmd.run:
    - name: ufw limit {{ ssh_port }}/tcp comment 'SSH access (rate limited)'
    - unless: ufw status | grep -q "{{ ssh_port }}/tcp.*LIMIT"
    - require:
      - cmd: ufw_default_deny_incoming
{% else %}
# Allow SSH only from specific IPs with rate limiting
{% for ip in allowed_ssh_ips %}
allow_ssh_from_{{ loop.index }}:
  cmd.run:
    - name: ufw limit from {{ ip }} to any port {{ ssh_port }} proto tcp comment 'SSH from {{ ip }}'
    - unless: ufw status | grep -q "{{ ssh_port }}/tcp.*{{ ip }}"
    - require:
      - cmd: ufw_default_deny_incoming
{% endfor %}
{% endif %}

# Step 6: Allow additional ports from pillar config
{% for port in allowed_ports %}
{% if port != ssh_port ~ '/tcp' %}
{% set port_number = port.split('/')[0] %}
{% set port_proto = port.split('/')[1] %}
allow_port_{{ loop.index }}_{{ port_number }}_{{ port_proto }}:
  cmd.run:
    - name: ufw allow {{ port_number }}/{{ port_proto }} comment 'Additional port {{ port }}'
    - unless: ufw status | grep -q "{{ port_number }}/{{ port_proto }}.*ALLOW"
    - require:
      - cmd: ufw_default_deny_incoming
{% endif %}
{% endfor %}

# Step 7: Set up custom service rules from pillar
{% for rule in custom_service_rules %}
ufw_custom_service_{{ loop.index }}:
  cmd.run:
    - name: ufw {{ rule.rule | default('allow') }} {{ rule.port }}/{{ rule.proto | default('tcp') }}{% if rule.src is defined and rule.src != 'any' %} from {{ rule.src }}{% endif %} comment '{{ rule.comment | default("Custom rule") }}'
    - unless: ufw status | grep -q "{{ rule.port }}/{{ rule.proto | default('tcp') }}"
    - require:
      - cmd: ufw_default_deny_incoming
{% endfor %}

# Step 8: Set up advanced custom rules from pillar
{% for rule in custom_advanced_rules %}
ufw_advanced_rule_{{ loop.index }}:
  cmd.run:
    - name: ufw {{ rule.rule | default('allow') }}{% if rule.from is defined %} from {{ rule.from }}{% endif %}{% if rule.to is defined %} to {{ rule.to }}{% endif %}{% if rule.port is defined %} port {{ rule.port }}{% endif %}{% if rule.proto is defined %} proto {{ rule.proto }}{% endif %}{% if rule.interface is defined %} on {{ rule.interface }}{% endif %} comment '{{ rule.comment | default("Advanced rule") }}'
    - require:
      - cmd: ufw_default_deny_incoming
{% endfor %}

# Step 9: Enable UFW
enable_ufw:
  cmd.run:
    - name: echo "y" | ufw --force enable
    - unless: ufw status | grep -q "Status: active"
    - require:
      - cmd: ufw_default_deny_incoming
      - cmd: ufw_default_allow_outgoing
{% if 'any' in allowed_ssh_ips %}
      - cmd: allow_ssh_any
{% else %}
{% for ip in allowed_ssh_ips %}
      - cmd: allow_ssh_from_{{ loop.index }}
{% endfor %}
{% endif %}

# Step 10: Ensure UFW service is enabled at boot
ufw_service:
  service.running:
    - name: ufw
    - enable: True
    - require:
      - cmd: enable_ufw

# Step 11: Get UFW status (for verification)
get_ufw_status:
  cmd.run:
    - name: ufw status verbose
    - require:
      - cmd: enable_ufw