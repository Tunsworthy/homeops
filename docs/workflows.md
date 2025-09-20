List out each workflow and their purpose and the links between them.

Infrastructure_Dispatcher
    This workflow is used to pick what infrastructure action and host you want to configure.
    Hosts need to be setup in the infrastrcuture\host\hosts-config this tells the workflow what runner and environment to used based on your selection.
    
Network_Setup
    Used to configure the required VLANs on the server

Docker_Setup
    Used to configure docker with the correct settings

Docker_Network_Setup
    This configures all the networks required to get docker up an running

Certificate_Creation
    Run 
        Called from Container deployment workflow
    Inputs
        Hostname (domain will also be tomunsworth.net)
        Host(which host to put the cert onto - runner)
    Secrets
        Email
        Cloudfiare API token
    Docker Volume
        certbot:/var/www/certbot/
        certbot:/etc/letsencrypt/

docker run --rm               -v "$PWD/certbot/conf:/etc/letsencrypt"               -v "$PWD/certbot/www:/var/www/certbot"               certbot/dns-cloudflare               certonly               --dns-cloudflare           
    --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini               -d "crestron.tomunsworth.net"               --non-interactive --agree-tos --email mail@tomunsworth.net               --preferred-challenges dns-01

Container_Deployment
Containers will be deployed with the use of ansible rather than docker compose
A config file will be created to mange various aspects of the container:
    -Name
    -Image
    -Certificate (yes/no)
        -yes: Creates certificate with letsencrypt (runs workflow)
    -Externally avaliable (yes/no)
        -yes : Creates external DNS entry
    Run
        on change or creation of config file