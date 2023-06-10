{
  description = "Creating Haskell Single Page Applications";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = new: old:
        {
          haskell = old.haskell //
            {
              packages = old.haskell.packages //
                {
                  ghc962 = old.haskell.packages.ghc962.override (oldArgs: {
                    overrides = haskellOverlay old;
                  });
                };
            };
        };

      haskellOverlay = old: hnew: hold: {
        bsb-http-chunked = old.haskell.lib.dontCheck hold.bsb-http-chunked;
      };

      out = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };

        in
        {

          devShells.default =
            let haskellPackages = pkgs.pkgsCross.ghcjs.buildPackages.haskell.packages.ghc962;
            in
            haskellPackages.shellFor {
              packages = pkgs: [];
              withHoogle = false;
              buildInputs = with haskellPackages; [
                haskell-language-server
                pkgs.pkgsCross.ghcjs.buildPackages.haskell.compiler.ghc962
                cabal-install
              ];
            };
        };
    in
    flake-utils.lib.eachDefaultSystem out // {
      overlays = {
        default = overlay;
      };
    };
}
