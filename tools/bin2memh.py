#!/usr/bin/env python3
import sys


bytectr = 0
data = sys.stdin.buffer.read(128)
while len(data) > 0:
    for x in data:
        print("%02x" % x)
        bytectr = bytectr + 1
    data = sys.stdin.read(128)
