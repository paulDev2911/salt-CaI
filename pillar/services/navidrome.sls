navidrome:
  version: "latest"
  
  # Domain/URL Configuration
  domain: navidrome.tailnet.ilpaa.xyz
  
  # Installation paths
  install_dir: /opt/navidrome
  compose_file: /opt/navidrome/docker-compose.yml
  data_dir: /opt/navidrome/data
  
  # Storage Box Mount
  storage:
    mount_point: /mnt/storagebox
    host: u123456.your-storagebox.de
    remote_path: /music
    local_path: /mnt/storagebox/music
  
  # Navidrome Configuration
  music_folder: /music
  port: 4533
  
  # Caddy Configuration
  caddy:
    enabled: true
    internal_url: "http://localhost:4533"