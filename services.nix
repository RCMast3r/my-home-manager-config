{ pkgs, ... }:
{
  ystemd = {
      services = { 
  yourScriptService = {
    enable = true;
    description = "chrome-fix";
    script = [
      pkgs.writeText
      "fix-chrome.sh"
      ''
        #!/bin/sh
        rm -rf ${config.home.homeDirectory}/.config/google-chrome/Singleton*
      ''
    ];
    wantedBy = [ "default.target" ];
  };
      }'
}
