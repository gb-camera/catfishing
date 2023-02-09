import sys, os
from pathlib import Path
from src.stitcher import Stitcher

def main():
    if len(sys.argv) < 3:
        raise Exception("Arguments: src_directory game.p8 main.lua")
    cwd = sys.argv[1]
    pico8File = sys.argv[2]
    mainLuaFile = sys.argv[3]

    if cwd == ".":
        cwd = os.getcwd()
    elif cwd == "..":
        cwd = Path(os.getcwd()).parent
    elif not os.path.exists(cwd):
        raise("Path can't be found")

    stitcher = Stitcher(cwd)
    picoFilePath = os.path.join(cwd, pico8File)
    mainLuaPath = os.path.join(cwd, mainLuaFile)
    print("Stitching Lua Files...")
    result = stitcher.Stitch(picoFilePath, mainLuaPath)
    print("Finished Stitching Lua Files")
    print(f"Writing to {pico8File}...")
    with open(picoFilePath, "w", encoding="utf8") as f:
        f.write(result)
    print(f"Finished Writing to {pico8File}")


main()