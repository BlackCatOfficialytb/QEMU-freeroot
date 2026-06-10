"""
Decryptor for evil_mode/three.lua — minified version of two.lua.
Uses the same XOR + hex pool algorithm; runs simplify_math first to expand the math.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from decrypt_two import main as decrypt_two_main

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.argv = [sys.argv[0], "three.lua"]
    decrypt_two_main()
