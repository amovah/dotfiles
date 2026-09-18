# Put Homebrew's bin ahead of the system one, and nothing else.
#
# macOS runs path_helper for login shells, which appends the /etc/paths.d
# entries -- Homebrew's among them -- *after* /usr/bin. Every name Homebrew
# shares with an Apple copy therefore loses, and brew says so on install:
#
#   The following python@3.14 executables are shadowed by other commands
#   earlier in your PATH:
#     pip3 (shadowed by /usr/bin/pip3)
#     python3 (shadowed by /usr/bin/python3)
#
# So `brew install python3` lands 3.14 in /opt/homebrew/bin while `python3`
# still resolves to Apple's frozen 3.9.6.
#
# `brew shellenv` fixes this by prepending to the very front, which would also
# put Homebrew ahead of $fish_user_paths and the nvm bin -- so a later
# `brew install node` would quietly shadow the nvm-managed one, the same class
# of bug this file exists to fix. Inserting directly before /usr/bin beats the
# system copies and leaves every user-managed tool where it is.
#
# Apple's copies stay put, so macOS internals calling /usr/bin/python3 by
# absolute path are unaffected.
#
# $PATH is edited directly rather than through $fish_user_paths, which is a
# universal variable here: a global of that name would shadow it and silently
# drop what it holds. Editing $PATH does not persist, which is what we want --
# conf.d runs for every shell, so this is reapplied rather than accumulated.
#
# Not interactive-gated: scripts and build steps need the same resolution.

set -l brew_bin /opt/homebrew/bin

if test -d $brew_bin
    set -l rebuilt
    set -l placed 0

    for dir in $PATH
        # Drop any existing entry, so re-running cannot duplicate it.
        test "$dir" = $brew_bin; and continue

        if test $placed -eq 0; and test "$dir" = /usr/bin
            set -a rebuilt $brew_bin
            set placed 1
        end

        set -a rebuilt $dir
    end

    # No /usr/bin in $PATH at all: fall back to the front.
    test $placed -eq 0; and set rebuilt $brew_bin $rebuilt

    set -gx PATH $rebuilt
end
