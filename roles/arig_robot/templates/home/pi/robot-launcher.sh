#!/bin/bash
# {{ ansible_managed }}

ACTION="init"
EXTERNAL_DIR="/tmp/external-dir"
ROBOT_NAME=$(cat robot-name)
if [ "${ROBOT_NAME}" = "nerell" ] ; then
    OTHER_ROBOT_NAME="odin"
else
    OTHER_ROBOT_NAME="nerell"
fi

while [ "${ACTION}" != "exit" ] ; do
    cd
    mkdir -p "${EXTERNAL_DIR}"
    ./robot-launcher
    cd ${ROBOT_NAME}

    ACTION=$(cat /tmp/robot-action)
    echo "Action : ${ACTION}"

    if [ "${ACTION}" == "run" ] ; then
        ssh ${OTHER_ROBOT_NAME} touch ${EXTERNAL_DIR}/run
        ./run.sh
    elif [ "${ACTION}" == "monitoring" ] ; then
        ssh ${OTHER_ROBOT_NAME} touch ${OTHER_ROBOT_NAME}:${EXTERNAL_DIR}/monitoring
        ./monitoring.sh
    elif [ "${ACTION}" == "debug" ] ; then
        ./debug.sh
    elif [ "${ACTION}" == "reboot" ] ; then
        sudo reboot
    elif [ "${ACTION}" == "poweroff" ] ; then
        sudo poweroff
    fi

    rm -Rf "${EXTERNAL_DIR}"
done
