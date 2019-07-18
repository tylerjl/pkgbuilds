# -*- mode: ruby -*-
# vi: set ft=ruby :

memory = 512

pkgs = %w[
  base-devel
  devtools
  diffstat
  git
  jq
  namcap
  pacman-contrib
  pacutils
  parallel
  vifm
  vim
  wget
]

Vagrant.configure(2) do |config|
  config.vm.box = 'archlinux/archlinux'

  %w[libvirt virtualbox].each do |provider|
    config.vm.provider provider do |vm|
      vm.memory = memory
    end
  end

  config.vm.provision 'shell', inline: 'pacman -Sy'
  config.vm.provision 'shell', inline: "pacman -S --noconfirm #{pkgs.join(' ')}"
  config.vm.provision 'shell', inline: 'curl -O  https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz'

  # Useful for confirming webserver pakages
  config.vm.network 'forwarded_port', guest: 80, host: 8080

  config.vm.synced_folder '.', '/vagrant', type: 'sshfs'
end
