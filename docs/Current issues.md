Current issues
*Containers are out of date and upgrading many versions is difficult
*No automations for deployment of inf-services, keeping things update is not efficient
*no back-up of configration, this means high risk if/when changes happen - eg. OS updates are not applied because who knows if my Pi will come back online
*Undocumenated "Complex" network
*Devices in IoT VLAN have internet access, this was never meant to happen but got added overtime
*Containers currently sit in the IoT VLAN, these should be seperated out


Design principles
*Only things that need internet access should get it
*Only containers that need their Own IP should get it - eg. DNS, NTP,NGINX
*All webservices that cannot load their own certificates should be behind NGINX
*seperation where possbile
*SSL all the things
*Access provided from Internet by CloudFlare
*Automation
*Infrastructure as code
*Stop using latest

Goals
*Document home setup
    *Configuration
    *Architecture
    *Tool Chain
    *Simplfily
    *Move to Infrastructure as code
    *Standardise
*Automation of deployments
    -To allow for quick rebuilds
    -Deploy to test envioment before production
    -Flexability
*Automate updates
    *OS patching
    *Firmware (Router)
    *Containers (with testing)
*New things
    *Configration Storage (config files for tooling)
    *Backups
    *Investigate moving to Kuberneties (future need to look into hardware)


*Project Breakdown
-Design Phase
    -Document Network
    -Select Tooling
-Preperation
    -setup network with required VLANs
    -Setup Pi3

Diagrams
    -Physical Network
    -Logical network
    -Docker network


Tooling
-Terraform (future) - Will be used to configure Mikrotik and Ubuntu
-Ansible - Used to keep systems upto date and deploy containers
-Github
-Github Actions


Pi 4 10.2.2.10
pi 3 10.2.0.12


VLAN20-10.2.0.0-HomeWiFi
    DHCP Pool - 10.2.0.10-10.2.0.100
VLAN21-10.2.1.0-GuestWiFi
    DHCP Pool - 10.2.1.10-10.2.1.30
VLAN22-10.2.2.0-UniFiMan
VLAN23-10.2.3.0-IoTFi
    DHCP Pool - 10.2.3.30-10.2.3.100
VLAN24-10.2.4.0-Hostmanagement
VLAN25-10.2.5.0-Containers
VLAN26-10.2.6.0-Pi3-Containers

vlan100 - Used for ISP connection

WirelessVLANBridge
    Eth5 - WiFi
    Eth4 - Pi3
    Eth1 - Pi4

Tagged Vlans 20,21,23 - Eth1, Eth4, Eth5
Tagged Vlan 22,25,24,26 Eth4 - Eth1