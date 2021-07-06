BOX = "ubuntu/focal64"
#BOX = "bento/amazonlinux-2"

Vagrant.configure("2") do |config|
    config.vm.box = BOX
    
    # Set memory and CPU
    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 1
    end

    # Provision with script
    # config.vm.provision "shell", path: "xp-systemd.sh", privileged: true

    # Provision with ansible
    config.vm.provision :ansible do |ansible|
      ansible.limit = "all"
      ansible.extra_vars = {
        target_hosts: "all"
      }
      ansible.playbook = "xp-systemd.yml"
    end
end