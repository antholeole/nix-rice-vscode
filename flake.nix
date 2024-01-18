{
  description = "A patched version of vscodium with custom CSS and JS.";
  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, systems, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);

      ricedVscodiumBuilder = import ./ricedVscodium.nix;
    in
    {
      packages = eachSystem (system: let 
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        ricedVscodium = settings: (ricedVscodiumBuilder ({
          inherit pkgs;
        } // settings));

        testRicedVscodium = ricedVscodium {
          css = [./test.css];
        };
      });
    };
}
