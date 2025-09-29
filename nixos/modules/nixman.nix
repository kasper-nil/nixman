{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.nixman;
  json = builtins.toJSON {
    hosts = cfg.hosts;
    features = {
      rebuild = cfg.features.rebuild;
      gc = cfg.features.gc;
      update = cfg.features.update;
    };
  };
in
{
  options.services.nixman = {
    enable = lib.mkEnableOption "nixman TUI";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixman/config.json";
      description = "Path to nixman JSON config (system-scoped).";
    };

    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of rebuild ‘profiles’ (e.g., desktop, work).";
    };

    features = {
      rebuild = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show rebuild action";
      };
      gc = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show garbage-collect action";
      };
      update = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show nix flake update action";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Drop system-scoped JSON for the app to read
    environment.etc."nixman/config.json".text = json;

    # Put the binary in PATH
    environment.systemPackages = [ pkgs.nixman or (pkgs.callPackage ../../. { }) ];
  };
}
