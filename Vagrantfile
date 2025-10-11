Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |vb|
    vb.gui    = true
    vb.memory = 10240
    vb.cpus   = 6

    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"] 
    vb.customize ["modifyvm", :id, "--vtxvpid", "on"]
    vb.customize ["modifyvm", :id, "--vtxux", "on"]
    vb.customize ["modifyvm", :id, "--pae", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]

    vb.name = "debian-host-nested"
  end

  # Install a desktop environment (e.g., GNOME)
  config.vm.provision "shell", inline: <<-SHELL
    # Arreglar dpkg si está roto
    dpkg --configure -a
    apt-get update
    apt-get install -y ubuntu-desktop

    # Instalamos dependencias básicas
    sudo apt-get install -y build-essential dkms linux-headers-$(uname -r) apt-transport-https ca-certificates curl software-properties-common

    # Instalamos VirtualBox (forzar virtualización anidada)
    sudo apt-get install -y virtualbox virtualbox-ext-pack

    # Instalamos Vagrant
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y vagrant vagrant-hostmanager

    # Instalamos herramientas adicionales
    sudo apt-get install -y git vim unzip wget firefox

    # Guest Additions (ESENCIAL para clipboard y drag&drop) 
    sudo apt-get install -y virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-dkms

    # Simple: VirtualBox + usuario en grupo
    sudo usermod -a -G vboxusers vagrant
    
    # Instalar plugin hostmanager (ignorar si falla)
    sudo -u vagrant vagrant plugin install vagrant-hostmanager || echo "Plugin hostmanager falló - continuando..."

    # Cambiar teclado a español
    sudo localectl set-keymap es
    sudo loadkeys es
    localectl status

		sudo reboot
  SHELL
end
