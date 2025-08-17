package icu4cj.impl


public class RuleCharacterIterator {
    private var text: String

    private var pos: ParsePosition = None

    private var sym: SymbolTable

    private var buf: String

    private var bufPos: Int32 = 0

    private var isEscaped: Bool = false

    public static let DONE = -1

    public static let PARSE_VARIABLES = 1

    public static let PARSE_ESCAPES = 2

    public static let SKIP_WHITESPACE = 4

    public init(text: String, sym: SymbolTable, pos: ParsePosition) {
        if (text.isNone() || pos.getIndex() > Int32(text.size)) {
            throw IllegalArgumentException()
        }
        this.text = text
        this.sym = sym
        this.pos = pos
        buf = None
    }

    public func atEnd(): Bool {
        return buf.isNone() && pos.getIndex() == Int32(text.size)
    }

    public func next(options: Int32): Int32 {
        var c = DONE
        isEscaped = false
        while (true) {
            c = _current()
            _advance(UTF16.getCharCount(c))
            if (c == Int32(UInt32(SymbolTable.SYMBOL_REF)) && buf.isNone() && (options & PARSE_VARIABLES) != 0 && sym.isSome()) {
                let name = sym.parseReference(text, pos, Int32(text.size))
                if (name.isNone()) {
                    break
                }
                bufPos = 0
                let chars = sym.lookup(name)
                if (chars.isNone()) {
                    buf = None
                    throw IllegalArgumentException("Undefined variable: " + (name))
                }
                if (Int32(chars.size) == 0) {
                    buf = None
                }
                buf = String(chars)
                continue
            }
            if ((options & SKIP_WHITESPACE) != 0 && PatternProps.isWhiteSpace(c)) {
                continue
            }
            if (c == Int32(UInt32('\')) && (options & PARSE_ESCAPES) != 0) {
                let cpAndLength = Utility.unescapeAndLengthAt(getCurrentBuffer(), getCurrentBufferPos())
                if (cpAndLength < 0) {
                    throw IllegalArgumentException("Invalid escape")
                }
                c = Utility.cpFromCodePointAndLength(cpAndLength)
                jumpahead(Utility.lengthFromCodePointAndLength(cpAndLength))
                isEscaped = true
            }
            break
        }
        return c
    }

    public func isEscapedMethod(): Bool {
        return isEscaped
    }

    public func inVariable(): Bool {
        return buf.isSome()
    }

    public func getPos(p: RuleCharacterIterator_Position): RuleCharacterIterator_Position {
        var tempp = p
        if (tempp.isNone()) {
            tempp = RuleCharacterIterator_Position()
        }
        tempp.buf = buf
        tempp.bufPos = bufPos
        tempp.posIndex = pos.getIndex()
        return tempp
    }

    public func setPos(p: RuleCharacterIterator_Position): Unit {
        buf = p.buf
        pos.setIndex(p.posIndex)
        bufPos = p.bufPos
    }

    public func skipIgnored(options: Int32): Unit {
        if ((options & SKIP_WHITESPACE) != 0) {
            while (true) {
                let a = _current()
                if (!PatternProps.isWhiteSpace(a)) {
                    break
                }
                _advance(UTF16.getCharCount(a))
            }
        }
    }

    public func getCurrentBuffer(): String {
        if (buf.isSome()) {
            return buf
        } else {
            return text
        }
    }

    public func getCurrentBufferPos(): Int32 {
        if (buf.isSome()) {
            return bufPos
        } else {
            return pos.getIndex()
        }
    }

    public func jumpahead(count: Int32): Unit {
        if (count < 0) {
            throw IllegalArgumentException()
        }
        if (buf.isSome()) {
            bufPos += count
            if (bufPos > Int32(buf.size)) {
                throw IllegalArgumentException()
            }
            if (bufPos == Int32(buf.size)) {
                buf = None
            }
        } else {
            let i = pos.getIndex() + count
            pos.setIndex(i)
            if (i > Int32(text.size)) {
                throw IllegalArgumentException()
            }
        }
    }

    public override func toString(): String {
        let b = pos.getIndex()
        return text[0..Int64(b)] + '|'.toString() + text[Int64(b)..]
    }

    private func _current(): Int32 {
        if (buf.isSome()) {
            return UTF16.toRuneArray()[buf, bufPos]
        } else {
            let i = pos.getIndex()
            return if (i < Int32(text.size)) { UTF16.toRuneArray()[text, i] } else { DONE }
        }
    }

    private func _advance(count: Int32): Unit {
        if (buf.isSome()) {
            bufPos += count
            if (bufPos == Int32(buf.size)) {
                buf = None
            }
        } else {
            pos.setIndex(pos.getIndex() + count)
            if (pos.getIndex() > Int32(text.size)) {
                pos.setIndex(Int32(text.size))
            }
        }
    }
}


public class RuleCharacterIterator_Position {

    var buf: String

    var bufPos: Int32 = 0

    var posIndex: Int32 = 0
}
