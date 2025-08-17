package icu4cj.text

class StringReplacer <: UnicodeReplacer {
    private var output: String

    private var cursorPos: Int32 = 0

    private var hasCursor: Bool = false

    private var isComplex: Bool = false

    private let data: RuleBasedTransliterator_Data

    public init(theOutput: String, theCursorPos: Int32, theData: RuleBasedTransliterator_Data) {
        output = theOutput
        cursorPos = theCursorPos
        hasCursor = true
        data = theData
        isComplex = true
    }

    public init(theOutput: String, theData: RuleBasedTransliterator_Data) {
        output = theOutput
        cursorPos = 0
        hasCursor = false
        data = theData
        isComplex = true
    }

    public override func replace(text: Replaceable, start: Int32, limit: Int32, cursor: Array<Int32>): Int32 {
        let outLen: Int32
        var newStart = 0
        if (!isComplex) {
            text.replace(start, limit, output)
            outLen = Int32(output.size)
            newStart = cursorPos
        } else {
            let buf = StringBuffer()
            var oOutput: Int32 = 0
            isComplex = false
            let tempStart = text.size
            var destStart = tempStart
            if (start > 0) {
                let len = UTF16.getCharCount(text.char32At(start - 1))
                text.copy(start - len, start, tempStart)
                destStart += len
            } else {
                text.replace(tempStart, tempStart, "\u{ffff}")
                destStart++
            }
            var destLimit = destStart
            var tempExtra = 0
            oOutput = 0
            while (oOutput < Int32(output.size)) {
                if (oOutput == cursorPos) {
                    newStart = Int32(buf.size) + destLimit - destStart
                }
                let c = UTF16.toRuneArray()[output, oOutput]
                let nextIndex = oOutput + UTF16.getCharCount(c)
                if (nextIndex == Int32(output.size)) {
                    tempExtra = UTF16.getCharCount(text.char32At(limit))
                    text.copy(limit, limit + tempExtra, destLimit)
                }
                let r = data.lookupReplacer(c)
                if (r.isNone()) {
                    UTF16.append(buf, c)
                } else {
                    isComplex = true
                    if (Int32(buf.size) > 0) {
                        text.replace(destLimit, destLimit, toString(buf))
                        destLimit += Int32(buf.size)
                        buf.setLength(0)
                    }
                    let len = r.replace(text, destLimit, destLimit, cursor)
                    destLimit += len
                }
                oOutput = nextIndex
            }
            if (Int32(buf.size) > 0) {
                text.replace(destLimit, destLimit, toString(buf))
                destLimit += Int32(buf.size)
            }
            if (oOutput == cursorPos) {
                newStart = destLimit - destStart
            }
            outLen = destLimit - destStart
            text.copy(destStart, destLimit, start)
            text.replace(tempStart + outLen, destLimit + tempExtra + outLen, "")
            text.replace(start + outLen, limit + outLen, "")
        }
        if (hasCursor) {
            if (cursorPos < 0) {
                newStart = start
                var n = cursorPos
                while (n < 0 && newStart > 0) {
                    newStart -= UTF16.getCharCount(text.char32At(newStart - 1))
                    n++
                }
                newStart += n
            } else if (cursorPos > Int32(output.size)) {
                newStart = start + outLen
                var n = cursorPos - Int32(output.size)
                while (n > 0 && newStart < text.size) {
                    newStart += UTF16.getCharCount(text.char32At(newStart))
                    n--
                }
                newStart += n
            } else {
                newStart += start
            }
            cursor[0] = newStart
        }
        return outLen
    }

    public override func toReplacerPattern(escapeUnprintable: Bool): String {
        let rule = StringBuffer()
        let quoteBuf = StringBuffer()
        var cursor = cursorPos
        if (hasCursor && cursor < 0) {
            while (match (0) { case _ => cursor++; cursor - 1 } < 0) {
                Utility.appendToRule(rule, Int32(UInt32('@')), true, escapeUnprintable, quoteBuf)
            }
        }
        var i = 0
        while (i < Int32(output.size)) {
            if (hasCursor && i == cursor) {
                Utility.appendToRule(rule, Int32(UInt32('|')), true, escapeUnprintable, quoteBuf)
            }
            let c = Char(output[Int64(i)])
            let r = data.lookupReplacer(Int32(UInt32(c)))
            if (r.isNone()) {
                Utility.appendToRule(rule, Int32(UInt32(c)), false, escapeUnprintable, quoteBuf)
            } else {
                let buf = StringBuffer(" ")
                buf.append(r.toReplacerPattern(escapeUnprintable))
                buf.append(' ')
                Utility.appendToRule(rule, toString(buf), true, escapeUnprintable, quoteBuf)
            }
            i++
        }
        if (hasCursor && cursor > Int32(output.size)) {
            cursor -= Int32(output.size)
            while (match (0) { case _ => cursor--; cursor + 1 } > 0) {
                Utility.appendToRule(rule, Int32(UInt32('@')), true, escapeUnprintable, quoteBuf)
            }
            Utility.appendToRule(rule, Int32(UInt32('|')), true, escapeUnprintable, quoteBuf)
        }
        Utility.appendToRule(rule, -1, true, escapeUnprintable, quoteBuf)
        return toString(rule)
    }

    public override func addReplacementSetTo(toUnionTo: UnicodeSet): Unit {
        var ch: Int32 = 0
        var i = 0
        while (i < Int32(output.size)) {
            ch = UTF16.toRuneArray()[output, i]
            let r = data.lookupReplacer(ch)
            if (r.isNone()) {
                toUnionTo.add(ch)
            } else {
                r.addReplacementSetTo(toUnionTo)
            }
            i += UTF16.getCharCount(ch)
        }
    }
}
