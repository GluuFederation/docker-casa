#!/bin/sh
set -e

# =========
# FUNCTIONS
# =========

move_builtin_jars() {
    # move twilio lib
    if [ ! -f /opt/gluu/jetty/oxauth/custom/libs/twilio.jar ]; then
        mkdir -p /opt/gluu/jetty/oxauth/custom/libs
        mv /usr/share/java/twilio.jar /opt/gluu/jetty/oxauth/custom/libs/twilio.jar
    fi

    # move jsmpp lib
    if [ ! -f /opt/gluu/jetty/oxauth/custom/libs/jsmpp.jar ]; then
        mkdir -p /opt/gluu/jetty/oxauth/custom/libs
        mv /usr/share/java/jsmpp.jar /opt/gluu/jetty/oxauth/custom/libs/jsmpp.jar
    fi

}

# ==========
# ENTRYPOINT
# ==========

move_builtin_jars
python3 /app/scripts/wait.py

if [ ! -f /deploy/touched ]; then
    python3 /app/scripts/entrypoint.py
    touch /deploy/touched
fi

python3 /app/scripts/jca_sync.py &

# run Casa server
cd /opt/gluu/jetty/casa
exec java \
    -server \
    -XX:+DisableExplicitGC \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=$GLUU_MAX_RAM_PERCENTAGE \
    -Dgluu.base=/etc/gluu \
    -Dserver.base=/opt/gluu/jetty/casa \
    -Dlog.base=/opt/gluu/jetty/casa \
    -Dpython.home=/opt/jython \
    ${GLUU_JAVA_OPTIONS} \
    -jar /opt/jetty/start.jar
