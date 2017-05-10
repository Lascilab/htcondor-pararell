cluster = {
    :controller => {
        :hostname => "controller",
        :ipaddress => "10.10.10.3",
        :type => "controller"
    },
    :server1 => {
        :hostname => "server1",
        :ipaddress => "10.10.10.4",
        :type => "node"
    },
    :server2 => {
        :hostname => "server2",
        :ipaddress => "10.10.10.5",
        :type => "node"
    },
}

## vagrant plugin install vagrant-hostmanager
## vagrant plugin install vagrant-cachier
## vagrant up
Vagrant.configure("2") do |global_config|
  cluster.each_pair do |name, options|
    global_config.vm.define name do |config|
      config.vm.box = "ubuntutrusty64"
      config.vm.hostname = "#{name}"
      config.vm.network :private_network, ip: options[:ipaddress]
      if Vagrant.has_plugin?("vagrant-hostmanager")
        config.vm.provision :hosts, :sync_hosts => true
      end

      config.vm.provider :virtualbox do |v|
        v.memory = 1024
        if options[:type] == "node"
            v.cpus = 2
        end
      end

      if options[:type] == "controller"
        config.vm.provision "shell", path: "scripts/controller.sh"
      elsif options[:type] == "node"
        config.vm.provision "shell", path: "scripts/node.sh"
        # config.vm.provision "shell", path: "scripts/openfoam.sh"
      end
      
      if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
      end
    end
  end
end
