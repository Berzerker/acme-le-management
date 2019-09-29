# acme-le-management
Script to manage and renew acme.sh more granular than what the default method provides

# Installation

1. Install [acme.sh](https://github.com/Neilpang/acme.sh). Default location should drop everything in `~/.acme.sh`

2. Edit the script according to your specific configuration (comments for each area dictate configuration requirements)

3. Test with running the `updateacme.sh` script.

4. If everything works, add the file to run daily via crontab. This should automatically keep your Let's Encrypt certs up to date.
