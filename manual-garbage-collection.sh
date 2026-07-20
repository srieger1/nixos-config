echo "available generations:"
nix-env --list-generations
# redundant - but more detail
nix profile history --profile /nix/var/nix/profiles/system

echo "removing old generations"
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d

echo "remaining generations:"
nix-env --list-generations

echo "nix-collect-garbage:"
nix-collect-garbage

# redundant? nix-collect-garbage already did everything?
echo "nix store gc:"
nix store gc

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot
