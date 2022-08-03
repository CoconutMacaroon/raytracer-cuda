#!/usr/bin/env bash
GLPATH=/usr/lib make clean all SMS="60" && optirun ./simpleCUDA2GL
