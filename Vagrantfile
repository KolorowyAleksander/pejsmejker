instances = []

(1..3).each do |n| 
  instances.push({
    :name => "n#{n}",
    :ip => "192.168.10.#{n+10}",
  })
end

Vagrant.configure("2") do |config|
  instances.each do |instance|
    config.vm.define instance[:name] do |e|
      # create a box
      e.vm.box = "centos/7"
      e.vm.hostname = instance[:name]
      e.vm.network "private_network", ip: "#{instance[:ip]}"

      # add a virtual disk
      file_to_disk = "/tmp/vdisk#{instance[:name]}.hdi"
      e.vm.provider :virtualbox do |vb|
        if not File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 2 * 1024]
        end
        vb.customize ['storagectl', :id, '--name', 'SATA', '--add', 'sata']
        vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end

      # run all the shit
      e.vm.provision "shell", path: "install.sh"
      e.vm.provision "shell", path: "startup.sh"
    end
  end
end
