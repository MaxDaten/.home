default:
    echo 'Hello, world!'

switch:
    sudo darwin-rebuild switch --flake . --verbose

update:
    nix flake update --commit-lock-file

# List all secrets in the flake
sops-list-secrets:
    find . -type f \
        | grep -E "$(yq -r '.creation_rules[].path_regex' .sops.yaml | paste -sd '|')"
