#!/bin/bash
nix build '.#homeConfigurations.ben.activationPackage'
./result/activate