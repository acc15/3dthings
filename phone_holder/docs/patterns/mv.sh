#!/bin/sh

i=0

for f in frame*.png; do
    mv $f $i.png
    ((i++))
done