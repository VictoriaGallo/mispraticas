# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile - Proyecto Balanceador de carga NGINX + Apache
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # --- VM1: Web Server 1 ---
  config.vm.define "web1" do |web1|
    web1.vm.hostname = "web1"
    web1.vm.network "private_network", ip: "192.168.50.10"
    web1.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
    web1.vm.provision "shell", path: "provision/web.sh"
  end

  # --- VM2: Web Server 2 ---
  config.vm.define "web2" do |web2|
    web2.vm.hostname = "web2"
    web2.vm.network "private_network", ip: "192.168.50.20"
    web2.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
    web2.vm.provision "shell", path: "provision/web.sh"
  end

  # --- VM3: Load Balancer ---
  config.vm.define "lb" do |lb|
    lb.vm.hostname = "lb"
    lb.vm.network "private_network", ip: "192.168.50.30"
    lb.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
    lb.vm.provision "shell", path: "provision/lb.sh"
  end
end

