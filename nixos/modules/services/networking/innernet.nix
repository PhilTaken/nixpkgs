{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.innernet;
in {
  meta.maintainers = with maintainers; [ PhilTaken ];

  options.services.innernet = with types; {
    enable = mkEnableOption "innernet client daemon";

    port = mkOption {
      type = port;
      default = 51820;
      description = "The port to listen on for tunnel traffic";
    };

    configFile = mkOption {
      type = path;
      description = "Path to the config file for the innernet server interface";
    };

    package = mkOption {
      type = package;
      default = pkgs.innernet;
      defaultText = "pkgs.innernet";
      description = "The package to use for innernet";
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
    };
  };

  config = let
    interfaceName = builtins.head (builtins.match "[a-zA-Z_/-]+/([a-zA-Z_-]+).conf" "${cfg.configFile}");
  in mkIf cfg.enable {
    networking.wireguard.enable = true;
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    environment.systemPackages = [ cfg.package ]; # for the CLI
    environment.etc = {
      "innernet-server/${interfaceName}.conf" = {
        mode = "0644"; text = fileContents "${cfg.configFile}";
      };
    };

    systemd.packages = [ cfg.package ];
    systemd.services.innernetd = {
      after = [ "network-online.target" "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.iproute ];
      environment = { RUST_LOG = "info"; };
      serviceConfig =  {
        Restart = "always";
        ExecStart = "${cfg.package}/bin/innernet-server serve ${interfaceName}";
      };
    };
  };
}
