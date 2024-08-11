#!/bin/bash

set -eo pipefail

allowed_tags="\
install,\
destroy,\
configure_user"

tag="${1}"
shift

function usage() {
    echo "Usage: $0 <tag> [OPTIONS]"
    echo ""
    echo "Available Tags:"
    echo "  install          Create infrastructure and configure OpenVPN"
    echo "  destroy          Destroy infrastructure"
    echo "  configure_user   Configure OpenVPN user"
    echo ""
    echo "Required Options for Each Tag:"
    echo "  install:"
    echo "    --token <hcloud_token>        Hetzner Cloud API token"
    echo "    --client_name <client_name>   Client name for OpenVPN"
    echo "    --ovpn_passphrase <ovpn_passphrase>  Passphrase for OpenVPN"
    echo ""
    echo "  destroy:"
    echo "    --token <hcloud_token>        Hetzner Cloud API token"
    echo ""
    echo "  configure_user:"
    echo "    --client_name <client_name>   Client name for OpenVPN"
    echo "    --ovpn_passphrase <ovpn_passphrase>  Passphrase for OpenVPN"
    exit 1
}

HCLOUD_TOKEN=""
CLIENT_NAME=""
OVPN_PASSPHRASE=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --token) HCLOUD_TOKEN="$2"; shift 2 ;;
        --client_name) CLIENT_NAME="$2"; shift 2 ;;
        --ovpn_passphrase) OVPN_PASSPHRASE="$2"; shift 2 ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
done

function manage_infrastructure() {
    local action=("$1")
    if [ -z "$HCLOUD_TOKEN" ]; then
        echo "Error: --token parameter is required for install tag"
        usage
    fi

    export TF_VAR_hcloud_token=$HCLOUD_TOKEN
    terraform ${action}
}

function run_ansible_task() {
    local ansible_host=("$1")
    if [ -z "$CLIENT_NAME" ] || [ -z "$OVPN_PASSPHRASE" ]; then
        echo "Error: --client_name and --ovpn_passphrase parameters are required for configuring OpenVPN"
        usage
    fi

    export ANSIBLE_HOST_KEY_CHECKING=False
    export ANSIBLE_PRIVATE_KEY_FILE=./id_ed25519
    ansible-playbook -i inventory install.yml --tags ${tag} --extra-vars "client_name=$CLIENT_NAME ovpn_passphrase=$OVPN_PASSPHRASE ansible_ssh_host=$ansible_host"
}

if [[ "${tag}" == "install" ]]; then
    cd ./terraform
    echo "Initialized terraform"
    manage_infrastructure "init"
    echo "Creating infrastructure"
    manage_infrastructure "apply -auto-approve"
    public_address=$(terraform output -json ovpn_hosts | jq -r '.control_plane.public_address')
    terraform output -raw ovpn_host_ssh_private_key > ../id_ed25519 && chmod 400 ../id_ed25519
    echo "Sleep 30 seconds for server properly created"
    sleep 30
    cd ../
    echo "Run ansible for configure ovpn server"
    run_ansible_task "${public_address}"

elif [[ "${tag}" == "destroy" ]]; then
    echo "Destroying infrastructure"
    cd ./terraform
    manage_infrastructure "destroy -auto-approve"
    rm -f ../id_ed25519

elif [[ "${tag}" == "configure_user" ]]; then
    echo "Add Ovpn user"
    cd ./terraform
    public_address=$(terraform output -json ovpn_hosts | jq -r '.control_plane.public_address')
    cd ../
    run_ansible_task "${public_address}"

else
    usage
fi
