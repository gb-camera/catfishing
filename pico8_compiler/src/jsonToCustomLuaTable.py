import json

class JSONSerializer():
    def __init__(self, file: str) -> None:
        self.file = file
        self.tokenCount = 0
        pass

    def Parse(self) -> str:
        with open(self.file, "r") as f:
            data = json.load(f)
            return self.ConvertDict(data)[1:-1]

    def ConvertDict(self, data) -> str:
        result = "{"
        self.tokenCount += 1
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
        self.tokenCount += 1
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
