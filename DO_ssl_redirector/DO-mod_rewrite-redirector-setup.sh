#!/bin/bash

echo "*******************************************************************"
echo "  Welcome to the Terraform Script Runner to Set Up Your Redirector!  "
echo "*******************************************************************"
echo ""
echo "Have you already installed terraform? (Y/N)?"
read installed

if [[ ("$installed" ==  "N") || ("$installed" == "n") ]];then
	ostype=$(uname)
	if [[ "$ostype" == "Linux" ]]; then
		echo "attempting to install terraform (linux install)..."
		curl -o ~/terraform.zip https://releases.hashicorp.com/terraform/0.13.1/terraform_0.13.1_linux_amd64.zip
		mkdir -p ~/opt/terraform
		sudo apt install unzip
		unzip ~/terraform.zip -d ~/opt/terraform
		echo "Next add terraform to your path (append export PATH=$PATH:~/opt/terraform/bin to the end)"
		nano ~/.bashrc
		. .bashrc
	elif [[ "$ostype" == "Darwin" ]]; then
		echo "Attempting to install terraform (macOS Homebrew install)..."
		brew tap hashicorp/tap
		brew install hashicorp/tap/terraform
		
	fi
fi
echo "=====>Enter the name you want to call your redirector droplet"
read dropletName
echo "=====>Enter the src IP that you will login to your redirector from (i.e., terraform will set up a firewall only allowing ssh/admin access in from this src IP)"
read adminIP
echo "=====>Enter the IP address of the backend C2 server that the redirector will sit in front of (only the redirector will have access to ports 443 and/or 80 on this host)"
read c2IP
echo "=====>Enter your Digital Ocean API key"
read DOAPIKey
echo "=====>Enter the name of your Digital Ocean ssh key (can be found in your admin console panel or you can create one there if you haven't already)"
read keyName
echo "=====>Enter the local path to the ssh private key that you use to ssh into Digital Ocean (ex: ~/.ssh/id_rsa)"
read keyPath
echo "=====>Enter the domain name for your redirector. AFTER THE SCRIPT RUNS, BE SURE TO SET UP DNS RECORDS TO POINT TO THIS REDIRECTOR'S IP ADDRESS"
read domain
echo "=====>Enter the user agent string that you want the redirector to use to allow access to your back end C2 (i.e., the unique user agent in your C2 agent)"
read uAgent
echo "=====>Do you have an authorization token (ex: bearer token) that you want to use for redirecting? (Y/N)"
read authAns

if [[ ("$authAns" == "Y") || ("$authAns" == "y") ]];then
	echo "=====>Enter the first few characters of the auth string that are consistent (ex: for a token with Bearer [random] you would enter Bearer here)"
	read authString
	sed -i -e "s/startofauthstring/$authString/g" 000-default.conf
	sed -i -e "s/startofauthstring/$authString/g" htaccess
else
	sed -i -e '20d' 000-default.conf
	sed -i -e '10d' htaccess
fi

sed -i -e "s/myc2-1/$dropletName/g" droplet-config.tf
sed -i -e "s/keyname/$keyName/g" init.tf
sed -i -e "s/keyname/$keyName/g" droplet-config.tf
sed -i -e "s/127.0.0.1/$adminIP/g" droplet-config.tf
sed -i -e "s/10.0.0.0/$c2IP/g" droplet-config.tf

sed -i -e "s/domainhere/$domain/g" init.tf
sed -i -e "s/domainhere/$domain/g" 000-default.conf
sed -i -e "s/domainhere/$domain/g" droplet-config.tf
sed -i -e 's|useragenthere|'"$uAgent"'|g' 000-default.conf
sed -i -e "s/c2IPhere/$c2IP/g" 000-default.conf
sed -i -e "s/domainhere/$domain/g" htaccess
sed -i -e 's|useragenthere|'"$uAgent"'|g' htaccess
sed -i -e "s/c2IPhere/$c2IP/g" htaccess

terraform init
echo "====>Running terraform plan for the new droplet and firewall that the droplet will be added to"
terraform plan -var "do_token=$DOAPIKey" -var "pvt_key=$keyPath"
echo "====>Applying the terraform plan..."
terraform apply -var "do_token=$DOAPIKey" -var "pvt_key=$keyPath"
cp init.tf-orig init.tf
cp droplet-config.tf-orig droplet-config.tf
cp 000-default.conf-orig 000-default.conf
cp htaccess-orig htaccess
