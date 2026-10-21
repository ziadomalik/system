{ pkgs, ... }:
{
	systemd.services.eth-vpn = {
		description = "ETH VPN";
		wants = [ "network-online.target" ];
		after = [ "network-online.target" ];
		path  = [ pkgs.openconnect pkgs.oath-toolkit ];
		script = ''
		  pw=$(cat /etc/eth-vpn/password)
		  otp=$(oathtool --totp -b "$(tr -d ' ' < /etc/eth-vpn/otp-secret)")
		  printf '%s\n%s\n' "$pw" "$otp" | openconnect --useragent=AnyConnect -u zmalik@student-net.ethz.ch -g student-net --passwd-on-stdin sslvpn.ethz.ch
		'';
	};
}
