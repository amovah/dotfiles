# Pin the macOS SDK that clang builds against.
#
# clang picks the highest-numbered SDK in the Command Line Tools SDKs
# directory, not the CLT-managed `MacOSX.sdk` symlink. A leftover SDK from a
# beta CLT therefore wins over the one the installed toolchain matches, and
# linking dies on stub libraries the older `ld` cannot parse:
#
#   ld: tapi error: malformed file
#   .../MacOSX27.0.sdk/usr/lib/libSystem.B.tbd: unknown architecture
#                      arm64e.x1-macos, arm64e.x1-maccatalyst ]
#
# That breaks every native build, not just one -- tree-sitter parsers, node
# native modules, cgo, Rust cc-rs. Pointing SDKROOT at the symlink hands clang
# the SDK that CLT considers current, and keeps doing so across CLT upgrades.
#
# Deleting the stray SDK is the more complete fix, since this only reaches
# programs started from fish -- a GUI-launched app inherits nothing:
#
#   sudo rm -rf /Library/Developer/CommandLineTools/SDKs/MacOSX<n>.sdk
#
# Not interactive-gated: builds run in non-interactive shells too.

if test (uname -s) = Darwin
    set -l sdk /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
    test -e $sdk; and set -gx SDKROOT $sdk
end
