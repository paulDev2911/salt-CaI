include:
  - roles.basic_server_setup
  - roles.setup_docker

{% set pihole_config = salt['pillar.get']('pihole', {}) %}
{% set timezone = pihole_config.get('timezone', 'Europe/Berlin') %}
{% set webpassword = pihole_config.get('webpassword', '') %}
{% set dns1 = pihole_config.get('dns1', '1.1.1.1') %}
{% set dns2 = pihole_config.get('dns2', '1.0.0.1') %}
{% set interface = pihole_config.get('interface', 'eth0') %}

/opt/pihole:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/opt/pihole/etc-pihole:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /opt/pihole

/opt/pihole/etc-dnsmasq.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /opt/pihole

/opt/pihole/docker-compose.yml:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        version: "3"

        services:
          pihole:
            container_name: pihole
            image: pihole/pihole:latest
            ports:
              - "53:53/tcp"
              - "53:53/udp"
              - "80:80/tcp"
            environment:
              TZ: '{{ timezone }}'
              WEBPASSWORD: '{{ webpassword }}'
              FTLCONF_LOCAL_IPV4: '{{ salt['network.interface_ip'](interface) }}'
              PIHOLE_DNS_: '{{ dns1 }};{{ dns2 }}'
              DNSMASQ_LISTENING: 'all'
            volumes:
              - './etc-pihole:/etc/pihole'
              - './etc-dnsmasq.d:/etc/dnsmasq.d'
            cap_add:
              - NET_ADMIN
            restart: unless-stopped
            logging:
              driver: "json-file"
              options:
                max-size: "10m"
                max-file: "3"
    - require:
      - file: /opt/pihole/etc-pihole
      - file: /opt/pihole/etc-dnsmasq.d

/etc/systemd/system/pihole.service:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        [Unit]
        Description=Pi-hole Docker Container
        Requires=docker.service
        After=docker.service network-online.target
        Wants=network-online.target

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        WorkingDirectory=/opt/pihole
        ExecStart=/usr/bin/docker compose up -d
        ExecStop=/usr/bin/docker compose down
        TimeoutStartSec=0

        [Install]
        WantedBy=multi-user.target
    - require:
      - file: /opt/pihole/docker-compose.yml

pihole-service:
  service.running:
    - name: pihole
    - enable: True
    - require:
      - file: /etc/systemd/system/pihole.service
    - watch:
      - file: /opt/pihole/docker-compose.yml
{% endif %}