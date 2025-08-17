package icu4cj.impl.duration.impl


public class XMLRecordWriter <: RecordWriter {
    private var w: StringWriter<OutputStream>

    private var nameStack: ArrayList<String>

    public init(w: StringWriter<OutputStream>) {
        this.w = w
        this.nameStack = ArrayList<String>()
    }

    public override func open(title: String): Bool {
        newline()
        writeString("<" + (title) + ">")
        nameStack.append(title)
        return true
    }

    public override func close(): Bool {
        let ix = Int32(nameStack.size) - 1
        if (ix >= 0) {
            let name: String = nameStack.remove(Int64(ix)).toString()
            newline()
            writeString("</" + (name) + ">")
            return true
        }
        return false
    }

    public func flush(): Unit {
        @AssertThrows[IOException]({
            w.flush()
        })
    }

    public override func bool(name: String, value: Bool): Unit {
        internalString(name, value.toString())
    }

    public override func boolArray(name: String, values: Array<Bool>): Unit {
        if (values.isSome()) {
            let stringValues = Array<String>(values.size)
            var i = 0
            while (i < Int32(values.size)) {
                stringValues[Int64(i)] = values[Int64(i)].toString()
                i++
            }
            stringArray(name, stringValues)
        }
    }

    private static func ctos(value: Char): String {
        if (value == '<') {
            return "&lt;"
        }
        if (value == '&') {
            return "&amp;"
        }
        return value.toString()
    }

    public override func character(name: String, value: Char): Unit {
        if (value != '\u{ffff}') {
            internalString(name, ctos(value))
        }
    }

    public override func characterArray(name: String, values: Array<Char>): Unit {
        if (values.isSome()) {
            let stringValues = Array<String>(values.size)
            var i = 0
            while (i < Int32(values.size)) {
                let value = values[Int64(i)]
                if (value == '\u{ffff}') {
                    stringValues[Int64(i)] = NULL_NAME
                } else {
                    stringValues[Int64(i)] = ctos(value)
                }
                i++
            }
            internalStringArray(name, stringValues)
        }
    }

    public override func namedIndex(name: String, names: Array<String>, value: Int32): Unit {
        if (value >= 0) {
            internalString(name, names[Int64(value)])
        }
    }

    public override func namedIndexArray(name: String, names: Array<String>, values: Array<UInt8>): Unit {
        if (values.isSome()) {
            let stringValues = Array<String>(values.size)
            var i = 0
            while (i < Int32(values.size)) {
                let value = Int32(values[Int64(i)])
                if (value < 0) {
                    stringValues[Int64(i)] = NULL_NAME
                } else {
                    stringValues[Int64(i)] = names[Int64(value)]
                }
                i++
            }
            internalStringArray(name, stringValues)
        }
    }

    public static func normalize(str: String): String {
        if (str.isNone()) {
            return None
        }
        var sb: StringBuilder
        var inWhitespace = false
        var c = '\u{0000}'
        var special = false
        var i = 0
        while (i < Int32(str.size)) {
            c = Char(str[Int64(i)])
            if (UCharacter.isWhitespace(Int32(UInt32(c)))) {
                if (sb.isNone() && (inWhitespace || c != ' ')) {
                    sb = StringBuilder(str[0..Int64(i)])
                }
                if (inWhitespace) {
                    continue
                }
                inWhitespace = true
                special = false
                c = ' '
            } else {
                inWhitespace = false
                special = c == '<' || c == '&'
                if (special && sb.isNone()) {
                    sb = StringBuilder(str[0..Int64(i)])
                }
            }
            if (sb.isSome()) {
                if (special) {
                    sb.append(if (c == '<') { "&lt;" } else { "&amp;" })
                } else {
                    sb.append(c)
                }
            }
            i++
        }
        if (sb.isSome()) {
            return sb.toString()
        }
        return str
    }

    private func internalString(name: String, normalizedValue: String): Unit {
        if (normalizedValue.isSome()) {
            newline()
            writeString("<" + (name) + ">" + (normalizedValue) + "</" + (name) + ">")
        }
    }

    private func internalStringArray(name: String, normalizedValues: Array<String>): Unit {
        if (normalizedValues.isSome()) {
            push((name) + "List")
            var i = 0
            while (i < Int32(normalizedValues.size)) {
                var value = normalizedValues[Int64(i)]
                if (value.isNone()) {
                    value = NULL_NAME
                }
                string(name, value)
                i++
            }
            pop()
        }
    }

    public override func string(name: String, value: String): Unit {
        internalString(name, normalize(value))
    }

    public override func stringArray(name: String, values: Array<String>): Unit {
        if (values.isSome()) {
            push((name) + "List")
            var i = 0
            while (i < Int32(values.size)) {
                var value = normalize(values[Int64(i)])
                if (value.isNone()) {
                    value = NULL_NAME
                }
                internalString(name, value)
                i++
            }
            pop()
        }
    }

    public override func stringTable(name: String, values: Array<Array<String>>): Unit {
        if (values.isSome()) {
            push((name) + "Table")
            var i = 0
            while (i < Int32(values.size)) {
                let rowValues: Array<String> = values[Int64(i)]
                if (rowValues.isNone()) {
                    internalString((name) + "List", NULL_NAME)
                } else {
                    stringArray(name, rowValues)
                }
                i++
            }
            pop()
        }
    }

    private func push(name: String): Unit {
        newline()
        writeString("<" + (name) + ">")
        nameStack.append(name)
    }

    private func pop(): Unit {
        let ix = Int32(nameStack.size) - 1
        let name: String = nameStack.remove(Int64(ix)).toString()
        newline()
        writeString("</" + (name) + ">")
    }

    private func newline(): Unit {
        writeString("\n")
        var i = 0
        while (i < Int32(nameStack.size)) {
            writeString(INDENT)
            i++
        }
    }

    private func writeString(str: String): Unit {
        if (w.isSome()) {
            try {
                w.write(str)
            } catch (e: IOException) {
                eprintln(e.message)
                w = None
            }
        }
    }

    static let NULL_NAME = "Null"

    private static let INDENT = "    "
}
