#!/bin/bash
./zig-out/bin/raytracing_one_week > image.ppm
magick image.ppm image.png
rm image.ppm
