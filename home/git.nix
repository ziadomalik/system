{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Ziad Malik"; 
      user.email = "me@ziadmalik.com";

      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
}
