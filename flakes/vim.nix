{ pkgs, ... }:
{
	environment.variables = { EDITOR = "nvim"; };

	environment.systemPackages = with pkgs; [
		(neovim.override {
			viAlias = true;
			vimAlias = true;
			configure = {
				packages.myPlugins = 
					with pkgs.vimPlugins; {
						start = [ 
							vim-lastplace
							vim-nix
							vim-yaml
							coc-nvim
							ctrlp 
						];
						opt = [];
					};
			};
			customRC = ''
				set nocompatible
				set backspace=indent,eol,start
			'';
		})
	];
}
