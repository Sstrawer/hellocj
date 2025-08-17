package icu4cj.impl


public class UnicodeRegex <: Cloneable & Freezable<UnicodeRegex> & StringTransform {

    private static let SUPP_ESCAPE = Pattern.compile("\\\\U00([0-9a-fA-F]{6})")

    private var symbolTable: SymbolTable

    public func getSymbolTable(): SymbolTable {
        return symbolTable
    }

    public func setSymbolTable(symbolTable: SymbolTable): UnicodeRegex {
        this.symbolTable = symbolTable
        return this
    }

    public override func transform(regex: String): String {
        let result = StringBuilder()
        let temp = UnicodeSet()
        let pos = ParsePosition(0)
        var state = 0
        var i = 0
        while (i < Int32(regex.size)) {
            let ch = Char(regex[Int64(i)])
            match (state) {
                case 0 => if (ch == '\') {
                    if (UnicodeSet.resemblesPattern(regex, i)) {
                        i = processSet(regex, i, result, temp, pos)
                        continue
                    }
                    state = 1
                } else if (ch == '[') {
                    if (UnicodeSet.resemblesPattern(regex, i)) {
                        i = processSet(regex, i, result, temp, pos)
                        continue
                    }
                }
                case 1 => if (ch == 'Q') {
                    state = 2
                } else {
                    state = 0
                }
                case 2 => if (ch == '\') {
                    state = 3
                }
                case 3 => if (ch == 'E') {
                    state = 0
                } else if (ch != '\') {
                    state = 2
                }
                case _ => ()
            }
            result.append(ch)
            i++
        }
        return result.toString()
    }

    public static func fix(regex: String): String {
        return STANDARD.transform(regex)
    }

    public static func compile(regex: String): Pattern {
        return Pattern.compile(STANDARD.transform(regex))
    }

    public static func compile(regex: String, options: Int32): Pattern {
        return Pattern.compile(STANDARD.transform(regex), options)
    }

    public func compileBnf(bnfLines: String): String {
        return compileBnf(ArrayList(<--("\\r\\n|\\n")) : ArrayList<T> => ArrayList<String> -->)
    }

    public func compileBnf(lines: ArrayList<String>): String {
        let variables = getVariables(lines)
        let unused = LinkedHashSet(variables.keys() as Collection<??String>)
        var i = 0
        while (i < 2) {
            for (entry in variables.entrySet()) {
                let variable = entry.getKey()
                let definition = entry.getValue()
                for (entry2 in variables.entrySet()) {
                    let variable2 = entry2.getKey()
                    let definition2 = entry2.getValue()
                    if (variable.equals(variable2)) {
                        continue
                    }
                    let altered2: String = definition2.replace(variable, definition)
                    if (!altered2.equals(definition2)) {
                        unused.remove(variable)
                        variables.put(variable2, altered2)
                    }
                }
            }
            i++
        }
        if (Int32(unused.size) != 1) {
            throw IllegalArgumentException("Not a single root: " + toString(unused))
        }
        return variables.get(unused.iterator().next())
    }

    public func getBnfCommentString(): String {
        return bnfCommentString
    }

    public func setBnfCommentString(bnfCommentString: String): Unit {
        this.bnfCommentString = bnfCommentString
    }

    public func getBnfVariableInfix(): String {
        return bnfVariableInfix
    }

    public func setBnfVariableInfix(bnfVariableInfix: String): Unit {
        this.bnfVariableInfix = bnfVariableInfix
    }

    public func getBnfLineSeparator(): String {
        return bnfLineSeparator
    }

    public func setBnfLineSeparator(bnfLineSeparator: String): Unit {
        this.bnfLineSeparator = bnfLineSeparator
    }

    public static func appendLines(result: ArrayList<String>, file: String, encoding: String): ArrayList<String> {
        let isTrue = FileInputStream(file)
        try {
            return appendLines(result, isTrue, encoding)
        } finally {
        }
    }

    public static func appendLines(result: ArrayList<String>, inputStream: InputStream, encoding: String): ArrayList<String> {
        let input = BufferedReader(// Мapping is present but failed: StringReader<InputStream>(inputStream, if (encoding.isNone()) { "UTF-8" } else { encoding }))
        while (true) {
            let line = input.readLine()
            if (line.isNone()) {
                break
            }
            result.append(line)
        }
        return result
    }

    public override func cloneAsThawed(): UnicodeRegex {
        try {
            return // Мapping is present but failed: clone()
        } catch (e: CloneNotSupportedException) {
            throw IllegalArgumentException()
        }
    }

    public override func freeze(): UnicodeRegex {
        return this
    }

    public override func isFrozen(): Bool {
        return true
    }

    private func processSet(regex: String, i: Int32, result: StringBuilder, temp: UnicodeSet, pos: ParsePosition): Int32 {
        var tempi = i
        try {
            pos.setIndex(tempi)
            let x = temp.clear().applyPattern(regex, pos, symbolTable, 0)
            x.complement().complement()
            var pattern = x.toPattern(false)
            if (pattern.contains("\\U")) {
                pattern = SUPP_ESCAPE.matcher(pattern).replaceAll("\\\\x{$1}")
            }
            result.append(pattern)
            tempi = pos.getIndex() - 1
            return tempi
        } catch (e: Exception) {
            throw IllegalArgumentException("Error in " + (regex)).initCause(e)
        }
    }

    private static let STANDARD = UnicodeRegex()

    private var bnfCommentString: String = "#"

    private var bnfVariableInfix: String = "="

    private var bnfLineSeparator: String = "\n"

    private var LongestFirst: Comparator = UnicodeRegex_1(this) as Comparator

    private func getVariables(lines: ArrayList<String>): Map<String, String> {
        let variables = TreeMap(LongestFirst)
        var variable: String
        let definition = StringBuffer()
        var count = 0
        for (line in lines) {
            count++
            if (Int32(line.size) == 0) {
                continue
            }
            if (Char(line[0]) == '\u{feff}') {
                line = line[1..]
            }
            if (bnfCommentString.isSome()) {
                let hashPos = indexOfWrap(line.indexOf(bnfCommentString))
                if (hashPos >= 0) {
                    line = line[0..Int64(hashPos)]
                }
            }
            let trimline = line.trimAscii()
            if (Int32(trimline.size) == 0) {
                continue
            }
            var linePart = line
            if (Int32(linePart.trimAscii().size) == 0) {
                continue
            }
            let terminated = trimline.endsWith(";")
            if (terminated) {
                linePart = linePart[0..Int64(indexOfWrap(linePart.lastIndexOf(UInt8(UInt32(';')))))]
            }
            let equalsPos = indexOfWrap(linePart.indexOf(bnfVariableInfix))
            if (equalsPos >= 0) {
                if (variable.isSome()) {
                    throw IllegalArgumentException("Missing ';' before " + count.toString() + ") " + (line))
                }
                variable = linePart[0..Int64(equalsPos)].trimAscii()
                if (variables.contains(variable)) {
                    throw IllegalArgumentException("Duplicate variable definition in " + (line))
                }
                definition.append(linePart[Int64(equalsPos + 1)..].trimAscii())
            } else {
                if (variable.isNone()) {
                    throw IllegalArgumentException("Missing '=' at " + count.toString() + ") " + (line))
                }
                definition.append(bnfLineSeparator).append(linePart)
            }
            if (terminated) {
                variables.put(variable, toString(definition))
                variable = None
                definition.setLength(0)
            }
        }
        if (variable.isSome()) {
            throw IllegalArgumentException("Missing ';' at end")
        }
        return variables
    }
}


class UnicodeRegex_1 <: Comparator {
    init(this_0: UnicodeRegex) { }

    public override func compare(obj0: Object, obj1: Object): Int32 {
        let arg0: String = toString(obj0)
        let arg1: String = toString(obj1)
        let len0 = Int32(arg0.size)
        let len1 = Int32(arg1.size)
        if (len0 != len1) {
            return len1 - len0
        }
        return arg0.compare(arg1).value()
    }
}
