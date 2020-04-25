import fnmatch
import os
from os import path
import sys
import subprocess

def main(argc, argv):
    if argc != 1:
        print("Usage: <source dir> <target dir>")
        return

    sourceDir = argv[0]
    targetRootDir = argv[0]

    matches = []
    for dir, dirnames, filenames in os.walk(sourceDir):
        for filename in fnmatch.filter(filenames, "*.N2PK"):
            relativeRoot = path.relpath(dir, sourceDir)
            src = path.join(dir, filename)
            dst = path.join(targetRootDir, relativeRoot+dir+"_unpacked")
            matches.append([src, dst])

    for m in matches:
        print(m[0])
        with open(os.devnull) as f:
            cmdLine = [ "Unpakke.exe", "upkk_n2pk.dll", "unpack", m[0], m[1] ]
            subprocess.call(cmdLine, stdout = f)

if __name__ == "__main__":
    main(len(sys.argv[1:]), sys.argv[1:])