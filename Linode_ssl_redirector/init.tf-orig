terraform {
	required_providers {
		linode = {
			source = "linode/linode"
			version = "1.14.3"
		}
	}
}

provider "linode" {
  token = "mylinodetoken"
}

resource "linode_instance" "myc2-1" {
	image = "linode/ubuntu20.04"
	label = "myc2-1"
	region = "us-west"
	type = "g6-nanode-1"
	authorized_keys = [chomp(file("publickeyhere"))]
	connection {
		host = self.ip_address
		user = "root"
		type = "ssh"
		private_key = chomp(file("privatekeyhere"))
		timeout = "2m"
	}

	provisioner "file" {
		source = "000-default.conf"
		destination = "/root/000-default.conf"
	}

	provisioner "file" {
		source = "apache2.conf"
		destination = "/root/apache2.conf"
	}

	provisioner "file" {
		source = ".htaccess"
		destination = "/root/.htaccess"
	}

	provisioner "remote-exec" {
        inline = [
				"sudo apt-get update -y && sudo apt-get upgrade -y",
				"sudo apt-get -y install ufw",
				"sudo ufw default allow outgoing",
				"sudo ufw allow from 127.0.0.1 to any port 22",
				"sudo ufw allow 80",
				"sudo ufw allow 443",
				"sudo ufw --force enable",
				"sudo apt-get install apache2 -y",
				"sudo a2enmod rewrite proxy proxy_http ssl proxy_connect",
				"sudo a2ensite default-ssl.conf",
				"sudo mv /root/000-default.conf /etc/apache2/sites-available/000-default.conf",
				"sudo mv /root/apache2.conf /etc/apache2/apache2.conf",
				"sudo mv /root/.htaccess /var/www/html/.htaccess",
				"sudo systemctl restart apache2",
				"sudo apt-get install -y software-properties-common",
				"sudo add-apt-repository universe",
				"sudo apt install -y certbot && sudo apt install -y python3-certbot-apache",
				"sudo certbot -d www.domainhere,domainhere --apache --register-unsafely-without-email --agree-tos --no-redirect",
				"sudo sed -i -e 's/#//' /var/www/html/.htaccess",
				"sudo sed -i -e 's/#---//' /etc/apache2/sites-available/000-default.conf",
				"sudo sed -i -e 's/:80/:443/g' /etc/apache2/sites-available/000-default.conf",
				"sudo ufw deny 80",
				"sudo service apache2 restart",
				"sudo apt-get install git",
        	]
}

}
