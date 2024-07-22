# Fast HCloud OVPN

A quick way to deploy a VPN server if you have a Hetzner Cloud account.

## Prerequisites

Make sure you have the following prerequisites (tested on the latest versions of the components):

1. Hetzner Cloud account and generated API token for it
2. Bash shell on the machine you are deploying from
3. Terraform installed
4. Ansible installed

## Deploy a VPN server

1. Clone this git repository:
    ```sh
    git clone https://github.com/valdisd96/fast-hcloud-ovpn.git
    ```
2. Go to the repository directory and run the wrapper script `fast-ovpn.sh` with the `install` tag:
    ```sh
    ./fast-ovpn.sh install --client_name "<client_name>" --ovpn_passphrase "<ovpn_passphrase>" --token "<hcloud_token>"
    ```
    After deployment, you will see a new directory `ovpn-client-configs` which will contain the client configuration. The OpenSSH key `id_rsa` will also be generated and can be found in the root directory of the repository.

## Configure additional users

The wrapper script also has an additional tag for creating users on an already configured VPN server. Run the script with the following options:
    ```sh
    ./fast-ovpn.sh configure_user --client_name "<client_name>" --ovpn_passphrase "<ovpn_passphrase>"
    ```

## Destroy VPN server and infrastructure

To remove the VPN server and infrastructure, run the script:
    ```sh
    ./fast-ovpn.sh destroy --token "<hcloud_token>"
    ```

## Help

Use `./fast-ovpn.sh --help` for more detailed options description.

## Basis

The basis of this project is the [OpenVPN server](https://github.com/kylemanna/docker-openvpn), which is deployed in Docker.
Over time, I plan to add more options for more flexible installation.
