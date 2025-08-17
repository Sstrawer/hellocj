package icu4cj.impl


public class CaseMapImpl {

    public static let TITLECASE_WHOLE_STRING = 32

    public static let TITLECASE_SENTENCES = 64

    private static let TITLECASE_ITERATOR_MASK = 224

    public static let TITLECASE_ADJUST_TO_CASED = 1024

    private static let TITLECASE_ADJUSTMENT_MASK = 1536

    public static func addTitleAdjustmentOption(options: Int32, newOption: Int32): Int32 {
        let adjOptions = options & TITLECASE_ADJUSTMENT_MASK
        if (adjOptions != 0 && adjOptions != newOption) {
            throw IllegalArgumentException("multiple titlecasing index adjustment options")
        }
        return options | newOption
    }

    private static let ACUTE = '\u{0301}'

    private static let U_GC_M_MASK = (shl(1, Int32(UCharacterCategory.NON_SPACING_MARK))) | (shl(1, Int32(UCharacterCategory.COMBINING_SPACING_MARK))) | (shl(1, Int32(UCharacterCategory.ENCLOSING_MARK)))

    private static let LNS = (shl(1, Int32(UCharacterCategory.UPPERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.LOWERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.TITLECASE_LETTER))) | (shl(1, Int32(UCharacterCategory.OTHER_LETTER))) | (shl(1, Int32(UCharacterCategory.DECIMAL_DIGIT_NUMBER))) | (shl(1, Int32(UCharacterCategory.LETTER_NUMBER))) | (shl(1, Int32(UCharacterCategory.OTHER_NUMBER))) | (shl(1, Int32(UCharacterCategory.MATH_SYMBOL))) | (shl(1, Int32(UCharacterCategory.CURRENCY_SYMBOL))) | (shl(1, Int32(UCharacterCategory.MODIFIER_SYMBOL))) | (shl(1, Int32(UCharacterCategory.OTHER_SYMBOL))) | (shl(1, Int32(UCharacterCategory.PRIVATE_USE)))

    private static func isLNS(c: Int32): Bool {
        let gc = UCharacterProperty.INSTANCE.getType(c)
        return ((shl(1, gc)) & LNS) != 0 || (gc == Int32(UCharacterCategory.MODIFIER_LETTER) && UCaseProps.INSTANCE.getType(c) != UCaseProps.NONE)
    }

    public static func addTitleIteratorOption(options: Int32, newOption: Int32): Int32 {
        let iterOptions = options & TITLECASE_ITERATOR_MASK
        if (iterOptions != 0 && iterOptions != newOption) {
            throw IllegalArgumentException("multiple titlecasing iterator options")
        }
        return options | newOption
    }

    public static func getTitleBreakIterator(locale: Locale, options: Int32, iter: BreakIterator): BreakIterator {
        var tempoptions = options
        var tempiter = iter
        tempoptions &= TITLECASE_ITERATOR_MASK
        if (tempoptions != 0 && tempiter.isSome()) {
            throw IllegalArgumentException("titlecasing iterator option together with an explicit iterator")
        }
        if (tempiter.isNone()) {
            match (tempoptions) {
                case 0 => tempiter = BreakIterator.getWordInstance(locale)
                case 32 => tempiter = CaseMapImpl_WholeStringBreakIterator()
                case 64 => tempiter = BreakIterator.getSentenceInstance(locale)
                case _ => throw IllegalArgumentException("unknown titlecasing iterator option")
            }
        }
        return tempiter
    }

    public static func getTitleBreakIterator(locale: ULocale, options: Int32, iter: BreakIterator): BreakIterator {
        var tempoptions = options
        var tempiter = iter
        tempoptions &= TITLECASE_ITERATOR_MASK
        if (tempoptions != 0 && tempiter.isSome()) {
            throw IllegalArgumentException("titlecasing iterator option together with an explicit iterator")
        }
        if (tempiter.isNone()) {
            match (tempoptions) {
                case 0 => tempiter = BreakIterator.getWordInstance(locale)
                case 32 => tempiter = CaseMapImpl_WholeStringBreakIterator()
                case 64 => tempiter = BreakIterator.getSentenceInstance(locale)
                case _ => throw IllegalArgumentException("unknown titlecasing iterator option")
            }
        }
        return tempiter
    }

    public static let OMIT_UNCHANGED_TEXT = 16384

    private static func appendCodePoint(a: Appendable, c: Int32): Int32 {
        if (c <= Int32(UInt32(Character.MAX_VALUE))) {
            a.append(Char(c))
            return 1
        } else {
            a.append(Char(55232 + (shr(c, 10))))
            a.append(Char(Int32(UInt32(Character.MIN_LOW_SURROGATE)) + (c & 1023)))
            return 2
        }
    }

    static func appendResult(result: Int32, dest: Appendable, cpLength: Int32, options: Int32, edits: Edits): Unit {
        if (result < 0) {
            if (edits.isSome()) {
                edits.addUnchanged(cpLength)
            }
            if ((options & OMIT_UNCHANGED_TEXT) != 0) {
                return
            }
            appendCodePoint(dest, )
        } else if (result <= UCaseProps.MAX_STRING_LENGTH) {
            if (edits.isSome()) {
                edits.addReplace(cpLength, result)
            }
        } else {
            let length = appendCodePoint(dest, result)
            if (edits.isSome()) {
                edits.addReplace(cpLength, length)
            }
        }
    }

    private static func appendUnchanged(src: String, start: Int32, length: Int32, dest: Appendable, options: Int32, edits: Edits): Unit {
        if (length > 0) {
            if (edits.isSome()) {
                edits.addUnchanged(length)
            }
            if ((options & OMIT_UNCHANGED_TEXT) != 0) {
                return
            }
            dest.append(src, start, start + length)
        }
    }

    private static func applyEdits(src: String, replacementChars: StringBuilder, edits: Edits): String {
        if (!edits.hasChanges()) {
            return toString(src)
        }
        let result = StringBuilder()
        let ei = edits.getCoarseIterator()
        while (ei.next()) {
            if (ei.hasChange()) {
                let i = ei.replacementIndex()
                result.append(replacementChars.asString(), i, i + ei.newLength())
            } else {
                let i = ei.sourceIndex()
                result.append(src, i, i + ei.oldLength())
            }
        }
        return result.toString()
    }

    private static let CASE_TRIE = UCaseProps.getTrie()

    private static func internalToLower(caseLocale: Int32, options: Int32, src: String, srcStart: Int32, srcLimit: Int32, iter: CaseMapImpl_StringContextIterator, dest: Appendable, edits: Edits): Unit {
        var tempiter = iter
        let latinToLower: Array<UInt8>
        if (caseLocale == UCaseProps.LOC_ROOT || (if (caseLocale >= 0) { !(caseLocale == UCaseProps.LOC_TURKISH || caseLocale == UCaseProps.LOC_LITHUANIAN) } else { (options & UCaseProps.FOLD_CASE_OPTIONS_MASK) == UCharacter.FOLD_CASE_DEFAULT })) {
            latinToLower = UCaseProps_LatinCase.TO_LOWER_NORMAL
        } else {
            latinToLower = UCaseProps_LatinCase.TO_LOWER_TR_LT
        }
        var prev = srcStart
        var srcIndex = srcStart
    private static func internalToUpper(caseLocale: Int32, options: Int32, src: String, dest: Appendable, edits: Edits): Unit {
        var iter: CaseMapImpl_StringContextIterator
        let latinToUpper: Array<UInt8>
        if (caseLocale == UCaseProps.LOC_TURKISH) {
            latinToUpper = UCaseProps_LatinCase.TO_UPPER_TR
        } else {
            latinToUpper = UCaseProps_LatinCase.TO_UPPER_NORMAL
        }
        var prev = 0
        var srcIndex = 0
        let srcLength = src.size
    public static func toLower(caseLocale: Int32, options: Int32, src: String): String {
        if (src.size <= 100 && (options & OMIT_UNCHANGED_TEXT) == 0) {
            if (src.size == 0) {
                return toString(src)
            }
            let edits = Edits()
            let replacementChars = toLower(caseLocale, options | OMIT_UNCHANGED_TEXT, src, StringBuilder() as A, edits)
            return applyEdits(src, replacementChars, edits)
        } else {
            return toLower(caseLocale, options, src, StringBuilder() as A, None).toString()
        }
    }

    public static func toLower<A>(caseLocale: Int32, options: Int32, src: String, dest: A, edits: Edits): A {
        try {
            if (edits.isSome()) {
                edits.reset()
            }
            internalToLower(caseLocale, options, src, 0, src.size, None, dest, edits)
            return dest
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public static func toUpper(caseLocale: Int32, options: Int32, src: String): String {
        if (src.size <= 100 && (options & OMIT_UNCHANGED_TEXT) == 0) {
            if (src.size == 0) {
                return toString(src)
            }
            let edits = Edits()
            let replacementChars = toUpper(caseLocale, options | OMIT_UNCHANGED_TEXT, src, StringBuilder() as A, edits)
            return applyEdits(src, replacementChars, edits)
        } else {
            return toUpper(caseLocale, options, src, StringBuilder() as A, None).toString()
        }
    }

    public static func toUpper<A>(caseLocale: Int32, options: Int32, src: String, dest: A, edits: Edits): A {
        try {
            if (edits.isSome()) {
                edits.reset()
            }
            if (caseLocale == UCaseProps.LOC_GREEK) {
                return CaseMapImpl_GreekUpper.toUpper(options, src, dest, edits)
            }
            internalToUpper(caseLocale, options, src, dest, edits)
            return dest
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public static func toTitle(caseLocale: Int32, options: Int32, iter: BreakIterator, src: String): String {
        if (src.size <= 100 && (options & OMIT_UNCHANGED_TEXT) == 0) {
            if (src.size == 0) {
                return toString(src)
            }
            let edits = Edits()
            let replacementChars = toTitle(caseLocale, options | OMIT_UNCHANGED_TEXT, iter, src, StringBuilder() as A, edits)
            return applyEdits(src, replacementChars, edits)
        } else {
            return toTitle(caseLocale, options, iter, src, StringBuilder() as A, None).toString()
        }
    }

    public static func toTitle<A>(caseLocale: Int32, options: Int32, titleIter: BreakIterator, src: String, dest: A, edits: Edits): A {
        try {
            if (edits.isSome()) {
                edits.reset()
            }
            let iter = CaseMapImpl_StringContextIterator(src)
            let srcLength = src.size
            var prev = 0
            var isFirstIndex = true
            while (prev < srcLength) {
                var index: Int32 = 0
                if (isFirstIndex) {
                    isFirstIndex = false
                    index = titleIter.first()
                } else {
                    index = titleIter.next()
                }
                if (index == BreakIterator.DONE || index > srcLength) {
                    index = srcLength
                }
                if (prev < index) {
                    var titleStart = prev
                    iter.setLimit(index)
                    var c = iter.nextCaseMapCP()
                    if ((options & UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT) == 0) {
                        let toCased = (options & CaseMapImpl.TITLECASE_ADJUST_TO_CASED) != 0
                        while ((if (toCased) { UCaseProps.NONE == UCaseProps.INSTANCE.getType(c) } else { !CaseMapImpl.isLNS(c) }) && (match (0) { case _ => c = iter.nextCaseMapCP(); c }) >= 0) { }
                        titleStart = iter.getCPStart()
                        if (prev < titleStart) {
                            appendUnchanged(src, prev, titleStart - prev, dest, options, edits)
                        }
                    }
                    if (titleStart < index) {
                        c = UCaseProps.INSTANCE.toFullTitle(c, iter, dest, caseLocale)
                        appendResult(c, dest, iter.getCPLength(), options, edits)
                        let titleLimit: Int32
                        if (titleStart + 1 < index && caseLocale == UCaseProps.LOC_DUTCH) {
                            if (c < 0) {
                                c = 
                            }
                            if (c == Int32(UInt32('I')) || c == Int32(UInt32('\u{00cd}'))) {
                                titleLimit = maybeTitleDutchIJ(src, c, titleStart + 1, index, dest, options, edits)
                                iter.moveTo(titleLimit)
                            } else {
                                titleLimit = iter.getCPLimit()
                            }
                        } else {
                            titleLimit = iter.getCPLimit()
                        }
                        if (titleLimit < index) {
                            if ((options & UCharacter.TITLECASE_NO_LOWERCASE) == 0) {
                                internalToLower(caseLocale, options, src, titleLimit, index, iter, dest, edits)
                            } else {
                                appendUnchanged(src, titleLimit, index - titleLimit, dest, options, edits)
                            }
                            iter.moveToLimit()
                        }
                    }
                }
                prev = index
            }
            return dest
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    private static func maybeTitleDutchIJ<A>(src: String, c: Int32, start: Int32, segmentLimit: Int32, dest: A, options: Int32, edits: Edits): Int32 {
        var tempstart = start
        if (!(tempstart < segmentLimit)) {
            throw AssertionError()
        }
        var index = tempstart
        var withAcute = false
        var unchanged1 = 0
        var doTitleJ = false
        var unchanged2 = 0
        var c2 = src[match (0] { case _ => index++; index - 1 })
        if (c == Int32(UInt32('I'))) {
            if (c2 == ACUTE) {
                withAcute = true
                unchanged1 = 1
                if (index == segmentLimit) {
                    return tempstart
                }
                c2 = src[match (0] { case _ => index++; index - 1 })
            }
        } else {
            withAcute = true
        }
        if (c2 == 'j') {
            doTitleJ = true
        } else if (c2 == 'J') {
            unchanged1++
        } else {
            return tempstart
        }
        if (withAcute) {
            if (index == segmentLimit || src[match (0] { case _ => index++; index - 1 }) != ACUTE) {
                return tempstart
            }
            if (doTitleJ) {
                unchanged2 = 1
            } else {
                unchanged1++
            }
        }
        if (index < segmentLimit) {
            let cp = Character.codePointAt(src, index)
            let bit = shl(1, UCharacter.getType(cp))
            if ((bit & U_GC_M_MASK) != 0) {
                return tempstart
            }
        }
        appendUnchanged(src, tempstart, unchanged1, dest, options, edits)
        tempstart += unchanged1
        if (doTitleJ) {
            dest.append('J')
            if (edits.isSome()) {
                edits.addReplace(1, 1)
            }
            tempstart++
        }
        appendUnchanged(src, tempstart, unchanged2, dest, options, edits)
        if (!(tempstart + unchanged2 == index)) {
            throw AssertionError()
        }
        return index
    }

    public static func fold(options: Int32, src: String): String {
        if (src.size <= 100 && (options & OMIT_UNCHANGED_TEXT) == 0) {
            if (src.size == 0) {
                return toString(src)
            }
            let edits = Edits()
            let replacementChars = fold(options | OMIT_UNCHANGED_TEXT, src, StringBuilder() as A, edits)
            return applyEdits(src, replacementChars, edits)
        } else {
            return fold(options, src, StringBuilder() as A, None).toString()
        }
    }

    public static func fold<A>(options: Int32, src: String, dest: A, edits: Edits): A {
        try {
            if (edits.isSome()) {
                edits.reset()
            }
            internalToLower(-1, options, src, 0, src.size, None, dest, edits)
            return dest
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }
}


public class CaseMapImpl_StringContextIterator <: UCaseProps_ContextIterator {
    public init(src: String) {
        this.s = src
        limit = src.size
        cpStart = match (0) { case _ => cpLimit = match (0) { case _ => index = 0; index }; cpLimit }
        dir = 0
    }

    public init(src: String, cpStart: Int32, cpLimit: Int32) {
        s = src
        index = 0
        limit = src.size
        this.cpStart = cpStart
        this.cpLimit = cpLimit
        dir = 0
    }

    public func setLimit(lim: Int32): Unit {
        if (0 <= lim && lim <= s.size) {
            limit = lim
        } else {
            limit = s.size
        }
    }

    public func moveToLimit(): Unit {
        cpStart = match (0) { case _ => cpLimit = limit; cpLimit }
    }

    public func moveTo(i: Int32): Unit {
        cpStart = match (0) { case _ => cpLimit = i; cpLimit }
    }

    public func nextCaseMapCP(): Int32 {
        cpStart = cpLimit
        if (cpLimit < limit) {
            let c = Character.codePointAt(s, cpLimit)
            cpLimit += Character.charCount(c)
            return c
        } else {
            return -1
        }
    }

    public func setCPStartAndLimit(s: Int32, l: Int32): Unit {
        cpStart = s
        cpLimit = l
        dir = 0
    }

    public func getCPStart(): Int32 {
        return cpStart
    }

    public func getCPLimit(): Int32 {
        return cpLimit
    }

    public func getCPLength(): Int32 {
        return cpLimit - cpStart
    }

    public override func reset(direction: Int32): Unit {
        if (direction > 0) {
            dir = 1
            index = cpLimit
        } else if (direction < 0) {
            dir = -1
            index = cpStart
        } else {
            dir = 0
            index = 0
        }
    }

    public override func next(): Int32 {
        let c: Int32
        if (dir > 0 && index < s.size) {
            c = Character.codePointAt(s, index)
            index += Character.charCount(c)
            return c
        } else if (dir < 0 && index > 0) {
            c = Character.codePointBefore(s, index)
            index -= Character.charCount(c)
            return c
        }
        return -1
    }

    protected var s: String

    protected var index: Int32 = 0

    protected var limit: Int32 = 0

    protected var cpStart: Int32 = 0

    protected var cpLimit: Int32 = 0

    protected var dir: Int32 = 0
}


class CaseMapImpl_WholeStringBreakIterator <: BreakIterator {
    init() {
        super()
    }

    private var length: Int32 = 0

    private static func notImplemented(): Unit {
        throw UnsupportedOperationException("should not occur")
    }

    public override func first(): Int32 {
        return 0
    }

    public override func last(): Int32 {
        notImplemented()
        return 0
    }

    public override func next(n: Int32): Int32 {
        notImplemented()
        return 0
    }

    public override func next(): Int32 {
        return length
    }

    public override func previous(): Int32 {
        notImplemented()
        return 0
    }

    public override func following(offset: Int32): Int32 {
        notImplemented()
        return 0
    }

    public override func current(): Int32 {
        notImplemented()
        return 0
    }

    public override func getText(): CharacterIterator {
        notImplemented()
        return None
    }

    public override func setText(newText: CharacterIterator): Unit {
        length = newText.getEndIndex()
    }

    public override func setText(newText: String): Unit {
        length = newText.size
    }

    public override func setText(newText: String): Unit {
        length = Int32(newText.size)
    }
}


class CaseMapImpl_GreekUpper {

    private static let UPPER_MASK = 1023

    private static let HAS_VOWEL = 4096

    private static let HAS_YPOGEGRAMMENI = 8192

    private static let HAS_ACCENT = 16384

    private static let HAS_DIALYTIKA = 32768

    private static let HAS_COMBINING_DIALYTIKA = 65536

    private static let HAS_OTHER_GREEK_DIACRITIC = 131072

    private static let HAS_VOWEL_AND_ACCENT = HAS_VOWEL | HAS_ACCENT

    private static let HAS_VOWEL_AND_ACCENT_AND_DIALYTIKA = HAS_VOWEL_AND_ACCENT | HAS_DIALYTIKA

    private static let HAS_EITHER_DIALYTIKA = HAS_DIALYTIKA | HAS_COMBINING_DIALYTIKA

    private static let AFTER_CASED = 1

    private static let AFTER_VOWEL_WITH_COMBINING_ACCENT = 2

    private static let AFTER_VOWEL_WITH_PRECOMPOSED_ACCENT = 4

    private static let data0370: Array<Char> = [Char(880), Char(880), Char(882), Char(882), Char(0), Char(0), Char(886), Char(886), Char(0), Char(0), Char(890), Char(1021), Char(1022), Char(1023), Char(0), Char(895), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(913 | HAS_VOWEL), Char(914), Char(915), Char(916), Char(917 | HAS_VOWEL), Char(918), Char(919 | HAS_VOWEL), Char(920), Char(921 | HAS_VOWEL), Char(922), Char(923), Char(924), Char(925), Char(926), Char(927 | HAS_VOWEL), Char(928), Char(929), Char(0), Char(931), Char(932), Char(933 | HAS_VOWEL), Char(934), Char(935), Char(936), Char(937 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_DIALYTIKA), Char(933 | HAS_VOWEL | HAS_DIALYTIKA), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(913 | HAS_VOWEL), Char(914), Char(915), Char(916), Char(917 | HAS_VOWEL), Char(918), Char(919 | HAS_VOWEL), Char(920), Char(921 | HAS_VOWEL), Char(922), Char(923), Char(924), Char(925), Char(926), Char(927 | HAS_VOWEL), Char(928), Char(929), Char(931), Char(931), Char(932), Char(933 | HAS_VOWEL), Char(934), Char(935), Char(936), Char(937 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_DIALYTIKA), Char(933 | HAS_VOWEL | HAS_DIALYTIKA), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(975), Char(914), Char(920), Char(978), Char(978 | HAS_ACCENT), Char(978 | HAS_DIALYTIKA), Char(934), Char(928), Char(975), Char(984), Char(984), Char(986), Char(986), Char(988), Char(988), Char(990), Char(990), Char(992), Char(992), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(0), Char(922), Char(929), Char(1017), Char(895), Char(1012), Char(917 | HAS_VOWEL), Char(0), Char(1015), Char(1015), Char(1017), Char(1018), Char(1018), Char(1020), Char(1021), Char(1022), Char(1023)]

    private static let data1F00: Array<Char> = [Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL), Char(917 | HAS_VOWEL), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(917 | HAS_VOWEL), Char(917 | HAS_VOWEL), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(919 | HAS_VOWEL), Char(919 | HAS_VOWEL), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL), Char(919 | HAS_VOWEL), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL), Char(927 | HAS_VOWEL), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(927 | HAS_VOWEL), Char(927 | HAS_VOWEL), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(933 | HAS_VOWEL), Char(0), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL), Char(937 | HAS_VOWEL), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL), Char(937 | HAS_VOWEL), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(0), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_ACCENT), Char(913 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(0), Char(921 | HAS_VOWEL), Char(0), Char(0), Char(0), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(0), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(917 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_ACCENT), Char(919 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(0), Char(0), Char(0), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(921 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(0), Char(0), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(921 | HAS_VOWEL | HAS_ACCENT), Char(0), Char(0), Char(0), Char(0), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(933 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(929), Char(929), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT | HAS_DIALYTIKA), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(933 | HAS_VOWEL | HAS_ACCENT), Char(929), Char(0), Char(0), Char(0), Char(0), Char(0), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(0), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(927 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_ACCENT), Char(937 | HAS_VOWEL | HAS_YPOGEGRAMMENI), Char(0), Char(0), Char(0)]

    private static let data2126 = Char(937 | HAS_VOWEL)

    private static func getLetterData(c: Int32): Int32 {
        if (c < 880 || 8486 < c || (1023 < c && c < 7936)) {
            return 0
        } else if (c <= 1023) {
            return Int32(UInt32(data0370[Int64(c - 880)]))
        } else if (c <= 8191) {
            return Int32(UInt32(data1F00[Int64(c - 7936)]))
        } else if (c == 8486) {
            return Int32(UInt32(data2126))
        } else {
            return 0
        }
    }

    private static func getDiacriticData(c: Int32): Int32 {
        <-- Internal error: switch (c) {
        case '\u{0300}':

        case '\u{0301}':

        case '\u{0342}':

        case '\u{0302}':

        case '\u{0303}':

        case '\u{0311}':
            return HAS_ACCENT;

        case '\u{0308}':
            return HAS_COMBINING_DIALYTIKA;

        case '\u{0344}':
            return HAS_COMBINING_DIALYTIKA | HAS_ACCENT;

        case '\u{0345}':
            return HAS_YPOGEGRAMMENI;

        case '\u{0304}':

        case '\u{0306}':

        case '\u{0313}':

        case '\u{0314}':

        case '\u{0343}':
            return HAS_OTHER_GREEK_DIACRITIC;

        default:
            return 0;

        } -->
    }

    private static func isFollowedByCasedLetter(s: String, i: Int32): Bool {
        var tempi = i
        while (tempi < s.size) {
            let c = Character.codePointAt(s, tempi)
            let Type = UCaseProps.INSTANCE.getTypeOrIgnorable(c)
            if ((Type & UCaseProps.IGNORABLE) != 0) {
                tempi += Character.charCount(c)
            } else if (Type != UCaseProps.NONE) {
                return true
            } else {
                return false
            }
        }
        return false
    }

    static func toUpper<A>(options: Int32, src: String, dest: A, edits: Edits): A {
        var state = 0
        var i = 0
        while (i < src.size) {
            var c = Character.codePointAt(src, i)
            var nextIndex = i + Character.charCount(c)
            var nextState = 0
            let Type = UCaseProps.INSTANCE.getTypeOrIgnorable(c)
            if ((Type & UCaseProps.IGNORABLE) != 0) {
                nextState |= (state & AFTER_CASED)
            } else if (Type != UCaseProps.NONE) {
                nextState |= AFTER_CASED
            }
            var data = getLetterData(c)
            if (data > 0) {
                var upper = data & UPPER_MASK
                if ((data & HAS_VOWEL) != 0 && (state & (AFTER_VOWEL_WITH_PRECOMPOSED_ACCENT | AFTER_VOWEL_WITH_COMBINING_ACCENT)) != 0 && (upper == Int32(UInt32('\u{0399}')) || upper == Int32(UInt32('\u{03a5}')))) {
                    data |= if ((state & AFTER_VOWEL_WITH_PRECOMPOSED_ACCENT) != 0) { HAS_DIALYTIKA } else { HAS_COMBINING_DIALYTIKA }
                }
                var numYpogegrammeni = 0
                if ((data & HAS_YPOGEGRAMMENI) != 0) {
                    numYpogegrammeni = 1
                }
                let hasPrecomposedAccent = (data & HAS_ACCENT) != 0
                while (nextIndex < src.size) {
                    let diacriticData = getDiacriticData(Int32(UInt32(src[nextIndex])))
                    if (diacriticData != 0) {
                        data |= diacriticData
                        if ((diacriticData & HAS_YPOGEGRAMMENI) != 0) {
                            numYpogegrammeni++
                        }
                        nextIndex++
                    } else {
                        break
                    }
                }
                if ((data & HAS_VOWEL_AND_ACCENT_AND_DIALYTIKA) == HAS_VOWEL_AND_ACCENT) {
                    nextState |= if (hasPrecomposedAccent) { AFTER_VOWEL_WITH_PRECOMPOSED_ACCENT } else { AFTER_VOWEL_WITH_COMBINING_ACCENT }
                }
                var addTonos = false
                if (upper == Int32(UInt32('\u{0397}')) && (data & HAS_ACCENT) != 0 && numYpogegrammeni == 0 && (state & AFTER_CASED) == 0 && !isFollowedByCasedLetter(src, nextIndex)) {
                    if (hasPrecomposedAccent) {
                        upper = Int32(UInt32('\u{0389}'))
                    } else {
                        addTonos = true
                    }
                } else if ((data & HAS_DIALYTIKA) != 0) {
                    if (upper == Int32(UInt32('\u{0399}'))) {
                        upper = Int32(UInt32('\u{03aa}'))
                        data &= 
                    } else if (upper == Int32(UInt32('\u{03a5}'))) {
                        upper = Int32(UInt32('\u{03ab}'))
                        data &= 
                    }
                }
                var change: Bool = false
                if (edits.isNone() && (options & CaseMapImpl.OMIT_UNCHANGED_TEXT) == 0) {
                    change = true
                } else {
                    change = Int32(UInt32(src[i])) != upper || numYpogegrammeni > 0
                    var i2 = i + 1
                    if ((data & HAS_EITHER_DIALYTIKA) != 0) {
                        change |= i2 >= nextIndex || Int32(UInt32(src[i2])) != 776
                        i2++
                    }
                    if (addTonos) {
                        change |= i2 >= nextIndex || Int32(UInt32(src[i2])) != 769
                        i2++
                    }
                    let oldLength = nextIndex - i
                    let newLength = (i2 - i) + numYpogegrammeni
                    change |= oldLength != newLength
                    if (change) {
                        if (edits.isSome()) {
                            edits.addReplace(oldLength, newLength)
                        }
                    } else {
                        if (edits.isSome()) {
                            edits.addUnchanged(oldLength)
                        }
                        change = (options & CaseMapImpl.OMIT_UNCHANGED_TEXT) == 0
                    }
                }
                if (change) {
                    dest.append(Char(upper))
                    if ((data & HAS_EITHER_DIALYTIKA) != 0) {
                        dest.append('\u{0308}')
                    }
                    if (addTonos) {
                        dest.append('\u{0301}')
                    }
                    while (numYpogegrammeni > 0) {
                        dest.append('\u{0399}')
                        numYpogegrammeni--
                    }
                }
            } else {
                c = UCaseProps.INSTANCE.toFullUpper(c, None, dest, UCaseProps.LOC_GREEK)
                CaseMapImpl.appendResult(c, dest, nextIndex - i, options, edits)
            }
            i = nextIndex
            state = nextState
        }
        return dest
    }
}
