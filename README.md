# Vagrant Packet Provider
Based heavily (almost completely) on the [Vagrant-AWS](https://github.com/mitchellh/vagrant-aws) provider written by [Mitchell Hashimoto](https://github.com/mitchellh)

## Of note:
- Packet provisions bare metal machines. It's cool.
  - Since they're bare metal, provision time is somewhat slower (5-10min) 
  - Once provisioned, I suggest `vagrant halt` and `vagrant up` for faster performance
- You need to add your SSH Key within the Packet.net portal. Vagrant will not handle this for you. (Much like the Vagrant-Google plugin)
- Your synced folders must use the rsync option (seen below)

## Example Vagrantfile:
```
Vagrant.configure("2") do |config|
    config.vm.box = "packet.box"

    config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    
    config.vm.provider :packet do |packet, override|
        packet.packet_token = "YOUR_PACKET_API_TOKEN"
        packet.project_id = "YOUR_PACKET_PROJECT_ID"

        # c2.medium.x86
        packet.plan = "MACHINE_TYPE" 

        # sjc1
        packet.facility = "DATACENTER"

        # ubuntu_16_04
        packet.operating_system = "OS" 

        # Packet provisions machines with root
        override.ssh.username = "root"
        override.ssh.private_key_path = "~/.ssh/id_rsa"
    end
end
```