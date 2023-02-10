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
        tableStr = jsonSer.Parse()
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