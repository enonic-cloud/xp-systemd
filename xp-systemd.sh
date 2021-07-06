#!/usr/bin/env sh

XP_VERSION=${XP_VERSION:-"7.7.1"}
XP_USER=${XP_USER:-"xp"}
XP_GROUP=${XP_GROUP:-"xp"}
XP_DIR_DISTROS=${XP_DIR_DISTROS:-"/opt/enonic/distros"}
XP_DIR_HOME=${XP_DIR_HOME:-"/opt/enonic/home"}
XP_SERVICE=${XP_SERVICE:-"xp.service"}
XP_SERVICE_FILE=${XP_SERVICE_FILE:-"/etc/systemd/system/${XP_SERVICE}"}
XP_OPTS=${XP_OPTS:-"-Xms1G -Xmx1G"}

set -e

cat << EOF
Enonic XP systemd installation script!

XP_VERSION      ${XP_VERSION}
XP_USER         ${XP_USER}
XP_GROUP        ${XP_GROUP}
XP_DIR_DISTROS  ${XP_DIR_DISTROS}
XP_DIR_HOME     ${XP_DIR_HOME}
XP_SERVICE_FILE ${XP_SERVICE_FILE}
XP_OPTS         ${XP_OPTS}
EOF

echo " "

echo "Set vm.max_map_count ..."
echo "vm.max_map_count=262144" > "/etc/sysctl.d/99-xp.conf"
sysctl --system > /dev/null


echo "Create xp user/group if needed ... "
id -u ${XP_USER} > /dev/null 2>&1 || (groupadd -f ${XP_GROUP}; useradd --gid ${XP_USER} --system ${XP_USER})

echo "Create xp directories if needed ..."
[ -d "${XP_DIR_DISTROS}" ] || install -d -m 0755 -o ${XP_USER} -g ${XP_GROUP} ${XP_DIR_DISTROS}
[ -d "${XP_DIR_HOME}" ] || install -d -m 0755 -o ${XP_USER} -g ${XP_GROUP} ${XP_DIR_HOME}

echo "Download xp distro if needed ..."
[ -d "${XP_DIR_DISTROS}/enonic-xp-linux-server-${XP_VERSION}" ] || su -m ${XP_USER} -c "wget -q -c https://repo.enonic.com/public/com/enonic/xp/enonic-xp-linux-server/${XP_VERSION}/enonic-xp-linux-server-${XP_VERSION}.tgz -O - | tar -xz -C ${XP_DIR_DISTROS}"

echo "Setup xp home directory if needed ..."
[ "$(ls -A ${XP_DIR_HOME})" ] || cp -rp ${XP_DIR_DISTROS}/enonic-xp-linux-server-${XP_VERSION}/home/* ${XP_DIR_HOME}

echo "Create systemd service file ..."
cat << EOF > ${XP_SERVICE_FILE}
[Unit]
Description=Enonic XP
Documentation=https://developer.enonic.com/docs
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
PrivateTmp=true
Environment=XP_INSTALL=${XP_DIR_DISTROS}/enonic-xp-linux-server-${XP_VERSION}
Environment=XP_JAVA_HOME=${XP_DIR_DISTROS}/enonic-xp-linux-server-${XP_VERSION}/jdk
Environment=XP_HOME=${XP_DIR_HOME}
Environment=XP_OPTS=${XP_OPTS}

User=${XP_USER}
Group=${XP_GROUP}

ExecStart=${XP_DIR_DISTROS}/enonic-xp-linux-server-${XP_VERSION}/bin/server.sh

StandardOutput=journal
StandardError=inherit

LimitNOFILE=65536
LimitNPROC=4096
LimitAS=infinity
LimitFSIZE=infinity

KillSignal=SIGTERM
KillMode=process
SendSIGKILL=no
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF

echo " "

cat << EOF
Installation completed!

Reload systemd daemon with:       systemctl daemon-reload
Enable and start XP service with: systemctl enable --now ${XP_SERVICE}
View XP logs with:                journalctl -u ${XP_SERVICE}
EOF