package icu4cj.text

public class SimpleFormatter {
    private let compiledPattern: String

    private init(compiledPattern: String) {
        this.compiledPattern = compiledPattern
    }

    public static func compile(pattern: String): SimpleFormatter {
        return compileMinMaxArguments(pattern, 0, Int32.Max)
    }

    public static func compileMinMaxArguments(pattern: String, min: Int32, max: Int32): SimpleFormatter {
        let sb = StringBuilder()
        let compiledPattern = SimpleFormatterImpl.compileToStringMinMaxArguments(pattern, sb, min, max)
        return SimpleFormatter(compiledPattern)
    }

    public func getArgumentLimit(): Int32 {
        return SimpleFormatterImpl.getArgumentLimit(compiledPattern)
    }

    public func format(values: Array<String>): String {
        return SimpleFormatterImpl.formatCompiledPattern(compiledPattern, values)
    }

    public func formatAndAppend(appendTo: StringBuilder, offsets: Array<Int32>, values: Array<String>): StringBuilder {
        return SimpleFormatterImpl.formatAndAppend(compiledPattern, appendTo, offsets, values)
    }

    public func formatAndReplace(result: StringBuilder, offsets: Array<Int32>, values: Array<String>): StringBuilder {
        return SimpleFormatterImpl.formatAndReplace(compiledPattern, result, offsets, values)
    }

    public override func toString(): String {
        let values = Array<String>(Int64(getArgumentLimit()))
        var i = 0
        while (i < Int32(values.size)) {
            values[Int64(i)] = "{" + i.toString() + '}'.toString()
            i++
        }
        return formatAndAppend(StringBuilder(), None, values).toString()
    }

    public func getTextWithNoArguments(): String {
        return SimpleFormatterImpl.getTextWithNoArguments(compiledPattern)
    }
}
