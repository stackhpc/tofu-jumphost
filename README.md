An OpenTofu module to define a jumphost using RockyLinux.

Key features:
- No shell access to host, only SSH tunnelling is permitted [*]
- No default "rocky" user with passwordless sudo [*]
- DNF updates on boot and at 3AM
- firewalld running, only SSH permitted
- fail2ban running

[*] Except in a debug mode


See `variables.tf` for all options.
