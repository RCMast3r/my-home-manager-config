{ pkgs, ... }:
{
  nextcloud-client = {
    enable = true;
    startInBackground = true;
    package = pkgs.nextcloud-client;
  };
}