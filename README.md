in order to use:

`nix build '.#homeConfigurations.ben.activationPackage'`

and then

`./result/activate`


in order to get app tray apps in gnome use:

`ln -s ~/.nix-profile/share/applications/* ~/.local/share/applications/`