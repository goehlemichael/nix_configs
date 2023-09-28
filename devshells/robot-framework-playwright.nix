{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
        playwright
        python311Full
        python311Packages.robotframework
        nodejs_18
    ];
  shellHook =
    ''
      python3 -m venv venv
      . venv/bin/activate
      pip3 install robotframework-browser
      python3 -m Browser.entry init
    '';
}
