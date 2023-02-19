import json

# Lua Format:
# `--[[json lua_variable_name relative_path_to_JSON_file]]`

class JSONSerializer():
    def __init__(self, file: str) -> None:
        self.file = file
        self.tokenCount = 0
        pass

    def Parse(self) -> str:
        fileName = self.file.split("/")[-1]
        print(f"Converting [{fileName}] to lua table string...")
        with open(self.file, "r") as f:
            data = json.load(f)
            tableStr: str = self.ConvertDict(data)[1:-1]
            print("\tJSON finishing converting...")
            tokensSaved = self.tokenCount - 1
            print(f"\tYou saved {tokensSaved} tokens")
            charsUsed = len(tableStr) + 5
            print(f"\t{charsUsed} chars used after replacement")
            return tableStr

    def ConvertDict(self, data) -> str:
        result = "{"
        self.tokenCount += 2
        for i, item in enumerate(data):
            result += f"{item}="
            self.tokenCount += 2
            if type(data[item]) is dict:
                result += self.ConvertDict(data[item])
            elif type(data[item]) is list:
                result += self.ConvertList(data[item])
            else:
                result += str(data[item])
            if i < len(data) - 1:
                result += ","
                self.tokenCount += 1
        return result + "}"

    def ConvertList(self, listData: list[any]) -> str:
        result = "{"
        self.tokenCount += 2
        for i, item in enumerate(listData):
            if type(item) is None: continue

            if type(item) is dict:
                result += self.ConvertDict(item)
            elif type(item) is list:
                result += self.ConvertList(item)
            else:
                result += str(item)
            if i < len(listData) - 1:
                result +=","
                self.tokenCount += 1
        return result + "}"
