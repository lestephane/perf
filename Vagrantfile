Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest: 5000, host: 5000

  config.vm.provider "virtualbox" do |v|
	  v.name = 'FlameGraphs'
	  v.memory = 2048
	  v.cpus = 2
  end

  config.vm.provision "shell", path: "./configure-as-root.sh"

  # This enables keeping track of local diffs
  config.vm.synced_folder "#{ENV['HOME']}/.m2", "#{ENV['HOME']}/.m2"
  config.vm.synced_folder "#{ENV['HOME']}/GitRepos/envimation-portal", "#{ENV['HOME']}/GitRepos/envimation-portal"
  config.vm.synced_folder "#{ENV['HOME']}/GitRepos/perf-map-agent", '/home/vagrant/perf-map-agent'
  config.vm.synced_folder "#{ENV['HOME']}/GitRepos/FlameGraph", '/home/vagrant/FlameGraph'
  config.vm.synced_folder "#{ENV['HOME']}/GitRepos/async-profiler", '/home/vagrant/async-profiler'
  config.vm.synced_folder '/opt/jetbrains', '/opt/jetbrains'
end
