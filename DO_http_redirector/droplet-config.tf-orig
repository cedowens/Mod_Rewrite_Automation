resource "digitalocean_droplet" "myc2-1" {
    image = "ubuntu-20-04-x64"
    name = "myc2-1"
    region = "sfo2"
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = [
      data.digitalocean_ssh_key.keyname.id
    ]

connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
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
				"sudo apt-get update -y",
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
