Requires GNU Emacs 24.4

# Installation

## install cask
https://github.com/cask/cask

## install elisp packages

    cd path/to/.emacs.d
    path/to/cask

## install ruby (1.9.3 or later)
https://www.ruby-lang.org/en/

## install ruby gems:

    cd path/to/.emacs.d
    gem install bundler
    bundle install --system

# Custom keybindings

## buffers
C-c T - term-with-title

## windows
s-B - windmove-left
s-F - windmove-right
s-N - windmove-down
s-P - windmove-up

## frames
s-O - other-frame

## ruby
C-c C-c - annotate expressions via (seeing_is_believing)
