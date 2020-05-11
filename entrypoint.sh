#!/bin/bash

# No point in doing this since we are running this as wineuser
#if [ -f /root/.Xauthority ]; then
#    cp /root/.Xauthority /home/wineuser
#    chown wineuser:wineuser /home/wineuser/.Xauthority
#fi

# start the server manager script
exec /usr/bin/server_manager "$@"
