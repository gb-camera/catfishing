from src.compiler import Compiler, FunctionData
from src.jsonToCustomLuaTable import JSONSerializer

class Stitcher():
    def __init__(self, srcDirectory: str) -> None:
        self.compiler = Compiler(srcDirectory)
        self.hazards = set({
            "function", "if", "for", "while", "return",
            "[[", "]]", "local", "pico-8 cartridge // http://www.pico-8.com", 
            "version 39", '" "', "and", "or", '"', "goto", "else", "not"
        })
        pass

    def Stitch(self, pico8FilePath: str, mainFilePath: str) -> str:
        with open(pico8FilePath, encoding="utf8") as pf:
            lines: list[str] = pf.readlines()
            buffer:list[str] = []
            readingLua = False
            readingMain = False
            for line in lines:
                if not readingLua:
                    buffer.append(line)
                    if line.count("__lua__") > 0:
                        readingLua = True
                        readingMain = True
                        continue

                if readingLua and readingMain:
                    mainData = self._StitchMain(mainFilePath)
                    buffer.append(mainData)
                    readingMain = False
                    continue

                if readingLua and not readingMain:
                    if line.count("__gfx__"):
                        buffer.append(line)
                        readingLua = False
                
        return self._ListToString(buffer)

    def _StitchMain(self, mainFilePath: str) -> str:
        buffer: list[str] = []
        with open(mainFilePath, encoding="utf8") as f:
            lines: list[str] = f.readlines()
            for i, line in enumerate(lines):
                if line.count("--[[remove]]") > 0: continue
                if line.count("--[[preserve]]") > 0:
                    buffer.append(line)
                    continue
                if line.lstrip().startswith("--"):
                    # Stringify JSON File
                    if line.startswith("--[[json"):
                        args: list[str] = line.split(" ")
                        if len(args) != 3: continue
                        replacementLine:str = Compiler.JsonStringify(args[1], args[2])
                        buffer.append(replacementLine)
                    # Skip comments
                    continue
                # Copy code
                if line.count("#include") == 0:
                    functionName: str = Compiler._GetFunctionName(line)
                    if self.compiler.FunctionExist(functionName):
                        raise Exception(f"Function {functionName} exist in {self.compiler.GetFunctionData(functionName)} and in main file on line: {i + 1}")
                    buffer.append(line)
                else:
                    # Stitch included file
                    fileName = Compiler._ParseFileName(line)
                    data = self.compiler.Compile(fileName)
                    buffer.append(self._ListToString(data))
        mainData = self._ListToString(buffer)
        return mainData
            

    def _ListToString(self, data: list[any]) -> str:
        buffer: list[str] = []
        result = ""
        flag = False
        for dat in data:
            if type(dat) == list:
                buffer += dat
            else:
                buffer.append(dat)
        for line in buffer:
            if line.count("__gfx__") > 0:
                flag = True
                
            if not flag:
                if line.count("#include") > 0: continue
                if line == "\n": continue
                # if line.lstrip().startswith("--") and not line.lstrip().startswith("--[[preserve]]"): continue

                # line = self._Sanitize(line) # Basic mimifying
        
            result += line
        if not result.endswith("\n"):
            result += "\n"
        return result

    def _Sanitize(self, line: str) -> str:
        result = line.lstrip()
        state = self._HasHazard(result)
        if state: return result
        return result.replace(" ", "")

    def _HasHazard(self, line: str) -> bool:
        for hazard in self.hazards:
            if line.count(hazard) > 0:
                return True
        return False
