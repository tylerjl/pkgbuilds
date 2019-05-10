# -*- mode: ruby -*-
# vi: set ft=ruby :

memory = 512

Vagrant.configure(2) do |config|

  config.vm.box = 'archlinux/archlinux'

  %w[libvirt virtualbox].each do |provider|
    config.vm.provider provider do |vm|
      vm.memory = memory
    end
  end

  config.vm.provision 'shell', inline: 'pacman -Sy'
  config.vm.provision 'shell', inline: 'pacman -S --noconfirm base-devel namcap'

  # Useful for confirming webserver pakages
  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.synced_folder ".", "/vagrant", type: 'sshfs'
end
