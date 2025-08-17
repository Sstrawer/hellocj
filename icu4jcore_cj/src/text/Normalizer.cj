package icu4cj.text


public class Normalizer <: Cloneable {
    private var text: UCharacterIterator

    private var norm2: Normalizer2

    private var mode: Normalizer_Mode

    private var options: Int32 = 0

    private var currentIndex: Int32 = 0

    private var nextIndex: Int32 = 0

    private var buffer: StringBuilder

    private var bufferPos: Int32 = 0

    
    public static let UNICODE_3_2 = 32

    
    public static let DONE = UCharacterIterator.DONE

    
    public static let NONE: Normalizer_Mode = Normalizer_NONEMode()

    
    public static let NFD: Normalizer_Mode = Normalizer_NFDMode()

    
    public static let NFKD: Normalizer_Mode = Normalizer_NFKDMode()

    
    public static let NFC: Normalizer_Mode = Normalizer_NFCMode()

    
    public static let DEFAULT = NFC

    
    public static let NFKC: Normalizer_Mode = Normalizer_NFKCMode()

    
    public static let FCD: Normalizer_Mode = Normalizer_FCDMode()

    
    public static let NO_OP = NONE

    
    public static let COMPOSE = NFC

    
    public static let COMPOSE_COMPAT = NFKC

    
    public static let DECOMP = NFD

    
    public static let DECOMP_COMPAT = NFKD

    
    public static let IGNORE_HANGUL = 1

    public static let NO = Normalizer_QuickCheckResult(0)

    public static let YES = Normalizer_QuickCheckResult(1)

    public static let MAYBE = Normalizer_QuickCheckResult(2)

    public static let FOLD_CASE_DEFAULT = UCharacter.FOLD_CASE_DEFAULT

    public static let INPUT_IS_FCD = 131072

    public static let COMPARE_IGNORE_CASE = 65536

    public static let COMPARE_CODE_POINT_ORDER = 32768

    public static let FOLD_CASE_EXCLUDE_SPECIAL_I = UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I

    
    public static let COMPARE_NORM_OPTIONS_SHIFT = 20

    
    public init(str: String, mode: Normalizer_Mode, opt: Int32) {
        this.text = UCharacterIterator.getInstance(str)
        this.mode = mode
        this.options = opt
        norm2 = mode.getNormalizer2(opt)
        buffer = StringBuilder()
    }

    
    public init(iter: CharacterIterator, mode: Normalizer_Mode, opt: Int32) {
        this.text = UCharacterIterator.getInstance(iter.clone())
        this.mode = mode
        this.options = opt
        norm2 = mode.getNormalizer2(opt)
        buffer = StringBuilder()
    }

    
    public init(iter: UCharacterIterator, mode: Normalizer_Mode, options: Int32) {
        try {
            this.text = iter.clone()
            this.mode = mode
            this.options = options
            norm2 = mode.getNormalizer2(options)
            buffer = StringBuilder()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    
    public override func clone(): Object {
        try {
            let copy = super.toString()
            copy.text = text.clone()
            copy.mode = mode
            copy.options = options
            copy.norm2 = norm2
            copy.buffer = StringBuilder(buffer.asString())
            copy.bufferPos = bufferPos
            copy.currentIndex = currentIndex
            copy.nextIndex = nextIndex
            return copy
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    private static func getComposeNormalizer2(compat: Bool, options: Int32): Normalizer2 {
        return (if (compat) { NFKC } else { NFC }).getNormalizer2(options)
    }

    private static func getDecomposeNormalizer2(compat: Bool, options: Int32): Normalizer2 {
        return (if (compat) { NFKD } else { NFD }).getNormalizer2(options)
    }

    
    public static func compose(str: String, compat: Bool): String {
        return compose(str, compat, 0)
    }

    
    public static func compose(str: String, compat: Bool, options: Int32): String {
        return getComposeNormalizer2(compat, options).normalize(str)
    }

    
    public static func compose(source: Array<Char>, target: Array<Char>, compat: Bool, options: Int32): Int32 {
        return compose(source, 0, Int32(source.size), target, 0, Int32(target.size), compat, options)
    }

    
    public static func compose(src: Array<Char>, srcStart: Int32, srcLimit: Int32, dest: Array<Char>, destStart: Int32, destLimit: Int32, compat: Bool, options: Int32): Int32 {
        let srcBuffer = CharBuffer.wrap(src, srcStart, srcLimit - srcStart)
        let app = Normalizer_CharsAppendable(dest, destStart, destLimit)
        getComposeNormalizer2(compat, options).normalize(srcBuffer, app)
        return app.size
    }

    
    public static func decompose(str: String, compat: Bool): String {
        return decompose(str, compat, 0)
    }

    
    public static func decompose(str: String, compat: Bool, options: Int32): String {
        return getDecomposeNormalizer2(compat, options).normalize(str)
    }

    
    public static func decompose(source: Array<Char>, target: Array<Char>, compat: Bool, options: Int32): Int32 {
        return decompose(source, 0, Int32(source.size), target, 0, Int32(target.size), compat, options)
    }

    
    public static func decompose(src: Array<Char>, srcStart: Int32, srcLimit: Int32, dest: Array<Char>, destStart: Int32, destLimit: Int32, compat: Bool, options: Int32): Int32 {
        let srcBuffer = CharBuffer.wrap(src, srcStart, srcLimit - srcStart)
        let app = Normalizer_CharsAppendable(dest, destStart, destLimit)
        getDecomposeNormalizer2(compat, options).normalize(srcBuffer, app)
        return app.size
    }

    
    public static func normalize(str: String, mode: Normalizer_Mode, options: Int32): String {
        return mode.getNormalizer2(options).normalize(str)
    }

    
    public static func normalize(src: String, mode: Normalizer_Mode): String {
        return normalize(src, mode, 0)
    }

    
    public static func normalize(source: Array<Char>, target: Array<Char>, mode: Normalizer_Mode, options: Int32): Int32 {
        return normalize(source, 0, Int32(source.size), target, 0, Int32(target.size), mode, options)
    }

    
    public static func normalize(src: Array<Char>, srcStart: Int32, srcLimit: Int32, dest: Array<Char>, destStart: Int32, destLimit: Int32, mode: Normalizer_Mode, options: Int32): Int32 {
        let srcBuffer = CharBuffer.wrap(src, srcStart, srcLimit - srcStart)
        let app = Normalizer_CharsAppendable(dest, destStart, destLimit)
        mode.getNormalizer2(options).normalize(srcBuffer, app)
        return app.size
    }

    
    public static func normalize(char32: Int32, mode: Normalizer_Mode, options: Int32): String {
        if (refEq(mode, NFD) && options == 0) {
            var decomposition = Normalizer2.getNFCInstance().getDecomposition(char32)
            if (decomposition.isNone()) {
                decomposition = UTF16.valueOf(char32)
            }
            return decomposition
        }
        return normalize(UTF16.valueOf(char32), mode, options)
    }

    
    public static func normalize(char32: Int32, mode: Normalizer_Mode): String {
        return normalize(char32, mode, 0)
    }

    
    public static func quickCheck(source: String, mode: Normalizer_Mode): Normalizer_QuickCheckResult {
        return quickCheck(source, mode, 0)
    }

    
    public static func quickCheck(source: String, mode: Normalizer_Mode, options: Int32): Normalizer_QuickCheckResult {
        return mode.getNormalizer2(options).quickCheck(source)
    }

    
    public static func quickCheck(source: Array<Char>, mode: Normalizer_Mode, options: Int32): Normalizer_QuickCheckResult {
        return quickCheck(source, 0, Int32(source.size), mode, options)
    }

    
    public static func quickCheck(source: Array<Char>, start: Int32, limit: Int32, mode: Normalizer_Mode, options: Int32): Normalizer_QuickCheckResult {
        let srcBuffer = CharBuffer.wrap(source, start, limit - start)
        return mode.getNormalizer2(options).quickCheck(srcBuffer)
    }

    
    public static func isNormalized(src: Array<Char>, start: Int32, limit: Int32, mode: Normalizer_Mode, options: Int32): Bool {
        let srcBuffer = CharBuffer.wrap(src, start, limit - start)
        return mode.getNormalizer2(options).isNormalized(srcBuffer)
    }

    
    public static func isNormalized(str: String, mode: Normalizer_Mode, options: Int32): Bool {
        return mode.getNormalizer2(options).isNormalized(str)
    }

    
    public static func isNormalized(char32: Int32, mode: Normalizer_Mode, options: Int32): Bool {
        return isNormalized(UTF16.valueOf(char32), mode, options)
    }

    public static func compare(s1: Array<Char>, s1Start: Int32, s1imit: Int32, s2: Array<Char>, s2Start: Int32, s2imit: Int32, options: Int32): Int32 {
        if (s1.isNone() || s1Start < 0 || s1imit < 0 || s2.isNone() || s2Start < 0 || s2imit < 0 || s1imit < s1Start || s2imit < s2Start) {
            throw IllegalArgumentException()
        }
        return internalCompare(CharBuffer.wrap(s1, s1Start, s1imit - s1Start), CharBuffer.wrap(s2, s2Start, s2imit - s2Start), options)
    }

    public static func compare(s1: String, s2: String, options: Int32): Int32 {
        return internalCompare(s1, s2, options)
    }

    public static func compare(s1: Array<Char>, s2: Array<Char>, options: Int32): Int32 {
        return internalCompare(CharBuffer.wrap(s1), CharBuffer.wrap(s2), options)
    }

    public static func compare(char32a: Int32, char32b: Int32, options: Int32): Int32 {
        return internalCompare(UTF16.valueOf(char32a), UTF16.valueOf(char32b), options | INPUT_IS_FCD)
    }

    public static func compare(char32a: Int32, str2: String, options: Int32): Int32 {
        return internalCompare(UTF16.valueOf(char32a), str2, options)
    }

    
    public static func concatenate(left: Array<Char>, leftStart: Int32, leftLimit: Int32, right: Array<Char>, rightStart: Int32, rightLimit: Int32, dest: Array<Char>, destStart: Int32, destLimit: Int32, mode: Normalizer_Mode, options: Int32): Int32 {
        if (dest.isNone()) {
            throw IllegalArgumentException()
        }
        if (refEq(right, dest) && rightStart < destLimit && destStart < rightLimit) {
            throw IllegalArgumentException("overlapping right and dst ranges")
        }
        let destBuilder = StringBuilder()
        destBuilder.append(left, leftStart, leftLimit - leftStart)
        let rightBuffer = CharBuffer.wrap(right, rightStart, rightLimit - rightStart)
        mode.getNormalizer2(options).append(destBuilder, rightBuffer)
        let destLength = Int32(destBuilder.size)
        if (destLength <= (destLimit - destStart)) {
            destBuilder.getChars(0, destLength, dest, destStart)
            return destLength
        } else {
            throw IndexOutOfBoundsException(destLength.toString())
        }
    }

    
    public static func concatenate(left: Array<Char>, right: Array<Char>, mode: Normalizer_Mode, options: Int32): String {
        let dest: StringBuilder = StringBuilder().append(left)
        return mode.getNormalizer2(options).append(dest, CharBuffer.wrap(right)).toString()
    }

    
    public static func concatenate(left: String, right: String, mode: Normalizer_Mode, options: Int32): String {
        let dest: StringBuilder = StringBuilder().append(left)
        return mode.getNormalizer2(options).append(dest, right).toString()
    }

    
    public static func getFC_NFKC_Closure(c: Int32, dest: Array<Char>): Int32 {
        let closure = getFC_NFKC_Closure(c)
        let length = Int32(closure.size)
        if (length != 0 && dest.isSome() && length <= Int32(dest.size)) {
            closure.toRuneArray().copyTo(dest, 0, 0, Int64(length - 0))
        }
        return length
    }

    
    public static func getFC_NFKC_Closure(c: Int32): String {
        let nfkc = Normalizer_NFKCModeImpl.INSTANCE.normalizer2
        let csp = UCaseProps.INSTANCE
        let folded = StringBuilder()
        let folded1ength = csp.toFullFolding(c, folded as Appendable, 0)
        if (folded1ength < 0) {
            let nfkcImpl = nfkc.impl
            if (nfkcImpl.getCompQuickCheck(nfkcImpl.getNorm16(c)) != 0) {
                return ""
            }
            folded.appendCodePoint(c)
        } else {
            if (folded1ength > UCaseProps.MAX_STRING_LENGTH) {
                folded.appendCodePoint(folded1ength)
            }
        }
        let kc1 = nfkc.normalize(folded.toString())
        let kc2 = nfkc.normalize(UCharacter.foldCase(kc1, 0))
        if (kc1.equals(kc2)) {
            return ""
        } else {
            return kc2
        }
    }

    
    public func current(): Int32 {
        if (bufferPos < Int32(buffer.size) || nextNormalize()) {
            return buffer.codePointAt(bufferPos)
        } else {
            return DONE
        }
    }

    
    public func next(): Int32 {
        if (bufferPos < Int32(buffer.size) || nextNormalize()) {
            let c = buffer.codePointAt(bufferPos)
            bufferPos += Character.charCount(c)
            return c
        } else {
            return DONE
        }
    }

    
    public func previous(): Int32 {
        if (bufferPos > 0 || previousNormalize()) {
            let c = buffer.codePointBefore(bufferPos)
            bufferPos -= Character.charCount(c)
            return c
        } else {
            return DONE
        }
    }

    
    public func reset(): Unit {
        text.setToStart()
        currentIndex = match (0) { case _ => nextIndex = 0; nextIndex }
        clearBuffer()
    }

    
    public func setIndexOnly(index: Int32): Unit {
        text.setIndex(index)
        currentIndex = match (0) { case _ => nextIndex = index; nextIndex }
        clearBuffer()
    }

    
    public func setIndex(index: Int32): Int32 {
        setIndexOnly(index)
        return current()
    }

    
    public func getBeginIndex(): Int32 {
        return 0
    }

    
    public func getEndIndex(): Int32 {
        return endIndex()
    }

    
    public func first(): Int32 {
        reset()
        return next()
    }

    
    public func last(): Int32 {
        text.setToLimit()
        currentIndex = match (0) { case _ => nextIndex = text.getIndex(); nextIndex }
        clearBuffer()
        return previous()
    }

    
    public func getIndex(): Int32 {
        if (bufferPos < Int32(buffer.size)) {
            return currentIndex
        } else {
            return nextIndex
        }
    }

    
    public func startIndex(): Int32 {
        return 0
    }

    
    public func endIndex(): Int32 {
        return text.getLength()
    }

    
    public func setMode(newMode: Normalizer_Mode): Unit {
        mode = newMode
        norm2 = mode.getNormalizer2(options)
    }

    
    public func getMode(): Normalizer_Mode {
        return mode
    }

    
    public func setOption(option: Int32, value: Bool): Unit {
        if (value) {
            options |= option
        } else {
            options &= ()
        }
        norm2 = mode.getNormalizer2(options)
    }

    
    public func getOption(option: Int32): Int32 {
        if ((options & option) != 0) {
            return 1
        } else {
            return 0
        }
    }

    
    public func getText(fillIn: Array<Char>): Int32 {
        return text.getText(fillIn)
    }

    
    public func getLength(): Int32 {
        return text.getLength()
    }

    
    public func getText(): String {
        return text.getText()
    }

    
    public func setText(newText: StringBuffer): Unit {
        let newIter = UCharacterIterator.getInstance(newText)
        if (newIter.isNone()) {
            throw Exception("Could not create a new UCharacterIterator")
        }
        text = newIter
        reset()
    }

    
    public func setText(newText: Array<Char>): Unit {
        let newIter = UCharacterIterator.getInstance(newText)
        if (newIter.isNone()) {
            throw Exception("Could not create a new UCharacterIterator")
        }
        text = newIter
        reset()
    }

    
    public func setText(newText: String): Unit {
        let newIter = UCharacterIterator.getInstance(newText)
        if (newIter.isNone()) {
            throw Exception("Could not create a new UCharacterIterator")
        }
        text = newIter
        reset()
    }

    
    public func setText(newText: CharacterIterator): Unit {
        let newIter = UCharacterIterator.getInstance(newText)
        if (newIter.isNone()) {
            throw Exception("Could not create a new UCharacterIterator")
        }
        text = newIter
        reset()
    }

    
    public func setText(newText: UCharacterIterator): Unit {
        try {
            let newIter = newText.clone()
            if (newIter.isNone()) {
                throw Exception("Could not create a new UCharacterIterator")
            }
            text = newIter
            reset()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException("Could not clone the UCharacterIterator", e as Exception)
        }
    }

    private func clearBuffer(): Unit {
        buffer.setLength(0)
        bufferPos = 0
    }

    private func nextNormalize(): Bool {
        clearBuffer()
        currentIndex = nextIndex
        text.setIndex(nextIndex)
        var c = text.nextCodePoint()
        if (c < 0) {
            return false
        }
        let segment = StringBuilder().appendCodePoint(c)
        while ((match (0) { case _ => c = text.nextCodePoint(); c }) >= 0) {
            if (norm2.hasBoundaryBefore(c)) {
                text.moveCodePointIndex(-1)
                break
            }
            segment.appendCodePoint(c)
        }
        nextIndex = text.getIndex()
        norm2.normalize(segment.asString(), buffer)
        return Int32(buffer.size) != 0
    }

    private func previousNormalize(): Bool {
        clearBuffer()
        nextIndex = currentIndex
        text.setIndex(currentIndex)
        let segment = StringBuilder()
        var c: Int32 = 0
        while ((match (0) { case _ => c = text.previousCodePoint(); c }) >= 0) {
            if (c <= 65535) {
                segment.insert(0, Char(c))
            } else {
                segment.insert(0, Character.toChars(c).asString())
            }
            if (norm2.hasBoundaryBefore(c)) {
                break
            }
        }
        currentIndex = text.getIndex()
        norm2.normalize(segment.toString(), buffer)
        bufferPos = Int32(buffer.size)
        return Int32(buffer.size) != 0
    }

    private static func internalCompare(s1: String, s2: String, options: Int32): Int32 {
        var tempoptions = options
        var temps1 = s1
        var temps2 = s2
        let normOptions = ushr(tempoptions, COMPARE_NORM_OPTIONS_SHIFT)
        tempoptions |= COMPARE_EQUIV
        if ((tempoptions & INPUT_IS_FCD) == 0 || (tempoptions & FOLD_CASE_EXCLUDE_SPECIAL_I) != 0) {
            let n2: Normalizer2
            if ((tempoptions & FOLD_CASE_EXCLUDE_SPECIAL_I) != 0) {
                n2 = NFD.getNormalizer2(normOptions)
            } else {
                n2 = FCD.getNormalizer2(normOptions)
            }
            let spanQCYes1 = n2.spanQuickCheckYes(temps1)
            let spanQCYes2 = n2.spanQuickCheckYes(temps2)
            if (spanQCYes1 < temps1.size) {
                let fcd1 = StringBuilder().append(temps1, 0, spanQCYes1)
                temps1 = n2.normalizeSecondAndAppend(fcd1, temps1.subSequence(spanQCYes1, temps1.size)).asString()
            }
            if (spanQCYes2 < temps2.size) {
                let fcd2 = StringBuilder().append(temps2, 0, spanQCYes2)
                temps2 = n2.normalizeSecondAndAppend(fcd2, temps2.subSequence(spanQCYes2, temps2.size)).asString()
            }
        }
        return cmpEquivFold(temps1, temps2, tempoptions)
    }

    private static func createCmpEquivLevelStack(): Array<Normalizer_CmpEquivLevel> {
        return [Normalizer_CmpEquivLevel(), Normalizer_CmpEquivLevel()]
    }

    private static let COMPARE_EQUIV = 524288

    static func cmpEquivFold(cs1: String, cs2: String, options: Int32): Int32 {
        var tempcs1 = cs1
        var tempcs2 = cs2
        let nfcImpl: Normalizer2Impl
        let csp: UCaseProps
        var s1: Int32 = 0
        var s2: Int32 = 0
        var limit1: Int32 = 0
        var limit2: Int32 = 0
        var length: Int32 = 0
        var stack1: Array<Normalizer_CmpEquivLevel>
        var stack2: Array<Normalizer_CmpEquivLevel>
        var decomp1: String
        var decomp2: String
        let fold1: StringBuilder
        let fold2: StringBuilder
        var level1: Int32 = 0
        var level2: Int32 = 0
        var c1: Int32 = 0
        var c2: Int32 = 0
        var cp1: Int32 = 0
        var cp2: Int32 = 0
        if ((options & COMPARE_EQUIV) != 0) {
            nfcImpl = Norm2AllModes.getNFCInstance().impl
        } else {
            nfcImpl = None
        }
        if ((options & COMPARE_IGNORE_CASE) != 0) {
            csp = UCaseProps.INSTANCE
            fold1 = StringBuilder()
            fold2 = StringBuilder()
        } else {
            csp = None
            fold1 = match (0) { case _ => fold2 = None; fold2 }
        }
        s1 = 0
        limit1 = tempcs1.size
        s2 = 0
        limit2 = tempcs2.size
        level1 = match (0) { case _ => level2 = 0; level2 }
        c1 = match (0) { case _ => c2 = -1; c2 }
        while (true) {
            if (c1 < 0) {
                while (true) {
                    if (s1 == limit1) {
                        if (level1 == 0) {
                            c1 = -1
                            break
                        }
                    } else {
                        c1 = Int32(UInt32(tempcs1[match (0] { case _ => s1++; s1 - 1 })))
                        break
                    }
                    s1 = stack1[Int64(level1)].s
                    limit1 = tempcs1.size
                }
            }
            if (c2 < 0) {
                while (true) {
                    if (s2 == limit2) {
                        if (level2 == 0) {
                            c2 = -1
                            break
                        }
                    } else {
                        c2 = Int32(UInt32(tempcs2[match (0] { case _ => s2++; s2 - 1 })))
                        break
                    }
                    s2 = stack2[Int64(level2)].s
                    limit2 = tempcs2.size
                }
            }
            if (c1 == c2) {
                if (c1 < 0) {
                    return 0
                }
                c1 = match (0) { case _ => c2 = -1; c2 }
                continue
            } else if (c1 < 0) {
                return -1
            } else if (c2 < 0) {
                return 1
            }
            cp1 = c1
            if (UTF16.isSurrogate(c1)) {
                let c: Char
                if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c1)) {
                    if (s1 != limit1 && Character.isLowSurrogate(match (0) { case _ => c = tempcs1[s1]; c })) {
                        cp1 = Character.toCodePoint(Char(c1), c)
                    }
                } else {
                    if (0 <= (s1 - 2) && Character.isHighSurrogate(match (0) { case _ => c = tempcs1[s1 - 2]; c })) {
                        cp1 = Character.toCodePoint(c, Char(c1))
                    }
                }
            }
            cp2 = c2
            if (UTF16.isSurrogate(c2)) {
                let c: Char
                if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c2)) {
                    if (s2 != limit2 && Character.isLowSurrogate(match (0) { case _ => c = tempcs2[s2]; c })) {
                        cp2 = Character.toCodePoint(Char(c2), c)
                    }
                } else {
                    if (0 <= (s2 - 2) && Character.isHighSurrogate(match (0) { case _ => c = tempcs2[s2 - 2]; c })) {
                        cp2 = Character.toCodePoint(c, Char(c2))
                    }
                }
            }
            if (level1 == 0 && (options & COMPARE_IGNORE_CASE) != 0 && (match (0) { case _ => length = csp.toFullFolding(cp1, fold1, options); length }) >= 0) {
                if (UTF16.isSurrogate(c1)) {
                    if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c1)) {
                        s1++
                    } else {
                        s2--
                        c2 = Int32(UInt32(tempcs2[s2 - 1]))
                    }
                }
                if (stack1.isNone()) {
                    stack1 = createCmpEquivLevelStack()
                }
                stack1[0].cs = tempcs1
                stack1[0].s = s1
                level1++
                if (length <= UCaseProps.MAX_STRING_LENGTH) {
                    fold1.delete(0, Int32(fold1.size) - length)
                } else {
                    fold1.setLength(0)
                    fold1.appendCodePoint(length)
                }
                tempcs1 = fold1.asString()
                s1 = 0
                limit1 = Int32(fold1.size)
                c1 = -1
                continue
            }
            if (level2 == 0 && (options & COMPARE_IGNORE_CASE) != 0 && (match (0) { case _ => length = csp.toFullFolding(cp2, fold2, options); length }) >= 0) {
                if (UTF16.isSurrogate(c2)) {
                    if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c2)) {
                        s2++
                    } else {
                        s1--
                        c1 = Int32(UInt32(tempcs1[s1 - 1]))
                    }
                }
                if (stack2.isNone()) {
                    stack2 = createCmpEquivLevelStack()
                }
                stack2[0].cs = tempcs2
                stack2[0].s = s2
                level2++
                if (length <= UCaseProps.MAX_STRING_LENGTH) {
                    fold2.delete(0, Int32(fold2.size) - length)
                } else {
                    fold2.setLength(0)
                    fold2.appendCodePoint(length)
                }
                tempcs2 = fold2.asString()
                s2 = 0
                limit2 = Int32(fold2.size)
                c2 = -1
                continue
            }
            if (level1 < 2 && (options & COMPARE_EQUIV) != 0 && (match (0) { case _ => decomp1 = nfcImpl.getDecomposition(cp1); decomp1 }).isSome()) {
                if (UTF16.isSurrogate(c1)) {
                    if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c1)) {
                        s1++
                    } else {
                        s2--
                        c2 = Int32(UInt32(tempcs2[s2 - 1]))
                    }
                }
                if (stack1.isNone()) {
                    stack1 = createCmpEquivLevelStack()
                }
                stack1[Int64(level1)].cs = tempcs1
                stack1[Int64(level1)].s = s1
                level1++
                if (level1 < 2) {
                    stack1[Int64(match (0) { case _ => level1++; level1 - 1 })].cs = None
                }
                tempcs1 = decomp1
                s1 = 0
                limit1 = Int32(decomp1.size)
                c1 = -1
                continue
            }
            if (level2 < 2 && (options & COMPARE_EQUIV) != 0 && (match (0) { case _ => decomp2 = nfcImpl.getDecomposition(cp2); decomp2 }).isSome()) {
                if (UTF16.isSurrogate(c2)) {
                    if (Normalizer2Impl_UTF16Plus.isSurrogateLead(c2)) {
                        s2++
                    } else {
                        s1--
                        c1 = Int32(UInt32(tempcs1[s1 - 1]))
                    }
                }
                if (stack2.isNone()) {
                    stack2 = createCmpEquivLevelStack()
                }
                stack2[Int64(level2)].cs = tempcs2
                stack2[Int64(level2)].s = s2
                level2++
                if (level2 < 2) {
                    stack2[Int64(match (0) { case _ => level2++; level2 - 1 })].cs = None
                }
                tempcs2 = decomp2
                s2 = 0
                limit2 = Int32(decomp2.size)
                c2 = -1
                continue
            }
            if (c1 >= 55296 && c2 >= 55296 && (options & COMPARE_CODE_POINT_ORDER) != 0) {
                if ((c1 <= 56319 && s1 != limit1 && Character.isLowSurrogate(tempcs1[s1])) || (Character.isLowSurrogate(Char(c1)) && 0 != (s1 - 1) && Character.isHighSurrogate(tempcs1[s1 - 2]))) { } else {
                    c1 -= 10240
                }
                if ((c2 <= 56319 && s2 != limit2 && Character.isLowSurrogate(tempcs2[s2])) || (Character.isLowSurrogate(Char(c2)) && 0 != (s2 - 1) && Character.isHighSurrogate(tempcs2[s2 - 2]))) { } else {
                    c2 -= 10240
                }
            }
            return c1 - c2
        }
    }
}


class Normalizer_ModeImpl {
    init(n2: Normalizer2) {
        normalizer2 = n2
    }

    let normalizer2: Normalizer2
}


class Normalizer_NFDModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(Normalizer2.getNFDInstance())
}


class Normalizer_NFKDModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(Normalizer2.getNFKDInstance())
}


class Normalizer_NFCModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(Normalizer2.getNFCInstance())
}


class Normalizer_NFKCModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(Normalizer2.getNFKCInstance())
}


class Normalizer_FCDModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(Norm2AllModes.getFCDNormalizer2())
}


class Normalizer_Unicode32 {

    static let INSTANCE = UnicodeSet("[:age=3.2:]").freeze()
}


class Normalizer_NFD32ModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(FilteredNormalizer2(Normalizer2.getNFDInstance(), Normalizer_Unicode32.INSTANCE))
}


class Normalizer_NFKD32ModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(FilteredNormalizer2(Normalizer2.getNFKDInstance(), Normalizer_Unicode32.INSTANCE))
}


class Normalizer_NFC32ModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(FilteredNormalizer2(Normalizer2.getNFCInstance(), Normalizer_Unicode32.INSTANCE))
}


class Normalizer_NFKC32ModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(FilteredNormalizer2(Normalizer2.getNFKCInstance(), Normalizer_Unicode32.INSTANCE))
}


class Normalizer_FCD32ModeImpl {

    static let INSTANCE = Normalizer_ModeImpl(FilteredNormalizer2(Norm2AllModes.getFCDNormalizer2(), Normalizer_Unicode32.INSTANCE))
}



public abstract class Normalizer_Mode {
    

    
    protected func getNormalizer2(options: Int32): Normalizer2
}


class Normalizer_NONEMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return Norm2AllModes.NOOP_NORMALIZER2
    }
}


class Normalizer_NFDMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return if ((options & Normalizer.UNICODE_3_2) != 0) { Normalizer_NFD32ModeImpl.INSTANCE.normalizer2 } else { Normalizer_NFDModeImpl.INSTANCE.normalizer2 }
    }
}


class Normalizer_NFKDMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return if ((options & Normalizer.UNICODE_3_2) != 0) { Normalizer_NFKD32ModeImpl.INSTANCE.normalizer2 } else { Normalizer_NFKDModeImpl.INSTANCE.normalizer2 }
    }
}


class Normalizer_NFCMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return if ((options & Normalizer.UNICODE_3_2) != 0) { Normalizer_NFC32ModeImpl.INSTANCE.normalizer2 } else { Normalizer_NFCModeImpl.INSTANCE.normalizer2 }
    }
}


class Normalizer_NFKCMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return if ((options & Normalizer.UNICODE_3_2) != 0) { Normalizer_NFKC32ModeImpl.INSTANCE.normalizer2 } else { Normalizer_NFKCModeImpl.INSTANCE.normalizer2 }
    }
}


class Normalizer_FCDMode <: Normalizer_Mode {
    init() {
        super()
    }

    override protected func getNormalizer2(options: Int32): Normalizer2 {
        return if ((options & Normalizer.UNICODE_3_2) != 0) { Normalizer_FCD32ModeImpl.INSTANCE.normalizer2 } else { Normalizer_FCDModeImpl.INSTANCE.normalizer2 }
    }
}


public class Normalizer_QuickCheckResult {
    init(value: Int32) { }
}


class Normalizer_CmpEquivLevel {

    var cs: String

    var s: Int32 = 0
}


class Normalizer_CharsAppendable <: Appendable {
    public init(dest: Array<Char>, destStart: Int32, destLimit: Int32) {
        chars = dest
        start = match (0) { case _ => offset = destStart; offset }
        limit = destLimit
    }

    public func length(): Int32 {
        let len = offset - start
        if (offset <= limit) {
            return len
        } else {
            throw IndexOutOfBoundsException(len.toString())
        }
    }

    public override func append(c: Char): Appendable {
        if (offset < limit) {
            chars[Int64(offset)] = c
        }
        offset++
        return this
    }

    public override func append(s: String): Appendable {
        return append(s, 0, s.size)
    }

    public override func append(s: String, sStart: Int32, sLimit: Int32): Appendable {
        var tempsStart = sStart
        let len = sLimit - tempsStart
        if (len <= (limit - offset)) {
            while (tempsStart < sLimit) {
                chars[Int64(match (0) { case _ => offset++; offset - 1 })] = s[match (0] { case _ => tempsStart++; tempsStart - 1 })
            }
        } else {
            offset += len
        }
        return this
    }

    private let chars: Array<Char>

    private let start: Int32

    private let limit: Int32

    private var offset: Int32 = 0
}
