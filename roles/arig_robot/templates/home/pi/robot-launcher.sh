#!/bin/bash
# {{ ansible_managed }}

{% if arig_robot_with_screen %}
if [ ! -f robot-launcher ] ; then
  echo "Pas de programme robot-launcher"
  exit 0
fi
{% endif %}

ACTION="init"
EXTERNAL_DIR="/tmp/external-dir"
ROBOT_NAME=$(cat robot-name)

rm -Rf "${EXTERNAL_DIR}"

function send_action_to_other_robots() {
{% if arig_robot_primary %}
    ACTION=${1}
    OTHER_ROBOTS_NAME="nerell pami-triangle pami-carre pami-rond"
    for OTHER_ROBOT_NAME in ${OTHER_ROBOTS_NAME} ; do
        if [ "${OTHER_ROBOT_NAME}" != "${ROBOT_NAME}" ] ; then
            echo "Envoi de l'action ${ACTION} à ${OTHER_ROBOT_NAME}"
            ssh ${OTHER_ROBOT_NAME}.local touch ${EXTERNAL_DIR}/${ACTION}
            echo "Action ${ACTION} envoyée à ${OTHER_ROBOT_NAME}"
            echo " --- "
        fi
    done
{% else %}
    echo "Action non envoyée aux autres robots car non primaire"
{% endif %}
}

{% if arig_robot_with_can %}
echo "Start CAN network"
sudo ip link set can0 up type can bitrate 2000000
{% endif %}

while [ "${ACTION}" != "exit" ] ; do
    cd
    mkdir -p "${EXTERNAL_DIR}"
    ACTION="none"
{% if arig_robot_with_screen %}
    ./robot-launcher

    ACTION=$(cat /tmp/robot-action)
{% else %}
    {% if arig_robot_with_can %}

    cansend can0 00A#
    sleep 5

    {% endif %}

    {% if ansible_hostname == "pami-triangle" or ansible_hostname == "pami-carre" %}
    i2cset -y 1 0x55 0x4C 0x00 0x4B i
    i2cset -y 1 0x55 0x4C 0x01 0x57 i
    {% endif %}
    {% if ansible_hostname == "pami-carre" %}
    i2cset -y 1 0x55 0x4C 0x02 0x57 i
    {% endif %}
    {% if ansible_hostname == "pami-rond" %}
    i2cset -y 1 0x55 0x4C 0x00 0x57 i
    {% endif %}

    if [[ -f "${EXTERNAL_DIR}/run" ]] ; then
        ACTION="run"
    elif [[ -f "${EXTERNAL_DIR}/monitoring" ]] ; then
        ACTION="monitoring"
    elif [[ -f "${EXTERNAL_DIR}/debug" ]] ; then
        ACTION="debug"
    elif [[ -f "${EXTERNAL_DIR}/reboot" ]] ; then
        ACTION="reboot"
    elif [[ -f "${EXTERNAL_DIR}/poweroff" ]] ; then
        ACTION="poweroff"
    elif [[ -f "${EXTERNAL_DIR}/exit" ]] ; then
        ACTION="exit"
    fi

{% endif %}
    echo "Action : ${ACTION}"
    cd ${ROBOT_NAME}

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
{% if ansible_hostname == "pami-triangle" or ansible_hostname == "pami-carre" or ansible_hostname == "pami-rond" %}
        i2cset -y 1 0x55 0x4C 0x00 0x52 i
{% endif %}
        sudo reboot
    elif [ "${ACTION}" == "poweroff" ] ; then
        send_action_to_other_robots "${ACTION}"
{% if ansible_hostname == "pami-triangle" or ansible_hostname == "pami-carre" or ansible_hostname == "pami-rond" %}
        i2cset -y 1 0x55 0x4C 0x00 0x4B i
{% endif %}
        sudo poweroff
    elif [ "${ACTION}" == "exit" ] ; then
{% if ansible_hostname == "pami-triangle" or ansible_hostname == "pami-carre" or ansible_hostname == "pami-rond" %}
        i2cset -y 1 0x55 0x4C 0x00 0x42 i
{% endif %}
    fi

    rm -Rf "${EXTERNAL_DIR}"
done
