#!/bin/sh

magick `ls | grep "cut_factor_" | sort` +append -resize 1000 cut_factor.png
magick `ls | grep "thickness_" | sort` +append -resize 1000 thickness.png
magick `ls | grep "shape_" | sort` +append -resize 1000 shape.png
magick `ls | grep "holder_fillet_" | sort` +append -resize 1000 holder_fillet.png
magick `ls | grep "angle_" | sort` +append -resize 1000 angle.png
magick `ls | grep "front_support_height_" | sort` +append -resize 1000 front_support_height.png
magick `ls | grep "front_support_fillet_" | sort` +append -resize 1000 front_support_fillet.png
magick `ls | grep "device_dimensions_" | sort` +append -resize 1000 device_dimensions.png
magick `ls | grep "shelf_height_" | sort` +append -resize 1000 shelf_height.png
magick `ls | grep "charger_dimensions_" | sort` +append -resize 1000 charger_dimensions.png
magick `ls | grep "arc_radius_" | sort` +append -resize 1000 arc_radius.png
magick `ls | grep "foot_length_" | sort` +append -resize 1000 foot_length.png
magick `ls | grep "pattern_outlines_" | sort` +append -resize 1000 pattern_outlines.png
magick `ls | grep "charger_position_" | sort` +append -resize 1000 charger_position.png

