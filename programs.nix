{ pkgs, ... }:
{
  home-manager = {
    enable = true;
  };
  vscode = {
    mutableExtensionsDir = false;
    enable = true;
    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    extensions = [ pkgs.vscode-extensions.twxs.cmake pkgs.vscode-extensions.ms-vscode.cmake-tools pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced pkgs.vscode-extensions.ms-vscode.cpptools pkgs.vscode-extensions.jnoortheen.nix-ide pkgs.vscode-extensions.vscodevim.vim ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "3.3.1";
        sha256 = "sha256-zBZFpOWJ4JEv6qu9XT1u0uspZ+N2wKrpL3joC+/t/zs=";
      }
      {
        name = "cmake-language-support-vscode";
        publisher = "josetr";
        version = "0.0.9";
        sha256 = "sha256-LNtXYZ65Lka1lpxeKozK6LB0yaxAjHsfVsCJ8ILX8io=";
      }
    ];

    userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
      "cmake.configureOnOpen" = false;
      "editor.minimap.enabled" = false;
    };
    keybindings = [
      {
        key = "ctrl+shift+x";
        command = "-workbench.view.extensions";
        when = "viewContainer.workbench.view.extensions.enabled";
      }
      {
        key = "ctrl+shift+x";
        command = "workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+w";
        command = "-workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenNavigatePreviousInEditorPicker";
        when = "inEditorsPicker && inQuickOpen";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenLeastRecentlyUsedEditorInGroup";
        when = "!activeEditorGroupEmpty";
      }
      {
        key = "ctrl+shift+tab";
        command = "workbench.action.previousEditor";
      }
      {
        key = "ctrl+pageup";
        command = "-workbench.action.previousEditor";
      }
      {
        key = "ctrl+tab";
        command = "workbench.action.nextEditor";
      }
      {
        key = "ctrl+pagedown";
        command = "-workbench.action.nextEditor";
      }
    ];
  };
  git = {
    enable = true;
    userEmail = "rcmast3r1@gmail.com";
    userName = "Ben Hall";
  };

}
