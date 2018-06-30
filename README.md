# Vagrant Packet Provider
This [Vagrant](https://vagrantup.com) plugin allows you to create and manage packet.net instances. 

Based heavily (almost completely) on the [Vagrant-AWS](https://github.com/mitchellh/vagrant-aws) provider written by [Mitchell Hashimoto](https://github.com/mitchellh)

## Of note:
- [Packet](https://packet.net) provisions bare metal machines. It's cool.
  - Since they're bare metal, provision time is somewhat slower (5-10min) 
  - Once provisioned, I suggest `vagrant halt` and `vagrant up` for faster performance.
- You need to add your SSH Key within the Packet.net portal. Vagrant will not handle this for you. (Much like the [Vagrant-Google](https://github.com/mitchellh/vagrant-google) plugin.)
- Your synced folders must use the rsync option (seen below) or it won't work.
- There are some Packet-specific options required in the config. The example explains how to find and select the correct options.

## Example Vagrantfile:
```
Vagrant.configure("2") do |config|
    config.vm.box = "packet.box"

    config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
    
    config.vm.provider :packet do |packet, override|
        # Create an API token within Packet
        # See https://help.packet.net/quick-start/api-integrations
        packet.packet_token = "YOUR_PACKET_API_TOKEN"

        # Get your project ID
        # See https://help.packet.net/faq/onboarding/portal
        packet.project_id = "YOUR_PACKET_PROJECT_ID"

        # Example: sjc1
        # See https://help.packet.net/faq/pre-sales/data-centers for
        # a list. Always use lower-case for the facility name.
        packet.facility = "DATACENTER"

        # Example: c2.medium.x86
        # Use the datacenter link above to make sure your machine
        # type is supported in your selected datacenter
        packet.plan = "MACHINE_TYPE"

        # Example: ubuntu_16_04
        # Use https://www.packet.net/developers/api/operatingsystems/
        # to find available operating systems and the correct label
        packet.operating_system = "OS"

        # Packet provisions machines with root so we must set this
        override.ssh.username = "root"

        # Make sure you've added your SSH key within Packet.
        # See https://help.packet.net/technical/infrastructure/ssh-access
        override.ssh.private_key_path = "~/.ssh/id_rsa"
    end
end
```

## Development
To work on the `vagrant-packet` plugin, clone this repository out, and use
[Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
and add the following line to your `Vagrantfile` 
```ruby
Vagrant.require_plugin "vagrant-packet"
```
Use bundler to execute Vagrant:
```
$ bundle exec vagrant --provider=packet up 
```