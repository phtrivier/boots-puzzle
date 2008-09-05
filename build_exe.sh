#!/bin/sh

# This should make it possible to
# build an executable to be able to run the game
# without ruby ...
ruby rubyscript2exe.rb init.rb
mv init_linux foobar