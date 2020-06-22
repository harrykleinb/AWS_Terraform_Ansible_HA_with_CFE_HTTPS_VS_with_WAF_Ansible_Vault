# AWS_Terraform_Ansible_HA_with_CFE_HTTPS_VS_with_WAF_Ansible_Vault

<H1>Environment Deployed</H1>
<ul>
  <li>A pair of BIG-IPs in HA (AWS API)</li><BR>
  <li>BIG-IPs have 3 NICS : mgmt, external, internal</li><BR>
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


<H1>Before launching the plan</H1>
Edit the file <i>variable.tf</i>
Modify the variables to reflect your own setup. For instance, replace some vars with your:
<ul>
  <li>userid</li><BR>
  <li>aws account id</li><BR>
  <li>private aws key</li><BR>
  <li>aws region</li><BR>
  <li>IP addresses</li><BR>
</ul>


<H1>Preparing a Valid SSL Cert which will be used into AS3</H1>
Create a PFX/pkcs12 file which includes the cert and private key.
You can do it with openssl : openssl pkcs12 -export -in file.crt -inkey file.key -out file.pfx 
Upload the file.pfx to a repo. 
Replace the pkcs12 url with yours into the file AS3_Template.j2.


<H1>Ansible-Vault Setup</H1>

Create a file where you have your password in it : echo "default" > ~/.vault_pass.txt

Create the ansible vault env variable with the command <b><i>export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt</i></b><BR>

Add the line <b><i>vault_password_file=~/.vault_pass.txt</i></b> into the ansible.cfg file (looks like Terraform doesn't have access to the env variables of Ansible)

Encrypt your bigip password (for instance BIGIPpwd123!) and set it into the vault admin_pwd variable: <BR>
  <b><i>ansible-vault encrypt_string 'BIGIPpwd123!' --name 'admin_pwd'</i></b>

Encrypt the passphrase (for instance default) of your PFX cert and set it into the vault passphrase variable: <br>
  <b><i>ansible-vault encrypt_string 'default' --name 'passphrase'</i></b>

Replace the names of the vars admin_pwd and passphrase with yours into the Playbooks which use them.

