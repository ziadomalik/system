{ ... }:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      r = "ranger";
      config = "vim ~/system";
      rebuild = "sudo nixos-rebuild switch --flake ~/system";
      update = "nix flake update --flake ~/system";
    }; 
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;   
  };
}
