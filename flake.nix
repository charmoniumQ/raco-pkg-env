{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        raco-pkg-env = pkgs.stdenv.mkDerivation {
          name = "raco-pkg-env";
          src = ./.;
          propagatedBuildInputs = [
            pkgs.racket-minimal
          ];
          installPhase = ''
            mkdir -p $out/bin
            mv raco-pkg-env-lib/main.rkt $out/bin/raco-pkg-env
            chmod +x $out/bin/raco-pkg-env
          '';
        };
      in {
        packages = {
          raco-pkg-env = raco-pkg-env;
        };
        defaultPackage = raco-pkg-env;
      });
}
