# Apache Mod_Rewrite Terrafrom Automation
Bash scripts that take variables from the user and then call terraform scripts to automate standing up apache2 with mod_rewrite in front of C2 servers. Right now, this repo supports standing up redirectors in Linode or Digital Ocean, and I have different scripts for standing up http redirectors versus https redirectors. Since the mod_rewrite redirector setup scripts use a user agent value and optionally a bearer token, these redirectors are not C2 dependent and can work for any C2 that uses http or https.

These bash and terraform scripts were built to be run on either Linux or macOS hosts, and first check to see if you have terraform installed. If terraform is not installed, the script will attempt to install it for you before proceeding.

**NOTE: After running, terraform will start apache2 using the root user account. It is recommended that you log in, create a local user with sudo, and restart apache using that user account rather than root, since running tools as root is not recommended**

## Prerequisites

- homebrew (to install terraform on macOS if you do not already have terraform installed)

- You will need to generate a public/private key pair locally for use (ex: Linode will put the public key on the host you stand up and use your private key to ssh in)

- For standing up redirectors in Linode, you will need a Linode Personal Access Token (can be generated under the "API Tokens" link under your profile in the web console. For standing up redirectors in Digital Ocean, you will need a Digital Ocean API key (can be done via the web admin console page).

## Instructions

> cd into directory of your choice

> chmod +x *.sh

> ./[bash_script_you_are_running]

### Info on the types of bash scripts include

#### 1. Linode_ssl_redirector/Linode-mod_rewrite-redirector-setup.sh 

This will setup an ssl redirector using mod_rewrite on an Ubuntu Linode nanode 1GB host. The script will take the following parameters for input and redirector configuration/setup:

- source IP that you can use to ssh into your redirector (terraform will setup a ufw firewall that only allows ssh in from this source IP)

- IP address of the backend C2 server that the redirector will sit in front of. Later, be sure to log into the back end C2 server and restrict http/https login only to the redirector so that your C2 server is not accessible publicly. I have some additional terraform scripts to help with this as well (https://github.com/cedowens/Linode_Terraform_Scripts, https://github.com/cedowens/Terraform_DigitalOcean_Scripts).

- Your Linode personal access token

- The local path to your ssh public key

- The local path to your ssh private key

- Domain name for your redirector (this will be used in the Apache config files as well as by certbot to install ssl certificates for your domain). As Linode spins the host up, I usually go ahead and change the IP address in my domain provider to the IP of the recently spun up redirector.

- User Agent (This is the regex value for a user-agent string that you want to specify which will be added into the .htaccess and 000-default.conf files. I have copies of these locally with placeholder values, and the bash script replaces those placeholder values with what the user enters and later terraform remotely copies these files over to the newly stood up redirector). ***IT IS IMPORTANT TO MAKE SURE THAT YOUR REGEX WORKS HERE. I HAVE INCLUDED SOME EXAMPLES BELOW***

    - For example, if you set a unique user agent string in your C2 client such as "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3; rv:10.0) Gecko/20100101 Firefox/10.0.9.1.5". You could then use a regex on the unique part of that user agent string. So in this example, when prompted for the user agent string in this script you could enter ***Firefox\/10.0.9.1.5***. Using this example, the script would then add ***Firefox\/10.0.9.1.5*** as ***RewriteCond %{HTTP_USER_AGENT} "Firefox\/10.0.9.1.5" [NC]*** in the 000-default.conf and .htaccess files.
    
- Optional authorization token (if your C2 agent uses an Authorization token, you can include this here. Since the token would be random, you can just key in on the static portion of that header. For example if the C2 client uses a header of ***Authorization: Bearer [random value]*** then you can enter the static value of ***Bearer*** here and the script will then add ***Bearer*** as ***RewriteCond %{HTTP:Authorization} ^Bearer*** in the 000-default.conf and .htaccess files.

Bash will then perform all of the variable replacements in the local init.tf, htaccess, and 000-default.conf files and then kick off a terraform plan and apply. Once you agree to the apply then terraform will stand up the Redirector in Linode.


#### 2. Linode_http_redirector/Linode-mod_rewrite-redirector-setup.sh

This will setup an http (non-ssl) redirector using mod_rewrite on an Ubuntu Linode nanode 1GB host. The script will take the following parameters for input and redirector configuration/setup:

- source IP that you can use to ssh into your redirector (terraform will setup a ufw firewall that only allows ssh in from this source IP)

- IP address of the backend C2 server that the redirector will sit in front of. Later, be sure to log into the back end C2 server and restrict http/https login only to the redirector so that your C2 server is not accessible publicly. I have some additional terraform scripts to help with this as well (https://github.com/cedowens/Linode_Terraform_Scripts, https://github.com/cedowens/Terraform_DigitalOcean_Scripts).

- Your Linode personal access token

- The local path to your ssh public key

- The local path to your ssh private key

- Domain name for your redirector (this will be used in the Apache config files). As Linode spins the host up, I usually go ahead and change the IP address in my domain provider to the IP of the recently spun up redirector.

- User Agent (This is the regex value for a user-agent string that you want to specify which will be added into the .htaccess and 000-default.conf files. I have copies of these locally with placeholder values, and the bash script replaces those placeholder values with what the user enters and later terraform remotely copies these files over to the newly stood up redirector). ***IT IS IMPORTANT TO MAKE SURE THAT YOUR REGEX WORKS HERE. SEE EXAMPLE ABOVE IN #1***
    
- Optional authorization token (if your C2 agent uses an Authorization token, you can include this here. Since the token would be random, you can just key in on the static portion of that header. For example if the C2 client uses a header of ***Authorization: Bearer [random value]*** then you can enter the static value of ***Bearer*** here and the script will then add ***Bearer*** as ***RewriteCond %{HTTP:Authorization} ^Bearer*** in the 000-default.conf and .htaccess files.

Bash will then perform all of the variable replacements in the local init.tf, htaccess, and 000-default.conf files and then kick off a terraform plan and apply. Once you agree to the apply then terraform will stand up the Redirector in Linode.
