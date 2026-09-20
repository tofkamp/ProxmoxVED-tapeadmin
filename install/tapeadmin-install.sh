#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Tjibbe (tofkamp)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/tofkamp/PASTA

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

#fetch_and_deploy_gh_release "tapeadmin" "https://github.com/tofkamp/PASTA.git" "tarball"

#msg_info "Installing Dependencies"
$STD apt install -y python3-pip
$STD apt install -y git
$STD mkdir -p /opt/tapeadmin
$STD git clone https://github.com/tofkamp/PASTA.git /opt/tapeadmin
$STD chmod 700 /opt/tapeadmin
#$STD pip install -r requirements.txt --break-system-packages
#msg_ok "Installed Dependencies"

msg_info "Setting up Python Environment"
$STD pip install --break-system-packages
  proxmoxer \
  requests
msg_ok "Set up Python Environment"

msg_info "Configuring TapeAdmin"
$STD cp /opt/tapeadmin/config.example.ini /opt/tapeadmin/config.ini
msg_ok "Configured TapeAdmin"

msg_info "Creating Scheduled Tasks"
$STD cat <<'EOF' >/etc/cron.d/tapeadmin
45 7 * * *  cd /opt/tapeadmin && ./tape_admin.py run        >> run.log 2>&1
0 8   * * *   cd /opt/tapeadmin && ./tape_admin.py check-overdue >> run.log 2>&1
EOF
$STD chmod 644 /etc/cron.d/tapeadmin
msg_ok "Created Scheduled Tasks"

motd_ssh
customize
cleanup_lxc
