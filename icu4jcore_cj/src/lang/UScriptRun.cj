package icu4cj.lang



public class UScriptRun {
    
    public init() {
        let nullChars: Array<Char> = None
        reset(nullChars, 0, 0)
    }

    
    public init(text: String) {
        reset(text)
    }

    
    public init(text: String, start: Int32, count: Int32) {
        reset(text, start, count)
    }

    
    public init(chars: Array<Char>) {
        reset(chars)
    }

    
    public init(chars: Array<Char>, start: Int32, count: Int32) {
        reset(chars, start, count)
    }

    
    public func reset(): Unit {
        while (stackIsNotEmpty()) {
            pop()
        }
        scriptStart = textStart
        scriptLimit = textStart
        scriptCode = UScript.INVALID_CODE
        parenSP = -1
        pushCount = 0
        fixupCount = 0
        textIndex = textStart
    }

    
    public func reset(start: Int32, count: Int32): Unit {
        var len = 0
        if (text.isSome()) {
            len = Int32(text.size)
        }
        if (start < 0 || count < 0 || start > len - count) {
            throw IllegalArgumentException()
        }
        textStart = start
        textLimit = start + count
        reset()
    }

    
    public func reset(chars: Array<Char>, start: Int32, count: Int32): Unit {
        var tempchars = chars
        if (tempchars.isNone()) {
            tempchars = emptyCharArray
        }
        text = tempchars
        reset(start, count)
    }

    
    public func reset(chars: Array<Char>): Unit {
        var length = 0
        if (chars.isSome()) {
            length = Int32(chars.size)
        }
        reset(chars, 0, length)
    }

    
    public func reset(str: String, start: Int32, count: Int32): Unit {
        var chars: Array<Char>
        if (str.isSome()) {
            chars = str.toRuneArray()
        }
        reset(chars, start, count)
    }

    
    public func reset(str: String): Unit {
        var length = 0
        if (str.isSome()) {
            length = Int32(str.size)
        }
        reset(str, 0, length)
    }

    
    public func getScriptStart(): Int32 {
        return scriptStart
    }

    
    public func getScriptLimit(): Int32 {
        return scriptLimit
    }

    
    public func getScriptCode(): Int32 {
        return scriptCode
    }

    
    public func next(): Bool {
        if (scriptLimit >= textLimit) {
            return false
        }
        scriptCode = UScript.COMMON
        scriptStart = scriptLimit
        syncFixup()
        while (textIndex < textLimit) {
            let ch = UTF16.toRuneArray()[text, textStart, textLimit, textIndex - textStart]
            let codePointCount = UTF16.getCharCount(ch)
            var sc = UScript.getScript(ch)
            let pairIndex = getPairIndex(ch)
            textIndex += codePointCount
            if (pairIndex >= 0) {
                if ((pairIndex & 1) == 0) {
                    push(pairIndex, scriptCode)
                } else {
                    let pi = pairIndex & 
                    while (stackIsNotEmpty() && top().pairIndex != pi) {
                        pop()
                    }
                    if (stackIsNotEmpty()) {
                        sc = top().scriptCode
                    }
                }
            }
            if (sameScript(scriptCode, sc)) {
                if (scriptCode <= UScript.INHERITED && sc > UScript.INHERITED) {
                    scriptCode = sc
                    fixup(scriptCode)
                }
                if (pairIndex >= 0 && (pairIndex & 1) != 0) {
                    pop()
                }
            } else {
                textIndex -= codePointCount
                break
            }
        }
        scriptLimit = textIndex
        return true
    }

    private static func sameScript(scriptOne: Int32, scriptTwo: Int32): Bool {
        return scriptOne <= UScript.INHERITED || scriptTwo <= UScript.INHERITED || scriptOne == scriptTwo
    }

    private static func mod(sp: Int32): Int32 {
        return sp % PAREN_STACK_DEPTH
    }

    private static func inc(sp: Int32, count: Int32): Int32 {
        return mod(sp + count)
    }

    private static func inc(sp: Int32): Int32 {
        return inc(sp, 1)
    }

    private static func dec(sp: Int32, count: Int32): Int32 {
        return mod(sp + PAREN_STACK_DEPTH - count)
    }

    private static func dec(sp: Int32): Int32 {
        return dec(sp, 1)
    }

    private static func limitInc(count: Int32): Int32 {
        var tempcount = count
        if (tempcount < PAREN_STACK_DEPTH) {
            tempcount += 1
        }
        return tempcount
    }

    private func stackIsEmpty(): Bool {
        return pushCount <= 0
    }

    private func stackIsNotEmpty(): Bool {
        return !stackIsEmpty()
    }

    private func push(pairIndex: Int32, scrptCode: Int32): Unit {
        pushCount = limitInc(pushCount)
        fixupCount = limitInc(fixupCount)
        parenSP = inc(parenSP)
        parenStack[Int64(parenSP)] = UScriptRun_ParenStackEntry(pairIndex, scrptCode)
    }

    private func pop(): Unit {
        if (stackIsEmpty()) {
            return
        }
        parenStack[Int64(parenSP)] = None
        if (fixupCount > 0) {
            fixupCount -= 1
        }
        pushCount -= 1
        parenSP = dec(parenSP)
        if (stackIsEmpty()) {
            parenSP = -1
        }
    }

    private func top(): UScriptRun_ParenStackEntry {
        return parenStack[Int64(parenSP)]
    }

    private func syncFixup(): Unit {
        fixupCount = 0
    }

    private func fixup(scrptCode: Int32): Unit {
        var fixupSP = dec(parenSP, fixupCount)
        while (match (0) { case _ => fixupCount--; fixupCount + 1 } > 0) {
            fixupSP = inc(fixupSP)
            parenStack[Int64(fixupSP)].scriptCode = scrptCode
        }
    }

    private var emptyCharArray: Array<Char> = [0]

    private var text: Array<Char>

    private var textIndex: Int32 = 0

    private var textStart: Int32 = 0

    private var textLimit: Int32 = 0

    private var scriptStart: Int32 = 0

    private var scriptLimit: Int32 = 0

    private var scriptCode: Int32 = 0

    private static var PAREN_STACK_DEPTH = 32

    private static var parenStack: Array<UScriptRun_ParenStackEntry> = Array<UScriptRun_ParenStackEntry>(Int64(PAREN_STACK_DEPTH))

    private var parenSP = -1

    private var pushCount = 0

    private var fixupCount = 0

    private static func highBit(n: Int32): UInt8 {
        var tempn = n
        if (tempn <= 0) {
            return 224
        }
        var bit = 0u8
        if (tempn >= shl(1, 16)) {
            tempn >>= 16
            bit += 16
        }
        if (tempn >= shl(1, 8)) {
            tempn >>= 8
            bit += 8
        }
        if (tempn >= shl(1, 4)) {
            tempn >>= 4
            bit += 4
        }
        if (tempn >= shl(1, 2)) {
            tempn >>= 2
            bit += 2
        }
        if (tempn >= shl(1, 1)) {
            tempn >>= 1
            bit += 1
        }
        return bit
    }

    private static func getPairIndex(ch: Int32): Int32 {
        var probe = pairedCharPower
        var index = 0
        if (ch >= pairedChars[Int64(pairedCharExtra)]) {
            index = pairedCharExtra
        }
        while (probe > (shl(1, 0))) {
            probe >>= 1
            if (ch >= pairedChars[Int64(index + probe)]) {
                index += probe
            }
        }
        if (pairedChars[Int64(index)] != ch) {
            index = -1
        }
        return index
    }

    private static var pairedChars: Array<Int32> = [40, 41, 60, 62, 91, 93, 123, 125, 171, 187, 8216, 8217, 8220, 8221, 8249, 8250, 12296, 12297, 12298, 12299, 12300, 12301, 12302, 12303, 12304, 12305, 12308, 12309, 12310, 12311, 12312, 12313, 12314, 12315]

    private static var pairedCharPower = shl(1, Int32(highBit(Int32(pairedChars.size))))

    private static var pairedCharExtra = Int32(pairedChars.size) - pairedCharPower
}


class UScriptRun_ParenStackEntry {
    var pairIndex: Int32 = 0

    var scriptCode: Int32 = 0

    public init(thePairIndex: Int32, theScriptCode: Int32) {
        pairIndex = thePairIndex
        scriptCode = theScriptCode
    }
}
