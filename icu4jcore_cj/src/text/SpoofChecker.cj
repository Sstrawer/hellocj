package icu4cj.text


public class SpoofChecker {
    public static let INCLUSION = UnicodeSet().applyIntPropertyValue(UProperty.IDENTIFIER_TYPE, UCharacter_IdentifierType.INCLUSION.ordinal).freeze()

    public static let RECOMMENDED = UnicodeSet().applyIntPropertyValue(UProperty.IDENTIFIER_TYPE, UCharacter_IdentifierType.RECOMMENDED.ordinal).freeze()

    public static let SINGLE_SCRIPT_CONFUSABLE = 1

    public static let MIXED_SCRIPT_CONFUSABLE = 2

    public static let WHOLE_SCRIPT_CONFUSABLE = 4

    public static let CONFUSABLE = SINGLE_SCRIPT_CONFUSABLE | MIXED_SCRIPT_CONFUSABLE | WHOLE_SCRIPT_CONFUSABLE

    
    public static let ANY_CASE = 8

    public static let RESTRICTION_LEVEL = 16

    
    public static let SINGLE_SCRIPT = RESTRICTION_LEVEL

    public static let INVISIBLE = 32

    public static let CHAR_LIMIT = 64

    public static let MIXED_NUMBERS = 128

    public static let HIDDEN_OVERLAY = 256

    public static let ALL_CHECKS = -1

    static let ASCII = UnicodeSet(0, 127).freeze()

    init() { }

    
    public func getRestrictionLevel(): SpoofChecker_RestrictionLevel {
        return fRestrictionLevel
    }

    public func getChecks(): Int32 {
        return fChecks
    }

    public func getAllowedLocales(): Set<ULocale> {
        return Collections.unmodifiableSet(fAllowedLocales)
    }

    public func getAllowedJavaLocales(): Set<Locale> {
        let locales = HashSet<Locale>(fAllowedLocales.size)
        for (uloc in fAllowedLocales) {
            locales.put(uloc.toLocale())
        }
        return locales as Set<Locale>
    }

    public func getAllowedChars(): UnicodeSet {
        return fAllowedCharsSet
    }

    public func failsChecks(text: String, checkResult: SpoofChecker_CheckResult): Bool {
        let length = Int32(text.size)
        var result = 0
        if (checkResult.isSome()) {
            checkResult.position = 0
            checkResult.numerics = None
            checkResult.restrictionLevel = None
        }
        if (0 != (this.fChecks & RESTRICTION_LEVEL)) {
            let textRestrictionLevel = getRestrictionLevel(text)
            if (textRestrictionLevel.append(fRestrictionLevel.asString()) > 0) {
                result |= RESTRICTION_LEVEL
            }
            if (checkResult.isSome()) {
                checkResult.restrictionLevel = textRestrictionLevel
            }
        }
        if (0 != (this.fChecks & MIXED_NUMBERS)) {
            let numerics = UnicodeSet()
            getNumerics(text, numerics)
            if (numerics.size() > 1) {
                result |= MIXED_NUMBERS
            }
            if (checkResult.isSome()) {
                checkResult.numerics = numerics
            }
        }
        if (0 != (this.fChecks & HIDDEN_OVERLAY)) {
            let index = findHiddenOverlay(text)
            if (index != -1) {
                result |= HIDDEN_OVERLAY
            }
        }
        if (0 != (this.fChecks & CHAR_LIMIT)) {
            var i: Int32 = 0
            var c: Int32 = 0
            i = 0
            while (i < length) {
                c = Character.codePointAt(text, i)
                i = Character.offsetByCodePoints(text, i, 1)
                if (!this.fAllowedCharsSet.contains(c)) {
                    result |= CHAR_LIMIT
                    break
                }
            }
        }
        if (0 != (this.fChecks & INVISIBLE)) {
            let nfdText = nfdNormalizer.normalize(text)
            var i: Int32 = 0
            var c: Int32 = 0
            var firstNonspacingMark = 0
            var haveMultipleMarks = false
            let marksSeenSoFar = UnicodeSet()
            i = 0
            while (i < length) {
                c = Character.codePointAt(nfdText, i)
                i = Character.offsetByCodePoints(nfdText, i, 1)
                if (Character.getType(c) != Int32(UCharacterCategory.NON_SPACING_MARK)) {
                    firstNonspacingMark = 0
                    if (haveMultipleMarks) {
                        marksSeenSoFar.clear()
                        haveMultipleMarks = false
                    }
                    continue
                }
                if (firstNonspacingMark == 0) {
                    firstNonspacingMark = c
                    continue
                }
                if (!haveMultipleMarks) {
                    marksSeenSoFar.add(firstNonspacingMark)
                    haveMultipleMarks = true
                }
                if (marksSeenSoFar.contains(c)) {
                    result |= INVISIBLE
                    break
                }
                marksSeenSoFar.add(c)
            }
        }
        if (checkResult.isSome()) {
            checkResult.checks = result
        }
        return (0 != result)
    }

    public func failsChecks(text: String): Bool {
        return failsChecks(text, None)
    }

    public func areConfusable(s1: String, s2: String): Int32 {
        if ((this.fChecks & CONFUSABLE) == 0) {
            throw IllegalArgumentException("No confusable checks are enabled.")
        }
        let s1Skeleton = getSkeleton(s1)
        let s2Skeleton = getSkeleton(s2)
        if (!s1Skeleton.equals(s2Skeleton)) {
            return 0
        }
        let s1RSS = SpoofChecker_ScriptSet()
        getResolvedScriptSet(s1, s1RSS)
        let s2RSS = SpoofChecker_ScriptSet()
        getResolvedScriptSet(s2, s2RSS)
        var result = 0
        if (s1RSS.intersects(s2RSS)) {
            result |= SINGLE_SCRIPT_CONFUSABLE
        } else {
            result |= MIXED_SCRIPT_CONFUSABLE
            if (!s1RSS.isEmpty() && !s2RSS.isEmpty()) {
                result |= WHOLE_SCRIPT_CONFUSABLE
            }
        }
        return result & fChecks
    }

    public func areConfusable(direction: Int32, s1: String, s2: String): Int32 {
        if ((this.fChecks & CONFUSABLE) == 0) {
            throw IllegalArgumentException("No confusable checks are enabled.")
        }
        let s1Skeleton = getBidiSkeleton(direction, s1)
        let s2Skeleton = getBidiSkeleton(direction, s2)
        if (!s1Skeleton.equals(s2Skeleton)) {
            return 0
        }
        let s1RSS = SpoofChecker_ScriptSet()
        getResolvedScriptSet(s1, s1RSS)
        let s2RSS = SpoofChecker_ScriptSet()
        getResolvedScriptSet(s2, s2RSS)
        var result = 0
        if (s1RSS.intersects(s2RSS)) {
            result |= SINGLE_SCRIPT_CONFUSABLE
        } else {
            result |= MIXED_SCRIPT_CONFUSABLE
            if (!s1RSS.isEmpty() && !s2RSS.isEmpty()) {
                result |= WHOLE_SCRIPT_CONFUSABLE
            }
        }
        result &= fChecks
        return result
    }

    public func getBidiSkeleton(direction: Int32, str: String): String {
        if (direction != Bidi.DIRECTION_LEFT_TO_RIGHT && direction != Bidi.DIRECTION_RIGHT_TO_LEFT) {
            throw IllegalArgumentException("direction should be DIRECTION_LEFT_TO_RIGHT or DIRECTION_RIGHT_TO_LEFT")
        }
        let bidi = Bidi(toString(str), direction)
        return getSkeleton(bidi.writeReordered(Bidi.KEEP_BASE_COMBINING | Bidi.DO_MIRRORING))
    }

    public func getSkeleton(str: String): String {
        let nfdId = nfdNormalizer.normalize(str)
        let normalizedLen = Int32(nfdId.size)
        let skelSB = StringBuilder()
        var inputIndex = 0
        while (inputIndex < normalizedLen) {
            let c = Character.codePointAt(nfdId, inputIndex)
            inputIndex += Character.charCount(c)
            if (!UCharacter.hasBinaryProperty(c, UProperty.DEFAULT_IGNORABLE_CODE_POINT)) {
                this.fSpoofData.confusableLookup(c, skelSB)
            }
        }
        var skelStr: String = skelSB.toString()
        skelStr = nfdNormalizer.normalize(skelStr)
        return skelStr
    }

    
    public func getSkeleton(Type: Int32, id: String): String {
        return getSkeleton(id)
    }

    public override func equals(other: Object): Bool {
        if (!(checkOptionalIs<SpoofChecker, Object>(other))) {
            return false
        }
        let otherSC = other
        if (!refEq(fSpoofData, otherSC.fSpoofData) && fSpoofData.isSome() && !fSpoofData.equals(otherSC.fSpoofData)) {
            return false
        }
        if (fChecks != otherSC.fChecks) {
            return false
        }
        if (fAllowedLocales != otherSC.fAllowedLocales && fAllowedLocales.isSome() && !// Мapping is present but failed: refEq(fAllowedLocales, otherSC.fAllowedLocales)) {
            return false
        }
        if (!refEq(fAllowedCharsSet, otherSC.fAllowedCharsSet) && fAllowedCharsSet.isSome() && !fAllowedCharsSet.equals(otherSC.fAllowedCharsSet)) {
            return false
        }
        if (!refEq(fRestrictionLevel, otherSC.fRestrictionLevel)) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        return Int64(fChecks ^ Int32(fSpoofData.hashCode()) ^ Int32(fAllowedLocales.hashCode()) ^ Int32(fAllowedCharsSet.hashCode()) ^ fRestrictionLevel.ordinal)
    }

    private static func getAugmentedScriptSet(codePoint: Int32, result: SpoofChecker_ScriptSet): Unit {
        result.clear()
        UScript.getScriptExtensions(codePoint, result)
        if (result.get(UScript.HAN)) {
            result.set(UScript.HAN_WITH_BOPOMOFO)
            result.set(UScript.JAPANESE)
            result.set(UScript.KOREAN)
        }
        if (result.get(UScript.HIRAGANA)) {
            result.set(UScript.JAPANESE)
        }
        if (result.get(UScript.KATAKANA)) {
            result.set(UScript.JAPANESE)
        }
        if (result.get(UScript.HANGUL)) {
            result.set(UScript.KOREAN)
        }
        if (result.get(UScript.BOPOMOFO)) {
            result.set(UScript.HAN_WITH_BOPOMOFO)
        }
        if (result.get(UScript.COMMON) || result.get(UScript.INHERITED)) {
            result.setAll()
        }
    }

    private func getResolvedScriptSet(input: String, result: SpoofChecker_ScriptSet): Unit {
        getResolvedScriptSetWithout(input, UScript.CODE_LIMIT, result)
    }

    private func getResolvedScriptSetWithout(input: String, script: Int32, result: SpoofChecker_ScriptSet): Unit {
        result.setAll()
        let temp = SpoofChecker_ScriptSet()
        var utf16Offset = 0
        while (utf16Offset < input.size) {
            let codePoint = Character.codePointAt(input, utf16Offset)
            utf16Offset += Character.charCount(codePoint)
            getAugmentedScriptSet(codePoint, temp)
            if (script == UScript.CODE_LIMIT || !temp.get(script)) {
                result.and(temp)
            }
        }
    }

    private func getNumerics(input: String, result: UnicodeSet): Unit {
        result.clear()
        var utf16Offset = 0
        while (utf16Offset < Int32(input.size)) {
            let codePoint = Character.codePointAt(input, utf16Offset)
            utf16Offset += Character.charCount(codePoint)
            if (UCharacter.getType(codePoint) == Int32(UCharacterCategory.DECIMAL_DIGIT_NUMBER)) {
                result.add(codePoint - UCharacter.getNumericValue(codePoint))
            }
        }
    }

    private func getRestrictionLevel(input: String): SpoofChecker_RestrictionLevel {
        if (!fAllowedCharsSet.containsAll(input)) {
            return SpoofChecker_RestrictionLevel.UNRESTRICTIVE
        }
        if (ASCII.containsAll(input)) {
            return SpoofChecker_RestrictionLevel.ASCII
        }
        let resolvedScriptSet = SpoofChecker_ScriptSet()
        getResolvedScriptSet(input, resolvedScriptSet)
        if (!resolvedScriptSet.isEmpty()) {
            return SpoofChecker_RestrictionLevel.SINGLE_SCRIPT_RESTRICTIVE
        }
        let resolvedNoLatn = SpoofChecker_ScriptSet()
        getResolvedScriptSetWithout(input, UScript.LATIN, resolvedNoLatn)
        if (resolvedNoLatn.get(UScript.HAN_WITH_BOPOMOFO) || resolvedNoLatn.get(UScript.JAPANESE) || resolvedNoLatn.get(UScript.KOREAN)) {
            return SpoofChecker_RestrictionLevel.HIGHLY_RESTRICTIVE
        }
        if (!resolvedNoLatn.isEmpty() && !resolvedNoLatn.get(UScript.CYRILLIC) && !resolvedNoLatn.get(UScript.GREEK) && !resolvedNoLatn.get(UScript.CHEROKEE)) {
            return SpoofChecker_RestrictionLevel.MODERATELY_RESTRICTIVE
        }
        return SpoofChecker_RestrictionLevel.MINIMALLY_RESTRICTIVE
    }

    public func findHiddenOverlay(input: String): Int32 {
        var sawLeadCharacter = false
        let sb = StringBuilder()
        var i = 0
        while (i < Int32(input.size)) {
            let cp = input.codePointAt(i)
            if (sawLeadCharacter && cp == 775) {
                return i
            }
            let combiningClass = UCharacter.getCombiningClass(cp)
            if (!(UCharacter.getCombiningClass(775) == 230)) {
                throw AssertionError()
            }
            if (combiningClass == 0 || combiningClass == 230) {
                sawLeadCharacter = isIllegalCombiningDotLeadCharacter(cp, sb)
            }
            i += UCharacter.charCount(cp)
        }
        return -1
    }

    public func isIllegalCombiningDotLeadCharacterNoLookup(cp: Int32): Bool {
        return cp == Int32(UInt32('i')) || cp == Int32(UInt32('j')) || cp == Int32(UInt32('\u{0131}')) || cp == Int32(UInt32('\u{0237}')) || cp == Int32(UInt32('l')) || UCharacter.hasBinaryProperty(cp, UProperty.SOFT_DOTTED)
    }

    public func isIllegalCombiningDotLeadCharacter(cp: Int32, sb: StringBuilder): Bool {
        if (isIllegalCombiningDotLeadCharacterNoLookup(cp)) {
            return true
        }
        sb.setLength(0)
        fSpoofData.confusableLookup(cp, sb)
        let finalCp = UCharacter.codePointBefore(sb.asString(), Int32(sb.size))
        if (finalCp != cp && isIllegalCombiningDotLeadCharacterNoLookup(finalCp)) {
            return true
        }
        return false
    }

    var fChecks: Int32 = 0

    var fSpoofData: SpoofChecker_SpoofData

    var fAllowedLocales: Set<ULocale>

    var fAllowedCharsSet: UnicodeSet

    var fRestrictionLevel: SpoofChecker_RestrictionLevel

    private static var nfdNormalizer = Normalizer2.getNFDInstance()
}


public class SpoofChecker_RestrictionLevel <: Enum<SpoofChecker_RestrictionLevel> {
    public static let ASCII = SpoofChecker_RestrictionLevel("ASCII", 0)

    public static let SINGLE_SCRIPT_RESTRICTIVE = SpoofChecker_RestrictionLevel("SINGLE_SCRIPT_RESTRICTIVE", 1)

    public static let HIGHLY_RESTRICTIVE = SpoofChecker_RestrictionLevel("HIGHLY_RESTRICTIVE", 2)

    public static let MODERATELY_RESTRICTIVE = SpoofChecker_RestrictionLevel("MODERATELY_RESTRICTIVE", 3)

    public static let MINIMALLY_RESTRICTIVE = SpoofChecker_RestrictionLevel("MINIMALLY_RESTRICTIVE", 4)

    public static let UNRESTRICTIVE = SpoofChecker_RestrictionLevel("UNRESTRICTIVE", 5)

    private static func _values(): Array<SpoofChecker_RestrictionLevel> {
        return [SpoofChecker_RestrictionLevel.ASCII, SpoofChecker_RestrictionLevel.SINGLE_SCRIPT_RESTRICTIVE, SpoofChecker_RestrictionLevel.HIGHLY_RESTRICTIVE, SpoofChecker_RestrictionLevel.MODERATELY_RESTRICTIVE, SpoofChecker_RestrictionLevel.MINIMALLY_RESTRICTIVE, SpoofChecker_RestrictionLevel.UNRESTRICTIVE]
    }

    private static let _VALUES = SpoofChecker_RestrictionLevel._values()

    public static func values(): Array<SpoofChecker_RestrictionLevel> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): SpoofChecker_RestrictionLevel {
        return (TypeInfo.of<SpoofChecker_RestrictionLevel>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as SpoofChecker_RestrictionLevel
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class SpoofChecker_Builder {
    var fChecks: Int32 = 0

    var fSpoofData: SpoofChecker_SpoofData

    let fAllowedCharsSet = UnicodeSet(0, 1114111)

    let fAllowedLocales = LinkedHashSet()

    private var fRestrictionLevel: SpoofChecker_RestrictionLevel

    public init() {
        fChecks = SpoofChecker.ALL_CHECKS
        fSpoofData = None
        fRestrictionLevel = SpoofChecker_RestrictionLevel.HIGHLY_RESTRICTIVE
    }

    public init(src: SpoofChecker) {
        fChecks = src.fChecks
        fSpoofData = src.fSpoofData
        fAllowedCharsSet.set(src.fAllowedCharsSet)
        fAllowedLocales.putAll(src.fAllowedLocales)
        fRestrictionLevel = src.fRestrictionLevel
    }

    public func build(): SpoofChecker {
        if (fSpoofData.isNone()) {
            fSpoofData = SpoofChecker_SpoofData.getDefault()
        }
        let result = SpoofChecker()
        result.fChecks = this.fChecks
        result.fSpoofData = this.fSpoofData
        result.fAllowedCharsSet = this.fAllowedCharsSet.clone()
        result.fAllowedCharsSet.freeze()
        result.fAllowedLocales = HashSet<ULocale>(this.fAllowedLocales)
        result.fRestrictionLevel = this.fRestrictionLevel
        return result
    }

    public func setData(confusables: StringReader<InputStream>): SpoofChecker_Builder {
        fSpoofData = SpoofChecker_SpoofData()
        SpoofChecker_Builder_ConfusabledataBuilder.buildConfusableData(confusables, fSpoofData)
        return this
    }

    
    public func setData(confusables: StringReader<InputStream>, confusablesWholeScript: StringReader<InputStream>): SpoofChecker_Builder {
        setData(confusables)
        return this
    }

    public func setChecks(checks: Int32): SpoofChecker_Builder {
        if (0 != (checks & )) {
            throw IllegalArgumentException("Bad Spoof Checks value.")
        }
        this.fChecks = (checks & SpoofChecker.ALL_CHECKS)
        return this
    }

    public func setAllowedLocales(locales: Set<ULocale>): SpoofChecker_Builder {
        fAllowedCharsSet.clear()
        for (locale in locales) {
            addScriptChars(locale, fAllowedCharsSet)
        }
        fAllowedLocales.clear()
        if (Int32(locales.size) == 0) {
            fAllowedCharsSet.add(0, 1114111)
            fChecks &= 
            return this
        }
        let tempSet = UnicodeSet()
        tempSet.applyIntPropertyValue(UProperty.SCRIPT, UScript.COMMON)
        fAllowedCharsSet.addAll(tempSet)
        tempSet.applyIntPropertyValue(UProperty.SCRIPT, UScript.INHERITED)
        fAllowedCharsSet.addAll(tempSet)
        fAllowedLocales.clear()
        fAllowedLocales.putAll(locales)
        fChecks |= SpoofChecker.CHAR_LIMIT
        return this
    }

    public func setAllowedJavaLocales(locales: Set<Locale>): SpoofChecker_Builder {
        let ulocales = HashSet<ULocale>(Int64(locales.size()))
        for (locale in locales) {
            ulocales.put(ULocale.forLocale(locale))
        }
        return setAllowedLocales(ulocales)
    }

    private func addScriptChars(locale: ULocale, allowedChars: UnicodeSet): Unit {
        let scripts = UScript.getCode(locale)
        if (scripts.isSome()) {
            let tmpSet = UnicodeSet()
            var i = 0
            while (i < Int32(scripts.size)) {
                tmpSet.applyIntPropertyValue(UProperty.SCRIPT, scripts[Int64(i)])
                allowedChars.addAll(tmpSet)
                i++
            }
        }
    }

    public func setAllowedChars(chars: UnicodeSet): SpoofChecker_Builder {
        fAllowedCharsSet.set(chars)
        fAllowedLocales.clear()
        fChecks |= SpoofChecker.CHAR_LIMIT
        return this
    }

    public func setRestrictionLevel(restrictionLevel: SpoofChecker_RestrictionLevel): SpoofChecker_Builder {
        fRestrictionLevel = restrictionLevel
        fChecks |= SpoofChecker.RESTRICTION_LEVEL | SpoofChecker.MIXED_NUMBERS
        return this
    }
}


class SpoofChecker_Builder_ConfusabledataBuilder {
    private var fTable: Hashtable = None

    private var fKeySet: UnicodeSet

    private var fStringTable: StringBuffer = None

    private var fKeyVec: ArrayList<Int32>

    private var fValueVec: ArrayList<Int32>

    private var stringPool: SpoofChecker_Builder_ConfusabledataBuilder_SPUStringPool

    private var fParseLine: Pattern = None

    private var fParseHexNum: Pattern = None

    private var fLineNum: Int32 = 0

    init() {
        fTable = Hashtable()
        fKeySet = UnicodeSet()
        fKeyVec = ArrayList<Int32>()
        fValueVec = ArrayList<Int32>()
        stringPool = SpoofChecker_Builder_ConfusabledataBuilder_SPUStringPool()
    }

    public func build(confusables: StringReader<InputStream>, dest: SpoofChecker_SpoofData): Unit {
        let fInput = StringBuffer()
        let lnr = LineNumberReader(confusables)
            fInput.append(line)
            fInput.append('\n')
        } while (true)
        fParseLine = Pattern.compile("(m)^[ \\t]*([0-9A-Fa-f]+)[ \\t]+;[ \\t]*([0-9A-Fa-f]+(:[ \\t]+[0-9A-Fa-f]+)*)[ \\t]*;\\s*(:(SL)|(SA)|(ML)|(MA))[ \\t]*(:#.*)$|^([ \\t]*(:#.*))$|^(.*)$")
        fParseHexNum = Pattern.compile("\\s*([0-9A-F]+)")
        if (Int32(UInt32(fInput.get(0))) == 65279) {
            fInput.insert(0, Char(32))
        }
        let matcher = fParseLine.matcher(fInput)
        while (matcher.find()) {
            fLineNum++
            if (matcher.start(7) >= 0) {
                continue
            }
            if (matcher.start(8) >= 0) {
                throw ParseException("Confusables, line " + fLineNum.toString() + ": Unrecognized Line: " + (matcher.group(8)), matcher.start(8))
            }
            let keyChar = parse<Int32>(matcher.group(1), 16)
            if (keyChar > 1114111) {
                throw ParseException("Confusables, line " + fLineNum.toString() + ": Bad code point: " + (matcher.group(1)), matcher.start(1))
            }
            let m = fParseHexNum.matcher(matcher.group(2))
            let mapString = StringBuilder()
            while (m.find()) {
                let c = parse<Int32>(m.group(1), 16)
                if (c > 1114111) {
                    throw ParseException("Confusables, line " + fLineNum.toString() + ": Bad code point: " + (Int32.toString(c, 16)), matcher.start(2))
                }
                mapString.appendCodePoint(c)
            }
            if (!(Int32(mapString.size) >= 1)) {
                throw AssertionError()
            }
            let smapString = stringPool.addString(mapString.toString())
            fTable.put(keyChar, smapString)
            fKeySet.add(keyChar)
        }
        stringPool.sort()
        fStringTable = StringBuffer()
        let poolSize = stringPool.size()
        var i: Int32 = 0
        i = 0
        while (i < poolSize) {
            let s = stringPool.getByIndex(i)
            let strLen = Int32(s.fStr.size)
            let strIndex = Int32(fStringTable.size)
            if (strLen == 1) {
                s.fCharOrStrTableIndex = Int32(UInt32(Char(s.fStr[0])))
            } else {
                s.fCharOrStrTableIndex = strIndex
                fStringTable.append(s.fStr)
            }
            i++
        }
        for (keyCharStr in fKeySet) {
            let keyChar = keyCharStr.codePointAt(0)
            let targetMapping = fTable.get(keyChar)
            if (!targetMapping.isSome()) {
                throw AssertionError()
            }
            if (Int32(targetMapping.fStr.size) > 256) {
                throw IllegalArgumentException("Confusable prototypes cannot be longer than 256 entries.")
            }
            let key = SpoofChecker_ConfusableDataUtils.codePointAndLengthToKey(keyChar, Int32(targetMapping.fStr.size))
            let value = targetMapping.fCharOrStrTableIndex
            fKeyVec.append(key)
            fValueVec.append(value)
        }
        let numKeys = Int32(fKeyVec.size)
        dest.fCFUKeys = Array<Int32>(Int64(numKeys)) { _ => 0 }
        var previousCodePoint = 0
        i = 0
        while (i < numKeys) {
            let key = fKeyVec[Int64(i)]
            let codePoint = SpoofChecker_ConfusableDataUtils.keyToCodePoint(key)
            if (!(codePoint > previousCodePoint)) {
                throw AssertionError()
            }
            dest.fCFUKeys[Int64(i)] = key
            previousCodePoint = codePoint
            i++
        }
        let numValues = Int32(fValueVec.size)
        if (!(numKeys == numValues)) {
            throw AssertionError()
        }
        dest.fCFUValues = Array<Int16>(Int64(numValues)) { _ => 0 }
        i = 0
        for (value in fValueVec) {
            if (!(value < 65535)) {
                throw AssertionError()
            }
            dest.fCFUValues[Int64(match (0) { case _ => i++; i - 1 })] = Int16(value)
        }
        dest.fCFUStrings = toString(fStringTable)
    }

    public static func buildConfusableData(confusables: StringReader<InputStream>, dest: SpoofChecker_SpoofData): Unit {
        let builder = SpoofChecker_Builder_ConfusabledataBuilder()
        builder.build(confusables, dest)
    }
}


class SpoofChecker_Builder_ConfusabledataBuilder_SPUString {
    var fStr: String

    var fCharOrStrTableIndex: Int32 = 0

    init(s: String) {
        fStr = s
        fCharOrStrTableIndex = 0
    }
}


class SpoofChecker_Builder_ConfusabledataBuilder_SPUStringComparator <: Comparator {
    private init() { }

    public override func compare(sL: SpoofChecker_Builder_ConfusabledataBuilder_SPUString, sR: SpoofChecker_Builder_ConfusabledataBuilder_SPUString): Int32 {
        let lenL = Int32(sL.fStr.size)
        let lenR = Int32(sR.fStr.size)
        if (lenL < lenR) {
            return -1
        } else if (lenL > lenR) {
            return 1
        } else {
            return sL.fStr.compare(sR.fStr).value()
        }
    }

    static let INSTANCE = SpoofChecker_Builder_ConfusabledataBuilder_SPUStringComparator()
}


class SpoofChecker_Builder_ConfusabledataBuilder_SPUStringPool {
    public init() {
        fVec = Vector()
        fHash = Hashtable()
    }

    public func size(): Int32 {
        return Int32(fVec.size)
    }

    public func getByIndex(index: Int32): SpoofChecker_Builder_ConfusabledataBuilder_SPUString {
        let retString = fVec.elementAt(index)
        return retString
    }

    public func addString(src: String): SpoofChecker_Builder_ConfusabledataBuilder_SPUString {
        var hashedString = fHash.get(src)
        if (hashedString.isNone()) {
            hashedString = SpoofChecker_Builder_ConfusabledataBuilder_SPUString(src)
            fHash.put(src, hashedString)
            fVec.addElement(hashedString)
        }
        return hashedString
    }

    public func sort(): Unit {
        Collections.sort(fVec, SpoofChecker_Builder_ConfusabledataBuilder_SPUStringComparator.INSTANCE as Comparator)
    }

    private var fVec: Vector = None

    private var fHash: Hashtable = None
}


public class SpoofChecker_CheckResult {
    public var checks: Int32 = 0

    
    public var position: Int32 = 0

    public var numerics: UnicodeSet

    public var restrictionLevel: SpoofChecker_RestrictionLevel

    public init() {
        checks = 0
        position = 0
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("checks:")
        if (checks == 0) {
            sb.append(" none")
        } else if (checks == SpoofChecker.ALL_CHECKS) {
            sb.append(" all")
        } else {
            if ((checks & SpoofChecker.SINGLE_SCRIPT_CONFUSABLE) != 0) {
                sb.append(" SINGLE_SCRIPT_CONFUSABLE")
            }
            if ((checks & SpoofChecker.MIXED_SCRIPT_CONFUSABLE) != 0) {
                sb.append(" MIXED_SCRIPT_CONFUSABLE")
            }
            if ((checks & SpoofChecker.WHOLE_SCRIPT_CONFUSABLE) != 0) {
                sb.append(" WHOLE_SCRIPT_CONFUSABLE")
            }
            if ((checks & SpoofChecker.ANY_CASE) != 0) {
                sb.append(" ANY_CASE")
            }
            if ((checks & SpoofChecker.RESTRICTION_LEVEL) != 0) {
                sb.append(" RESTRICTION_LEVEL")
            }
            if ((checks & SpoofChecker.INVISIBLE) != 0) {
                sb.append(" INVISIBLE")
            }
            if ((checks & SpoofChecker.CHAR_LIMIT) != 0) {
                sb.append(" CHAR_LIMIT")
            }
            if ((checks & SpoofChecker.MIXED_NUMBERS) != 0) {
                sb.append(" MIXED_NUMBERS")
            }
        }
        sb.append(", numerics: ").append(numerics.toPattern(false))
        sb.append(", position: ").append(position)
        sb.append(", restrictionLevel: ").append(restrictionLevel.asString())
        return sb.toString()
    }
}


class SpoofChecker_ConfusableDataUtils {
    private init() { }

    public static let FORMAT_VERSION = 2

    public static func keyToCodePoint(key: Int32): Int32 {
        return key & 16777215
    }

    public static func keyToLength(key: Int32): Int32 {
        return (shr((key & -16777216), 24)) + 1
    }

    public static func codePointAndLengthToKey(codePoint: Int32, length: Int32): Int32 {
        if (!((codePoint & 16777215) == codePoint)) {
            throw AssertionError()
        }
        if (!(length <= 256)) {
            throw AssertionError()
        }
        return codePoint | (shl((length - 1), 24))
    }
}


class SpoofChecker_SpoofData {
    var fCFUKeys: Array<Int32>

    var fCFUValues: Array<Int16>

    var fCFUStrings: String

    private static let DATA_FORMAT = 1130788128

    private static let IS_ACCEPTABLE = SpoofChecker_SpoofData_IsAcceptable()

    public static func getDefault(): SpoofChecker_SpoofData {
        if (SpoofChecker_SpoofData_DefaultData.EXCEPTION.isSome()) {
            throw MissingResourceException("Could not load default confusables data: " + SpoofChecker_SpoofData_DefaultData.EXCEPTION.message, "SpoofChecker", "")
        }
        return SpoofChecker_SpoofData_DefaultData.INSTANCE
    }

    init() { }

    init(bytes: ByteArrayStream) {
        ICUBinary.readHeader(bytes, DATA_FORMAT, IS_ACCEPTABLE)
        bytes.mark()
        readData(bytes)
    }

    public override func equals(other: Object): Bool {
        if (!(checkOptionalIs<SpoofChecker_SpoofData, Object>(other))) {
            return false
        }
        let otherData = other
        if (!fCFUKeys == otherData.fCFUKeys) {
            return false
        }
        if (!fCFUValues == otherData.fCFUValues) {
            return false
        }
        if (!Utility.sameObjects(fCFUStrings, otherData.fCFUStrings) && fCFUStrings.isSome() && !fCFUStrings.equals(otherData.fCFUStrings)) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        return Int64(Arrays.hashCode(fCFUKeys) ^ Arrays.hashCode(fCFUValues) ^ Int32(fCFUStrings.hashCode()))
    }

    private func readData(bytes: ByteArrayStream): Unit {
        let magic = bytes.getInt()
        if (magic != 944111087) {
            throw IllegalArgumentException("Bad Spoof Check Data.")
        }
        let dataFormatVersion = bytes.getInt()
        let dataLength = bytes.getInt()
        let CFUKeysOffset = bytes.getInt()
        let CFUKeysSize = bytes.getInt()
        let CFUValuesOffset = bytes.getInt()
        let CFUValuesSize = bytes.getInt()
        let CFUStringTableOffset = bytes.getInt()
        let CFUStringTableSize = bytes.getInt()
        bytes.reset()
        ICUBinary.skipBytes(bytes, CFUKeysOffset)
        fCFUKeys = ICUBinary.getInts(bytes, CFUKeysSize, 0)
        bytes.reset()
        ICUBinary.skipBytes(bytes, CFUValuesOffset)
        fCFUValues = ICUBinary.getShorts(bytes, CFUValuesSize, 0)
        bytes.reset()
        ICUBinary.skipBytes(bytes, CFUStringTableOffset)
        fCFUStrings = ICUBinary.getString(bytes, CFUStringTableSize, 0)
    }

    public func confusableLookup(inChar: Int32, dest: StringBuilder): Unit {
        var lo = 0
        var hi = length()
                lo = mid
            } else {
                lo = mid
                break
            }
        } while (hi - lo > 1)
        if (codePointAt(lo) != inChar) {
            dest.appendCodePoint(inChar)
            return
        }
        appendValueTo(lo, dest)
        return
    }

    public func length(): Int32 {
        return Int32(fCFUKeys.size)
    }

    public func codePointAt(index: Int32): Int32 {
        return SpoofChecker_ConfusableDataUtils.keyToCodePoint(fCFUKeys[Int64(index)])
    }

    public func appendValueTo(index: Int32, dest: StringBuilder): Unit {
        let stringLength = SpoofChecker_ConfusableDataUtils.keyToLength(fCFUKeys[Int64(index)])
        let value = fCFUValues[Int64(index)]
        if (stringLength == 1) {
            dest.append(Char(value))
        } else {
            dest.append(fCFUStrings, Int32(value), Int32(value) + stringLength)
        }
    }
}


class SpoofChecker_SpoofData_IsAcceptable <: ICUBinary_Authenticate {
    init() { }

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == SpoofChecker_ConfusableDataUtils.FORMAT_VERSION || Int32(version[1]) != 0 || Int32(version[2]) != 0 || Int32(version[3]) != 0
    }
}


class SpoofChecker_SpoofData_DefaultData {
    private init() { }

    static var INSTANCE: SpoofChecker_SpoofData

    static var EXCEPTION: IOException

}


class SpoofChecker_ScriptSet <: BitSet {
    init() {
        BitSet()
    }

    private static let serialVersionUID = 1

    public func and(script: Int32): Unit {
        this.clear(0, script)
        this.clear(script + 1, UScript.CODE_LIMIT)
    }

    public func setAll(): Unit {
        this.set(0, UScript.CODE_LIMIT)
    }

    public func isFull(): Bool {
        return cardinality() == UScript.CODE_LIMIT
    }

    public func appendStringTo(sb: StringBuilder): Unit {
        sb.append("{ ")
        if (isEmpty()) {
            sb.append("- ")
        } else if (isFull()) {
            sb.append("* ")
        } else {
            var script = 0
            while (script < UScript.CODE_LIMIT) {
                if (get(script)) {
                    sb.append(UScript.getShortName(script))
                    sb.append(" ")
                }
                script++
            }
        }
        sb.append("}")
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("<ScriptSet ")
        appendStringTo(sb)
        sb.append(">")
        return sb.toString()
    }
}
