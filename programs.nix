{ pkgs, ... }:
{
  home-manager = {
    enable = true;
  };
  vscode = {
    mutableExtensionsDir = false;
    enable = true;
    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    extensions = [ pkgs.vscode-extensions.marp-team.marp-vscode pkgs.vscode-extensions.ms-python.python pkgs.vscode-extensions.ms-vscode-remote.remote-ssh pkgs.vscode-extensions.twxs.cmake pkgs.vscode-extensions.ms-vscode.cmake-tools pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced pkgs.vscode-extensions.ms-vscode.cpptools pkgs.vscode-extensions.jnoortheen.nix-ide pkgs.vscode-extensions.vscodevim.vim ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
      {
        name = "cortex-debug";
        publisher = "marus25";
        version = "1.12.1";
        sha256 = "sha256-ioK6gwtkaAcfxn11lqpwhrpILSfft/byeEqoEtJIfM0=";
      }
      {
        name = "debug-tracker-vscode";
        publisher = "mcu-debug";
        version = "0.0.15";
        sha256 = "sha256-2u4Moixrf94vDLBQzz57dToLbqzz7OenQL6G9BMCn3I=";
      }
      {
        name = "memory-view";
        publisher = "mcu-debug";
        version = "0.0.24";
        sha256 = "sha256-SOs+h0MlypaICmueQ2dkqNJYc/J0e14U+SAmGYuJYvk=";
      }
      {
        name = "rtos-views";
        publisher = "mcu-debug";
        version = "0.0.7";
        sha256 = "sha256-VvMAYU7KiFxwLopUrOjvhBmA3ZKz4Zu8mywXZXCEHdo=";
      }
      {
        name = "peripheral-viewer";
        publisher = "mcu-debug";
        version = "1.4.6";
        sha256 = "sha256-flWBK+ugrbgy5pEDmGQeUzk1s2sCMQJRgrS3Ku1Oiag=";
      }
    ];

    userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
      "cmake.configureOnOpen" = false;
      "platformio-ide.autoRebuildAutocompleteIndex" = false;
      "editor.minimap.enabled" = false;
      "cortex-debug.stlinkPath.linux" = "nix/store/j9gj5jhp50qb9hdzg1y7rlx6nilflyfa-stlink-1.7.0/bin/st-util";
      "window.zoomLevel" = 1;
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
