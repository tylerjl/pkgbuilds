# pkgbuilds

Centralized repo for my collection of Arch Linux PKGBUILD files.

Now that AUR4 relies upon git for tracking, this repo serves as a central point for feedback if people prefer PRs/issues/etc. to the AUR interface.

## Publishing

    git subtree push --prefix=$package $package master

Assuming that you've added `$package` as a remote upstream pointing at the AUR.
