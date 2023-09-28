{ config, pkgs, lib, ... }:

let
  user = "";
  password = "";
  interface = "";
  hostname = "";
in {

  imports = [
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/raspberry-pi/4"
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi.firmwareConfig = ''
        gpu_mem=192
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = hostname;
  };
  programs.mosh.enable = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    raspberrypi-eeprom
    libraspberrypi
    firefox
    mkpasswd
  ];

  environment.etc."profile".text = ''
    export DISPLAY=:0
  '';

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
    settings.LogLevel = "VERBOSE";
    settings.X11Forwarding = true;
  };
  services.tailscale.enable = true;

  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.raspberry-pi."4".touch-ft5406.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    displayManager.autoLogin.enable = true;
    videoDrivers = [ "modesetting" ];
    displayManager.autoLogin.user = "guest";
  };

  services.xserver.displayManager.sessionCommands = ''
    xset s off
    xset -dpms
    firefox --kiosk http://<FLIGHTAWARE HOST IP>:8080/
  '';

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      hashedPassword = password;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        ""
      ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
