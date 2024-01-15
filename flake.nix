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
        ricedVscodium = rice: (ricedVscodiumBuilder { 
          inherit pkgs rice;

          lib = pkgs.lib;
        });

        # just making sure it works
        testRicedVscodium = ricedVscodium {};
      });
    };
}