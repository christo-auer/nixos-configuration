{
  description = "Home Manager configuration of chris";

  inputs = {

    private-config-data = {
        url = "git+ssh://chris@nagi-remote/home/chris/git/private-config-data.git";
        flake = false;
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    tuxedo-nixos = {
      url = "github:sund3RRR/tuxedo-nixos";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest"; 
      # nix-flatpak has no `nixpkgs` input, so nothing to follow.
    };

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eilmeldung = {
      url = "github:christo-auer/eilmeldung";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { private-config-data, nixpkgs, eilmeldung, home-manager, stylix, nixvim, nur, nix-flatpak, mcp-servers-nix, claude-desktop, tuxedo-nixos, mango, ... }:
    let
      system = "x86_64-linux";
      # pkgs = import nixpkgs {
      #   inherit system;
      #   overlays = [ eilmeldung.overlays.default ];
      # };
      private-values = import (private-config-data + "/values.nix");
    in {

      homeConfigurations."chris" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [ 
           ({...}: {
             nixpkgs.overlays = [ eilmeldung.overlays.default ];
           })
           nix-flatpak.homeManagerModules.nix-flatpak
           stylix.homeModules.stylix
           nixvim.homeModules.nixvim
           nur.modules.homeManager.default
           eilmeldung.homeManager.default
           mango.hmModules.mango
          ./home-manager/home.nix 
        ];

        extraSpecialArgs = {
          inherit private-values;
          private-data = private-config-data;
          inherit claude-desktop;
          inherit mcp-servers-nix;
          inherit eilmeldung;
        };


      };

      nixosConfigurations = 
      let common-modules = [
        nix-flatpak.nixosModules.nix-flatpak
        ./nixos/configuration.nix
        ./nixos/snapper.nix
        ./nixos/nfs-mount.nix
        ./nixos/users.nix
        ./nixos/docker.nix
        ./nixos/keyd.nix
      ]; in
      {
        waka = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/waka-hardware-configuration.nix
            ./nixos/waka.nix
          ] ++ common-modules;
        };

        kokiri = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            tuxedo-nixos.nixosModules.default
            ./nixos/kokiri-hardware-configuration.nix
            ./nixos/kokiri.nix
            ./nixos/btrbk.nix
          ] ++ common-modules;
        };
      };
  };
}
