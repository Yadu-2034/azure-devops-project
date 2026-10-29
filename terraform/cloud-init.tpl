#cloud-config
# Runs once on first boot of the VM: installs Python + nginx and prepares a systemd
# service. Jenkins later copies the application code and restarts the service.
package_update: true
packages:
  - python3-pip
  - python3-venv
  - nginx
  - rsync

write_files:
  - path: /etc/systemd/system/flaskapp.service
    permissions: "0644"
    content: |
      [Unit]
      Description=Flask web app (gunicorn)
      After=network.target

      [Service]
      User=${admin_username}
      WorkingDirectory=/opt/webapp
      ExecStart=/opt/webapp/venv/bin/gunicorn --workers 2 --bind 127.0.0.1:5000 app:app
      Restart=always
      RestartSec=3

      [Install]
      WantedBy=multi-user.target

  - path: /etc/nginx/conf.d/flaskapp.conf
    permissions: "0644"
    content: |
      server {
          listen 80 default_server;
          server_name _;

          location / {
              proxy_pass http://127.0.0.1:5000;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          }
      }

runcmd:
  - mkdir -p /opt/webapp
  - chown -R ${admin_username}:${admin_username} /opt/webapp
  - rm -f /etc/nginx/sites-enabled/default
  - systemctl daemon-reload
  - systemctl enable flaskapp
  - nginx -t && systemctl restart nginx
