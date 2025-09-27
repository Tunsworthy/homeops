List out each workflow and their purpose and the links between them.

Infrastructure_Dispatcher
    This workflow is used to pick what infrastructure action and host you want to configure.
    Hosts need to be setup in the infrastrcuture\host\hosts-config this tells the workflow what runner and environment to used based on your selection.

Host_Update
    This workflow uses the host-config to go update the OS on each runner using the os/upgrade runbook.

Network_Setup - Done
    Scope: Host
    Used to configure the required VLANs on the host

Docker_Setup - Done
    Scope: Host
    Used to configure docker with the correct settings

Docker_Network_Setup - Done
    Scope: Host
    This configures all the networks required to get docker up an running

Certificate_Creation - Done
    Scope: Containers
    This workflow will create a volume where all certiciates for containers running on that host can be sroted.
    Run 
        Called from Container deployment workflow
    Inputs
        Hostname (domain will also be tomunsworth.net)
        Host(which host to put the cert onto - runner)
    Secrets
        Email
        Cloudfiare API token
    Docker Volume
        certbot:/etc/letsencrypt/

CloudFlare Tunnel 
    I workflow that will add a container to the cloudflare tunnel confguation 

Container_Deployment
Containers will be deployed with the use of ansible rather than docker compose

A config file will be created to mange various aspects of the container:
    -Name
    -Image?
    -Certificate (true/false)
        -yes: Creates certificate with letsencrypt (runs workflow)
    -Externally avaliable (true/false)
        -yes : Creates external DNS entry
    -External IP (true/false)
        
    Run
        on change or creation of config file