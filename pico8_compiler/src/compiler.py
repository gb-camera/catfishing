import os
from src.jsonToCustomLuaTable import JSONSerializer

class FunctionData():
    def __init__(self, file_name:str, line:int) -> None:
        self.name = file_name
        self.line = line 

    def __repr__(self) -> str:
        return f"file: {self.name} on line: {self.line + 1}"

class Compiler():
    def __init__(self, srcDirectory: str) -> None:
        self.includedFiles:set = set({})
        self.functions: dict[str, ] = {}
        self.srcDirectory = srcDirectory
        pass

    def Compile(self, file: str, pathPrefix:str = "") -> list[str]:
        buffer: list[str] = []
        if not file.endswith(".lua"):
            raise Exception("Invalid lua file: " + file)

        fileName = file.split(".")[0].strip()
        if fileName in self.includedFiles:
            return []

        self.includedFiles.add(fileName)
        preprocess = os.path.join(self.srcDirectory, pathPrefix)
        path = os.path.join(preprocess, self._WinReverseSlashes(file))
        with open(path, encoding="utf8") as f:
            lines: list[str] = f.readlines()
            for i, line in enumerate(lines):
                if line.count("--[[remove]]") > 0: continue
                if line.count("#include") > 0:
                    fileName = self._ParseFileName(line)
                    if fileName in self.includedFiles:
                        continue
                    self.includedFiles.add(fileName)
                    prefix = self._GetPathPrefix(file)
                    compiledData = self.Compile(fileName, prefix)
                    if not compiledData[-1].endswith("\n"):
                        compiledData[-1] += "\n"
                    buffer.append(compiledData)
                elif line.lstrip().startswith("function"):
                    functionName: str = self._GetFunctionName(line)
                    if functionName in self.functions:
                        raise Exception(f"Function {functionName} exist in {self.functions[functionName]} and in {FunctionData(file, i)}")
                    self.functions[functionName] = FunctionData(file, i)
                elif line.lstrip().startswith("--"):
                    # Stringify JSON File
                    if line.startswith("--[[json"):
                        args: list[str] = line.split(" ")
                        if len(args) != 3: continue
                        replacementLine:str = Compiler.JsonStringify(args[1], args[2])
                        buffer.append(replacementLine)
                    continue
                buffer.append(line)
        return buffer

    def FunctionExist(self, functionName: str) -> bool:
        return functionName in self.functions

    def GetFunctionData(self, functionName: str) -> FunctionData:
        return self.functions[functionName]

    @staticmethod
    def JsonStringify(variableName: str, filepath: str) -> str:
        filepath = filepath.replace("]]\n", "")
        if os.path.exists(filepath):
            jsonSerializer = JSONSerializer(filepath)
            tableStr: str = jsonSerializer.Parse()
            return variableName + '="' + tableStr + '"\n'
        else: 
            raise Exception(f"Can't locate JSON file with path: {filepath}")

    @staticmethod
    def _ParseFileName(line: str) -> str:
        return line.split(" ")[1].strip()

    @staticmethod 
    def _GetFunctionName(line: str) -> str:
        tokens: list[str] = line.split(" ")
        result = ""
        for i, token in enumerate(tokens[1:]):
            result += token
            if i < len(tokens[1:]):
                result += " "
        return result

    @staticmethod
    def _WinReverseSlashes(path: str) -> str:
        if os.name == 'nt' :
            return path.replace("/", "\\\\")
        else:
            return path

    @staticmethod
    def _GetPathPrefix(path: str) -> str:
        prefixes = path.split("/")
        return Compiler._JoinPrefixes(prefixes[:-1])
    
    @staticmethod
    def _JoinPrefixes(prefixes: list[str]) -> str:
        result = ""
        for prefix in prefixes:
            if os.name == 'nt' :
                result += prefix + "\\\\"
            else:
                result += prefix +'/'
        return result