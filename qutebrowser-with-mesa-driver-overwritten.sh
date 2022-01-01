#!/bin/sh

MESA_LOADER_DRIVER_OVERRIDE=i965 qutebrowser --qt-flag ignore-gpu-blocklist --qt-flag enable-gpu-rasterization
