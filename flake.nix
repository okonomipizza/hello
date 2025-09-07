{
  description = "A JSON with Comments formatter written in Zig";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";
    flake-utils.url = "github:numtide/flake-utils";

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

  };

  outputs = {
    self,
    nixpkgs,
    zig,
    ...
  }:
    builtins.foldl' nixpkgs.lib.recursiveUpdate {} (
      builtins.map (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          devShell.${system} = pkgs.callPackage ./devShell.nix {
            zig = zig.packages.${system}."0.15.1";
          };
          

          packages.${system} = let
            mkArgs = optimize: {
              inherit optimize;

              revision = self.shortRev or self.dirtyShortRev or "dirty";
              zig = zig.packages.${system}."0.15.1";
            };
          in rec {
            hello-debug = pkgs.callPackage ./package.nix (mkArgs "Debug");
            hello-releasesafe = pkgs.callPackage ./package.nix (mkArgs "ReleaseSafe");
            hello-releasefast = pkgs.callPackage ./package.nix (mkArgs "ReleaseFast");

            hello = hello-releasefast;
            default = hello;
          };

          formatter.${system} = pkgs.alejandra;

        }
        # Our supported systems are the same supported systems as the Zig binaries.
      ) (builtins.attrNames zig.packages)
    );
}
