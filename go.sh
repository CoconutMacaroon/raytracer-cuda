#!/usr/bin/env bash
GLPATH=/usr/lib make clean all SMS="61" && optirun ./simpleCUDA2GL
