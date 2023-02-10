import json

class JSONSerializer():
    def __init__(self, file: str) -> None:
        self.file = file
        pass

    def Parse(self) -> str:
        with open(self.file, "r") as f:
            data = json.load(f)
            return self.ConvertDict(data)[1:-1]

    @staticmethod
    def ConvertDict(data) -> str:
        result = "{"
        for i, item in enumerate(data):
            result += f"{item}="
            if type(data[item]) is dict:
                result += JSONSerializer.ConvertDict(data[item])
            elif type(data[item]) is list:
                result += JSONSerializer.ConvertList(data[item])
            else:
                result += str(data[item])
            if i < len(data) - 1:
                result += ","
        return result + "}"

    @staticmethod
    def ConvertList(listData: list[any]) -> str:
        result = "{"
        for i, item in enumerate(listData):
            if type(item) is None: continue

            if type(item) is dict:
                result += JSONSerializer.ConvertDict(item)
            elif type(item) is list:
                result += JSONSerializer.ConvertList(item)
            else:
                result += str(item)
            if i < len(listData) - 1:
                result +=","
        return result + "}"
