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
		source = "htaccess"
		destination = "/root/.htaccess"
	}

	provisioner "remote-exec" {
        inline = [
				"sudo apt-get update -y && sudo apt-get upgrade -y",
				"sudo apt-get -y install ufw",
				"sudo ufw default allow outgoing",
				"sudo ufw allow from 127.0.0.1 to any port 22",
				"sudo ufw allow 80",
				"sudo ufw --force enable",
				"sudo apt-get install apache2 -y",
				"sudo a2enmod rewrite proxy proxy_http ssl proxy_connect",
				"sudo mv /root/000-default.conf /etc/apache2/sites-available/000-default.conf",
				"sudo mv /root/apache2.conf /etc/apache2/apache2.conf",
				"sudo mv /root/.htaccess /var/www/html/.htaccess",
				"sudo service apache2 restart",
        	]
}

}
