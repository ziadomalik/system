{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }: {
    nixosModules.default = { pkgs, ... }: {
      systemd.services.eth-vpn = {
        description = "ETH VPN";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.openconnect pkgs.oath-toolkit ];
        script = ''
          printf '%s\n%s\n' \
            "$(cat /etc/eth-vpn/password)" \
            "$(oathtool --totp -b "$(tr -d ' ' < /etc/eth-vpn/otp-secret)")" |
          openconnect --useragent=AnyConnect \
            -u zmalik@student-net.ethz.ch -g student-net \
            --passwd-on-stdin sslvpn.ethz.ch
        '';
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = 35; # > 30s, so a retry gets a fresh code
        };
      };
    };
  };
}
