# Cam's Dotfiles

This repo contains the dotfiles I'd care to move between machines and keep in version control. 

It explicity depends on `stow`. 

```bash
# Install Stow
paru -S stow

# Stow all configs
stow -vt ~ */

# Stow a single application's config
stow -vt ~ nvim
```

