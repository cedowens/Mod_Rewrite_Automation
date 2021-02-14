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
echo "=====>Enter the name you want to call your Linode redirector"
read linodeName
echo "=====>Enter the src IP that you will ssh into your redirector infra from (i.e., terraform will set up a firewall only allowing ssh/admin access in from this src IP"
read adminIP
echo "=====>Enter the IP address of the backend C2 server that the redirector will sit in front of (only the redirector will have access to ports 443 and/or 80 on this host)"
read c2IP
echo "=====>Enter your Linode Personal Access Token"
read linodeToken
echo "=====>Enter the local path to the ssh public key you want to load onto this host for ssh access (ex: ~/.ssh/id_rsa.pub)"
read pubKey
echo "=====>Enter the local path to the ssh private key that you want Terraform to use to ssh into this Linode host (ex: ~/.ssh/id_rsa)"
read privKey
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
	sed -i -e '15d' 000-default.conf
	sed -i -e '3d' htaccess
fi

sed -i -e "s/myc2-1/$linodeName/g" init.tf
sed -i -e 's|publickeyhere|'"$pubKey"'|g' init.tf
sed -i -e 's|privatekeyhere|'"$privKey"'|g' init.tf
sed -i -e "s/127.0.0.1/$adminIP/g" init.tf
sed -i -e "s/10.0.0.0/$c2IP/g" init.tf
sed -i -e "s/mylinodetoken/$linodeToken/g" init.tf
sed -i -e "s/domainhere/$domain/g" init.tf
sed -i -e "s/domainhere/$domain/g" 000-default.conf
sed -i -e 's|useragenthere|'"$uAgent"'|g' 000-default.conf
sed -i -e "s/c2IPhere/$c2IP/g" 000-default.conf
sed -i -e "s/domainhere/$domain/g" htaccess
sed -i -e 's|useragenthere|'"$uAgent"'|g' htaccess
sed -i -e "s/c2IPhere/$c2IP/g" htaccess

terraform init
echo "====>Running terraform plan for the new redirector..."
terraform plan
echo "====>Applying the terraform plan..."
terraform apply
cp init.tf-orig init.tf
cp 000-default.conf-orig 000-default.conf
cp htaccess-orig htaccess
