{ config, pkgs, inputs, ... }:

{
  imports =
   [
      ./hardware-configuration.nix
      inputs.nix-minecraft.nixosModules.minecraft-servers
   ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.boxy = {
    isNormalUser = true;
    description = "boxy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };

    overlays = [ 
      inputs.nix-minecraft.overlay
      (final: super: { 
        nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
      }) 
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  environment.variables.Editor = "vim";

  # Firewall Settings
  networking.firewall.allowedTCPPorts = [ 443 80 22 25565]; # My network is closed off anyway-- so good luck lolol
  networking.firewall.enable = true;

  # Minecraft Server Setup

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      test = {
        enable = true;

     	# package = pkgs.paperServers.paper-1_21_3;
	# Performance doesnt *seem* to matter regardless of the server software.

	serverProperties = {
	  max-players = 5;
	  hardcore = true;
	  gamemode = "survival";
	  difficulty = "hard";
	  simulation-distance = 10;
	  motd = "Boxy's survival server!";
	  view_distance = 10;
	  allow-flight = true; # I *really* hate dealing with "flying isn't enabled on this server"..

	};
      };
    };
  };

  system.stateVersion = "24.05";



}
