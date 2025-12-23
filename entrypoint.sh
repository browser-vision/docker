#!/bin/bash

# Wait for network to be ready
sleep 2

# Explicitly set environment variables
export USER=sandbox
export HOME=/home/sandbox
export DISPLAY=:1
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Start dbus daemon
mkdir -p /tmp/.X11-unix
if [ ! -e /var/run/dbus/pid ]; then
    sudo mkdir -p /var/run/dbus
    dbus-daemon --system --fork
fi
dbus-launch --sh-syntax > /tmp/dbus.env || true
if [ -f /tmp/dbus.env ]; then
    source /tmp/dbus.env
    echo "D-Bus session started with address: $DBUS_SESSION_BUS_ADDRESS"
fi

# Ensure icon cache is updated
mkdir -p ~/.icons ~/.themes
update-icon-caches ~/.icons || true
xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita" || true

# Create proper xstartup file for Xfce4
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << EOF
#!/bin/bash
xrdb $HOME/.Xresources
# Fix font path issue
xset fp default

# Initialize icon theme
export XDG_DATA_DIRS=/usr/share
xfce4-session &
EOF

chmod +x ~/.vnc/xstartup

# Set VNC password
echo "password" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

# Kill any existing VNC sessions
vncserver -kill :1 2>/dev/null || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Start VNC server with proper configuration
vncserver :1 -geometry 1280x800 -depth 24 -rfbport 5901

# Print debug information
echo "VNC server started"
echo "DISPLAY=$DISPLAY"

# Start noVNC using websockify
websockify --web /usr/share/novnc/ 0.0.0.0:6080 localhost:5901 &
echo "http://localhost:6080"

# Start the application
Vision &

# Keep the container running and show logs for debugging
tail -f ~/.vnc/*log
