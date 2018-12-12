#!/usr/bin/env bash

function usage
{
  echo "usage: $0 image"
  echo "Make app icons from the large app icon. For a list of all required app icons, open the Target in Xcode, go to the first General tab, scroll down to App Icons."
  exit 1
}

img=$1
if [ -z "${img}" ]; then
  img="../Large App Icon.png"
  #usage
fi

function resize_img
{
  size=$1

  resize_opt="${size}x${size}"
  out_img="AppIcon_${resize_opt}.png"

  echo convert -resize ${resize_opt} "$img" "$out_img"
  convert -resize ${resize_opt} "$img" "$out_img"
}

# App
resize_img 57
resize_img 114
resize_img 120
resize_img 72
resize_img 144
resize_img 76
resize_img 152
resize_img 180

# Spotlight
resize_img 29
resize_img 58
resize_img 80
resize_img 50
resize_img 100
resize_img 40
resize_img 80

# Settings
resize_img 29
resize_img 58
resize_img 29
resize_img 58
