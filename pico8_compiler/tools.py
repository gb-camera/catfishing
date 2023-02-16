import sys
import pkg_resources
from src.jsonToCustomLuaTable import JSONSerializer

def main():
    if len(sys.argv) < 2:
        raise Exception("Arguments: flag file")

    flag = sys.argv[1]
    file = sys.argv[2]
    installed = {pkg.key for pkg in pkg_resources.working_set}

    if flag == "-j" and file.endswith(".json"):
        jsonSer = JSONSerializer(file)
        print(f"Converting {file} to lua table string...")
        tableStr = jsonSer.Parse()
        print("JSON finishing converting...")
        tokensSaved = jsonSer.tokenCount - 1
        print(f"You saved {tokensSaved} tokens")
        charsUsed = len(tableStr) + 2
        print(f"Lua Table String is {charsUsed} chars long including the quotes after pasting")

        if "pyperclip" not in installed:
            print("Missing PyperClip::printing output instead...")
            print(tableStr)
        else:
            import pyperclip
            print("PyperClip installed::sending string to clipboard...")
            pyperclip.copy(tableStr)

    else:
        print("Unknown Flag or Invalid Args")

main()