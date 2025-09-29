{
  description = "nixman – tiny TUI scaffold with system JSON config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      # Build the Go binary
      packages = forAllSystems (
        pkgs:
        let
          pname = "nixman";
        in
        {
          ${pname} = pkgs.buildGoModule {
            pname = pname;
            version = "0.0.1";
            src = ./script/.;

            # Pin Go modules (first build will tell you the correct hash to paste here)
            vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

            # Helpful so nix run can infer the executable if you skip apps
            meta.mainProgram = "nixman";
          };
          default = pkgs.${pname};
        }
      );

      # Optional but convenient: nix run .#nixman
      apps = nixpkgs.lib.genAttrs systems (system: {
        nixman = {
          type = "app";
          program = "${self.packages.${system}.nixman}/bin/nixman";
        };
        default = self.apps.${system}.nixman;
      });

      # NixOS module you can import on hosts
      nixosModules = {
        nixman = import ./nixos/modules/nixman.nix;
      };
    };
}
