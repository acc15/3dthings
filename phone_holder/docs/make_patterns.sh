#!/bin/sh

montage -fill white -pointsize 30 -gravity North -label '%t' `ls --sort=t --reverse patterns/*png` -background '#333333' -tile 3x -geometry 332x332+2+2  patterns.png