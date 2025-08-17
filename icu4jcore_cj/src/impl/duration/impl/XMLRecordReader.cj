package icu4cj.impl.duration.impl


public class XMLRecordReader <: RecordReader {
    private var r: StringReader<InputStream>

    private var nameStack: ArrayList<String>

    private var atTag: Bool = false

    private var tag: String

    public init(r: StringReader<InputStream>) {
        this.r = r
        this.nameStack = ArrayList<String>()
        if (getTag().startsWith("xml")) {
            advance()
        }
        if (getTag().startsWith("!--")) {
            advance()
        }
    }

    public override func open(title: String): Bool {
        if (getTag().equals(title)) {
            nameStack.append(title)
            advance()
            return true
        }
        return false
    }

    public override func close(): Bool {
        let ix = Int32(nameStack.size) - 1
        let name = nameStack[Int64(ix)]
        if (getTag().equals("/" + (name))) {
            nameStack.remove(Int64(ix))
            advance()
            return true
        }
        return false
    }

    public override func bool(name: String): Bool {
        let s = string(name)
        if (s.isSome()) {
            return "true".equals(s)
        }
        return false
    }

    public override func boolArray(name: String): Array<Bool> {
        let sa = stringArray(name)
        if (sa.isSome()) {
            let result = Array<Bool>(sa.size) { _ => false }
            var i = 0
            while (i < Int32(sa.size)) {
                result[Int64(i)] = "true".equals(sa[Int64(i)])
                i++
            }
            return result
        }
        return None
    }

    public override func character(name: String): Char {
        let s = string(name)
        if (s.isSome()) {
            return Char(s[0])
        }
        return '\u{ffff}'
    }

    public override func characterArray(name: String): Array<Char> {
        let sa = stringArray(name)
        if (sa.isSome()) {
            let result = Array<Char>(sa.size) { _ => '\u{0000}' }
            var i = 0
            while (i < Int32(sa.size)) {
                result[Int64(i)] = Char(sa[Int64(i)][0])
                i++
            }
            return result
        }
        return None
    }

    public override func namedIndex(name: String, names: Array<String>): UInt8 {
        let sa = string(name)
        if (sa.isSome()) {
            var i = 0
            while (i < Int32(names.size)) {
                if (sa.equals(names[Int64(i)])) {
                    return UInt8(i)
                }
                i++
            }
        }
        return 255
    }

    public override func namedIndexArray(name: String, names: Array<String>): Array<UInt8> {
        let sa = stringArray(name)
        if (sa.isSome()) {
            let result = Array<UInt8>(sa.size) { _ => 0 }
    public override func string(name: String): String {
        if (match(name)) {
            let result = readData()
            if (match("/" + (name))) {
                return result
            }
        }
        return None
    }

    public override func stringArray(name: String): Array<String> {
        if (match((name) + "List")) {
            let list = ArrayList<String>()
            var s: String
            while ((match (0) { case _ => s = string(name); s }).isSome()) {
                if ("Null".equals(s)) {
                    s = None
                }
                list.append(s)
            }
            if (match("/" + (name) + "List")) {
                return list.toArray(size))
            }
        }
        return None
    }

    public override func stringTable(name: String): Array<Array<String>> {
        if (match((name) + "Table")) {
            let list = ArrayList<Array<String>>()
            var sa: Array<String>
            while ((match (0) { case _ => sa = stringArray(name); sa }).isSome()) {
                list.append(sa)
            }
            if (match("/" + (name) + "Table")) {
                return list.toArray(size)
            }
        }
        return None
    }

    private func match(target: String): Bool {
        if (getTag().equals(target)) {
            advance()
            return true
        }
        return false
    }

    private func getTag(): String {
        if (tag.isNone()) {
            tag = readNextTag()
        }
        return tag
    }

    private func advance(): Unit {
        tag = None
    }

    private func readData(): String {
        let sb = StringBuilder()
        var inWhitespace = false
        while (true) {
            var c = readChar()
            if (c == -1 || c == Int32(UInt32('<'))) {
                atTag = c == Int32(UInt32('<'))
                break
            }
            if (c == Int32(UInt32('&'))) {
                c = readChar()
                if (c == Int32(UInt32('#'))) {
                    let numBuf = StringBuilder()
                    var radix = 10
                    c = readChar()
                    if (c == Int32(UInt32('x'))) {
                        radix = 16
                        c = readChar()
                    }
                    while (c != Int32(UInt32(';')) && c != -1) {
                        numBuf.append(Char(c))
                        c = readChar()
                    }
                    @AssertThrows[IOException]({
                        let num = parse<Int32>(numBuf.toString(), radix)
                        c = Int32(UInt32(Char(num)))
                    } catch (ex: TimeParseException) {
                        eprintln("numbuf: " + numBuf.toString() + " radix: " + radix.toString())
                        throw ex
                    }
                } else {
                    let charBuf = StringBuilder()
                    while (c != Int32(UInt32(';')) && c != -1) {
                        charBuf.append(Char(c))
                        c = readChar()
                    }
                    let charName: String = charBuf.toString()
                    if (charName == "lt") {
                        c = Int32(UInt32('<'))
                    } else if (charName == "gt") {
                        c = Int32(UInt32('>'))
                    } else if (charName == "quot") {
                        c = Int32(UInt32('\"'))
                    } else if (charName == "apos") {
                        c = Int32(UInt32('\''))
                    } else if (charName == "amp") {
                        c = Int32(UInt32('&'))
                    } else {
                        eprintln("unrecognized character entity: '" + (charName) + "'")
                        continue
                    }
                }
            }
            if (UCharacter.isWhitespace(c)) {
                if (inWhitespace) {
                    continue
                }
                c = Int32(UInt32(' '))
                inWhitespace = true
            } else {
                inWhitespace = false
            }
            sb.append(Char(c))
        }
        return sb.toString()
    }

    private func readNextTag(): String {
        var c = Int32(UInt32('\u{0000}'))
        while (!atTag) {
            c = readChar()
            if (c == Int32(UInt32('<')) || c == -1) {
                if (c == Int32(UInt32('<'))) {
                    atTag = true
                }
                break
            }
            if (!UCharacter.isWhitespace(c)) {
                eprintln("Unexpected non-whitespace character " + c.format("x"))
                break
            }
        }
        if (atTag) {
            atTag = false
            let sb = StringBuilder()
            while (true) {
                c = readChar()
                if (c == Int32(UInt32('>')) || c == -1) {
                    break
                }
                sb.append(Char(c))
            }
            return sb.toString()
        }
        return None
    }

    public func readChar(): Int32 {
        try {
            return readWrap(r.read())
        })
        return -1
    }
}
