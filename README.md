# AWS_Terraform_Ansible_HA_with_CFE_HTTPS_VS_with_WAF_Ansible_Vault

<H1>Environment Deployed</H1>
<ul>
  <li>VS HTTPS with a WAF Policy</li><BR>
  <li>VS HTTP Redirect</li><BR>
  <li>Pool with Service Discovery</li><BR>
  <li>Arcadia Application Servers in an AWS Auto Scale Group and the associated tags for service discovery</li><BR>
  <li>Cloudinit is used for installation of the Tool Chain only</li><BR>
  <li>DO used for preparing the BIGIPs (Vlans, Self-IPs, NTP, Modules, DSC, etc)</li><BR>
  <li>CFE used for BIGIP HA in AWS</li><BR>
  <li>AS3 used for VS configuration</li>
</ul>

Terraform is used to create the objects into AWS.<BR>
Ansible is used to POST the Toolchain Declarations.<BR>
F5 Terraform Provider can't be used because BIGIP must be reachable when the Provider inits during the Terraform plan. That will be possible in a next version of Terraform.

<H1>Preparing a Valid SSL Cert which will be used into AS3</H1>
Create a PFX/pkcs12 file which includes the cert and private key.
You can do it with openssl : openssl pkcs12 -export -in file.crt -inkey file.key -out file.pfx 
Upload the file.pfx to a repo. 
Replace the pkcs12 url with yours into the file AS3_Template.j2.


<H1>Ansible-Vault Setup</H1>

Create a file where you have your password in it : echo "default" > ~/.vault_pass.txt

create the ansible vault env variable with the command <b><i>export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt</i></b> or add the line <b><i>vault_password_file=~/.vault_pass.txt</i></b> into the ansible.cfg file in case Terraform doesn't have access to the env variables of Ansible

Encrypt your bigip password: ansible-vault encrypt_string 'SanDiego123!' --name 'password'

Encrypt your PFX cert and key passphrase: ansible-vault encrypt_string 'default' --name 'passphrase'

Replace the vars password and passphrase with yours into the Playbooks.

