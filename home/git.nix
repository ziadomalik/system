{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Ziad Malik"; 
      user.email = "contact@ziadmalik.com";

      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
}
