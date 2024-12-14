default:
    echo 'Hello, world!'

switch:
    darwin-rebuild switch --flake . --verbose

# List all secrets in the flake
sops-list-secrets:
    find . -type f \
        | grep -E "$(yq -r '.creation_rules[].path_regex' .sops.yaml | paste -sd '|')"
