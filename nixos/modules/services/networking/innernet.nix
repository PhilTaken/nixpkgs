{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.innernet;
in {
  meta.maintainers = with maintainers; [ PhilTaken ];

  options.services.innernet = with types; {
    enable = mkEnableOption "innernet client daemon";

    #port = mkOption {
      #type = port;
      #default = 41641;
      #description = "The port to listen on for tunnel traffic (0=autoselect).";
    #};

    interfaceName = mkOption {
      type = str;
      default = "tailscale0";
      description = ''The interface name for tunnel traffic. Use "userspace-networking" (beta) to not use TUN.'';
    };

    package = mkOption {
      type = package;
      default = pkgs.tailscale;
      defaultText = "pkgs.innernet";
      description = "The package to use for tailscale";
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    networking.wireguard.enable = true;
    #networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    environment.systemPackages = [ cfg.package ]; # for the CLI
    systemd.packages = [ cfg.package ];
    systemd.services.innernetd = {
      after = [ "network-online.target" "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.iproute ];
      serviceConfig =  {
        Restart = "always";
        ExecStart = "${cfg.package}/bin/innernet-server serve ${cfg.interfaceName}";
      };
    };
  };
}
