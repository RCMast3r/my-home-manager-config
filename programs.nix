{pkgs, ...}:
{
  home-manager = {
    enable = true;
  };
  vscode = {
    mutableExtensionsDir = false;
    enable = true;
    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    extensions = [ pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced pkgs.vscode-extensions.ms-vscode.cpptools pkgs.vscode-extensions.jnoortheen.nix-ide pkgs.vscode-extensions.vscodevim.vim] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "3.3.1";
        sha256 = "sha256-fIQCG3S5CnqoZFAlwbDG740Z/nIFMQRAYY5/LnRNMSo=";
      }
    ];
    
    userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
    };
  };
  
}