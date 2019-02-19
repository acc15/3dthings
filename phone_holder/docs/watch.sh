#!/bin/sh

generate() {
    ./prepare_images.sh
    pandoc README.md -o README.html
}

generate
while inotifywait -e close_write *.md *.png; do 
    generate
done
