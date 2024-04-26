#!/bin/bash
# {{ ansible_managed }}

if [ ! -f robot-launcher ] ; then
  echo "Pas de programme robot-launcher"
  exit 0
fi

ACTION="init"
EXTERNAL_DIR="/tmp/external-dir"
ROBOT_NAME=$(cat robot-name)
OTHER_ROBOTS_NAME="nerell odin pami-triangle pami-carre pami-rond"

function send_action_to_other_robots() {
    ACTION=${1}
    for OTHER_ROBOT_NAME in ${OTHER_ROBOTS_NAME} ; do
        if [ "${OTHER_ROBOT_NAME}" != "${ROBOT_NAME}" ] ; then
            ssh ${OTHER_ROBOT_NAME} touch ${EXTERNAL_DIR}/${ACTION}
        fi
    done
}

while [ "${ACTION}" != "exit" ] ; do
    cd
    mkdir -p "${EXTERNAL_DIR}"
    ./robot-launcher
    cd ${ROBOT_NAME}

    ACTION=$(cat /tmp/robot-action)
    echo "Action : ${ACTION}"

    if [ "${ACTION}" == "run" ] ; then
        send_action_to_other_robots "${ACTION}"
        ./run.sh
    elif [ "${ACTION}" == "monitoring" ] ; then
        send_action_to_other_robots "${ACTION}"
        ./monitoring.sh
    elif [ "${ACTION}" == "debug" ] ; then
        send_action_to_other_robots "${ACTION}"
        ./debug.sh
    elif [ "${ACTION}" == "reboot" ] ; then
        send_action_to_other_robots "${ACTION}"
        sudo reboot
    elif [ "${ACTION}" == "poweroff" ] ; then
        send_action_to_other_robots "${ACTION}"
        sudo poweroff
    fi

    rm -Rf "${EXTERNAL_DIR}"
done
