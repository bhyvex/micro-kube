# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
SSL_TARBALL_PATH = File.expand_path("ssl/ssl.tar")

CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# WARNING: micro-kube's services and DNS expect that your node runs at the IP
# below.  Change this at your own risk.  Things WILL break.
IP = '172.17.8.100'

# Defaults for config options defined in CONFIG
$update_channel = "stable"
$image_version = "current"
$vm_memory = 2048
$vm_cpus = 1

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|

  # always use Vagrants insecure key
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % $update_channel
  if $image_version != "current"
      config.vm.box_version = $image_version
  end
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v, override|
      override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant_vmware_fusion.json" % [$update_channel, $image_version]
    end
  end

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define vm_name = "micro-kube" do |config|
    config.vm.hostname = vm_name

    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      config.vm.provider vmware do |v|
        v.vmx['memsize'] = $vm_memory
        v.vmx['numvcpus'] = $vm_cpus
      end
    end

    config.vm.provider :virtualbox do |vb|
      vb.memory = $vm_memory
      vb.cpus = $vm_cpus
    end

    config.vm.network :private_network, ip: IP

    config.vm.provision :file, :source => SSL_TARBALL_PATH, :destination => "/tmp/ssl.tar"
    config.vm.provision :shell, :inline => "mkdir -p /etc/micro-kube/ssl && tar -C /etc/micro-kube/ssl -xf /tmp/ssl.tar", :privileged => true

    config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
    config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true

  end

end
