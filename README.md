in order to use:

`nix build '.#homeConfigurations.ben.activationPackage'`

and then

`./result/activate`

or just use:

`./update.sh`

in order to get app tray apps in gnome use:

`ln -s ~/.nix-profile/share/applications/* ~/.local/share/applications/`

helpful links:
home manager configs: `https://rycee.gitlab.io/home-manager/options.html`
nix packages: `https://search.nixos.org/packages`
