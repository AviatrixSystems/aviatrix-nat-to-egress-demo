#! /bin/bash
sudo hostnamectl set-hostname ${name}
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Add workload user
sudo adduser workload
sudo echo "workload:${password}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers

# Traffic gen
cat <<SCR >>/home/workload/cron.sh
#!/bin/bash
sudo curl --insecure -m 1 https://docs.aviatrix.com; echo "\$(date): curl avx" | sudo tee -a /var/log/traffic-gen.log
sudo curl --insecure -m 1 https://aws.amazon.com; echo "\$(date): curl aws" | sudo tee -a /var/log/traffic-gen.log
sudo curl --insecure -m 1 https://azure.microsoft.com; echo "\$(date): curl azure" | sudo tee -a /var/log/traffic-gen.log
sudo curl --insecure -m 1 https://cloud.google.com; echo "\$(date): curl gcp" | sudo tee -a /var/log/traffic-gen.log
sudo curl --insecure -m 1 https://www.oracle.com/cloud; echo "\$(date): curl oci" | sudo tee -a /var/log/traffic-gen.log
sudo curl --insecure -m 1 https://stackoverflow.com/; echo "\$(date): curl oci" | sudo tee -a /var/log/traffic-gen.log
SCR
chmod +x /home/workload/cron.sh
crontab<<CRN
*/1 * * * * /home/workload/cron.sh
0 10 * * * rm -f /var/log/traffic-gen.log
CRN
sudo systemctl restart cron
