package icu4cj.text


public abstract class IDNA {
    public static let DEFAULT = 0

    
    public static let ALLOW_UNASSIGNED = 1

    public static let USE_STD3_RULES = 2

    public static let CHECK_BIDI = 4

    public static let CHECK_CONTEXTJ = 8

    public static let NONTRANSITIONAL_TO_ASCII = 16

    public static let NONTRANSITIONAL_TO_UNICODE = 32

    public static let CHECK_CONTEXTO = 64

    public static func getUTS46Instance(options: Int32): IDNA {
        return UTS46(options)
    }

    public func labelToASCII(label: String, dest: StringBuilder, info: IDNA_Info): StringBuilder

    public func labelToUnicode(label: String, dest: StringBuilder, info: IDNA_Info): StringBuilder

    public func nameToASCII(name: String, dest: StringBuilder, info: IDNA_Info): StringBuilder

    public func nameToUnicode(name: String, dest: StringBuilder, info: IDNA_Info): StringBuilder

    
    protected static func resetInfo(info: IDNA_Info): Unit {
        info.reset()
    }

    
    protected static func hasCertainErrors(info: IDNA_Info, errors: EnumSet): Bool {
        return !info.errors.isEmpty() && !Collections.disjoint(info.errors, errors)
    }

    
    protected static func hasCertainLabelErrors(info: IDNA_Info, errors: EnumSet): Bool {
        return !info.labelErrors.isEmpty() && !Collections.disjoint(info.labelErrors, errors)
    }

    
    protected static func addLabelError(info: IDNA_Info, error: IDNA_Error): Unit {
        info.labelErrors.add(error)
    }

    
    protected static func promoteAndResetLabelErrors(info: IDNA_Info): Unit {
        if (!info.labelErrors.isEmpty()) {
            info.errors.addAll(info.labelErrors)
            info.labelErrors.clear()
        }
    }

    
    protected static func addError(info: IDNA_Info, error: IDNA_Error): Unit {
        info.errors.add(error)
    }

    
    protected static func setTransitionalDifferent(info: IDNA_Info): Unit {
        info.isTransDiff = true
    }

    
    protected static func setBiDi(info: IDNA_Info): Unit {
        info.isBiDi = true
    }

    
    protected static func isBiDi(info: IDNA_Info): Bool {
        return info.isBiDi
    }

    
    protected static func setNotOkBiDi(info: IDNA_Info): Unit {
        info.isOkBiDi = false
    }

    
    protected static func isOkBiDi(info: IDNA_Info): Bool {
        return info.isOkBiDi
    }

    

    
    public static func convertToASCII(src: String, options: Int32): StringBuffer {
        let iter = UCharacterIterator.getInstance(src)
        return convertToASCII(iter, options)
    }

    
    public static func convertToASCII(src: StringBuffer, options: Int32): StringBuffer {
        let iter = UCharacterIterator.getInstance(src)
        return convertToASCII(iter, options)
    }

    
    public static func convertToASCII(src: UCharacterIterator, options: Int32): StringBuffer {
        return IDNA2003.convertToASCII(src, options)
    }

    
    public static func convertIDNToASCII(src: UCharacterIterator, options: Int32): StringBuffer {
        return convertIDNToASCII(src.getText(), options)
    }

    
    public static func convertIDNToASCII(src: StringBuffer, options: Int32): StringBuffer {
        return convertIDNToASCII(toString(src), options)
    }

    
    public static func convertIDNToASCII(src: String, options: Int32): StringBuffer {
        return IDNA2003.convertIDNToASCII(src, options)
    }

    
    public static func convertToUnicode(src: String, options: Int32): StringBuffer {
        let iter = UCharacterIterator.getInstance(src)
        return convertToUnicode(iter, options)
    }

    
    public static func convertToUnicode(src: StringBuffer, options: Int32): StringBuffer {
        let iter = UCharacterIterator.getInstance(src)
        return convertToUnicode(iter, options)
    }

    
    public static func convertToUnicode(src: UCharacterIterator, options: Int32): StringBuffer {
        return IDNA2003.convertToUnicode(src, options)
    }

    
    public static func convertIDNToUnicode(src: UCharacterIterator, options: Int32): StringBuffer {
        return convertIDNToUnicode(src.getText(), options)
    }

    
    public static func convertIDNToUnicode(src: StringBuffer, options: Int32): StringBuffer {
        return convertIDNToUnicode(toString(src), options)
    }

    
    public static func convertIDNToUnicode(src: String, options: Int32): StringBuffer {
        return IDNA2003.convertIDNToUnicode(src, options)
    }

    
    public static func compare(s1: StringBuffer, s2: StringBuffer, options: Int32): Int32 {
        if (s1.isNone() || s2.isNone()) {
            throw IllegalArgumentException("One of the source buffers is null")
        }
        return IDNA2003.compare(toString(s1), toString(s2), options)
    }

    
    public static func compare(s1: String, s2: String, options: Int32): Int32 {
        if (s1.isNone() || s2.isNone()) {
            throw IllegalArgumentException("One of the source buffers is null")
        }
        return IDNA2003.compare(s1, s2, options)
    }

    
    public static func compare(s1: UCharacterIterator, s2: UCharacterIterator, options: Int32): Int32 {
        if (s1.isNone() || s2.isNone()) {
            throw IllegalArgumentException("One of the source buffers is null")
        }
        return IDNA2003.compare(s1.getText(), s2.getText(), options)
    }
}


public class IDNA_Info {
    public init() {
        errors = EnumSet.noneOf(TypeInfo.of<IDNA_Error>() as ClassTypeInfo)
        labelErrors = EnumSet.noneOf(TypeInfo.of<IDNA_Error>() as ClassTypeInfo)
        isTransDiff = false
        isBiDi = false
        isOkBiDi = true
    }

    public func hasErrors(): Bool {
        return !errors.isEmpty()
    }

    public func getErrors(): Set<IDNA_Error> {
        return errors
    }

    public func isTransitionalDifferent(): Bool {
        return isTransDiff
    }

    public func reset(): Unit {
        errors.clear()
        labelErrors.clear()
        isTransDiff = false
        isBiDi = false
        isOkBiDi = true
    }

    var errors: EnumSet = None

    var labelErrors: EnumSet = None

    var isTransDiff: Bool = false

    var isBiDi: Bool = false

    var isOkBiDi: Bool = false
}


public class IDNA_Error <: Enum<IDNA_Error> {
    public static let EMPTY_LABEL = IDNA_Error("EMPTY_LABEL", 0)

    public static let LABEL_TOO_LONG = IDNA_Error("LABEL_TOO_LONG", 1)

    public static let DOMAIN_NAME_TOO_LONG = IDNA_Error("DOMAIN_NAME_TOO_LONG", 2)

    public static let LEADING_HYPHEN = IDNA_Error("LEADING_HYPHEN", 3)

    public static let TRAILING_HYPHEN = IDNA_Error("TRAILING_HYPHEN", 4)

    public static let HYPHEN_3_4 = IDNA_Error("HYPHEN_3_4", 5)

    public static let LEADING_COMBINING_MARK = IDNA_Error("LEADING_COMBINING_MARK", 6)

    public static let DISALLOWED = IDNA_Error("DISALLOWED", 7)

    public static let PUNYCODE = IDNA_Error("PUNYCODE", 8)

    public static let LABEL_HAS_DOT = IDNA_Error("LABEL_HAS_DOT", 9)

    public static let INVALID_ACE_LABEL = IDNA_Error("INVALID_ACE_LABEL", 10)

    public static let BIDI = IDNA_Error("BIDI", 11)

    public static let CONTEXTJ = IDNA_Error("CONTEXTJ", 12)

    public static let CONTEXTO_PUNCTUATION = IDNA_Error("CONTEXTO_PUNCTUATION", 13)

    public static let CONTEXTO_DIGITS = IDNA_Error("CONTEXTO_DIGITS", 14)

    private static func _values(): Array<IDNA_Error> {
        return [IDNA_Error.EMPTY_LABEL, IDNA_Error.LABEL_TOO_LONG, IDNA_Error.DOMAIN_NAME_TOO_LONG, IDNA_Error.LEADING_HYPHEN, IDNA_Error.TRAILING_HYPHEN, IDNA_Error.HYPHEN_3_4, IDNA_Error.LEADING_COMBINING_MARK, IDNA_Error.DISALLOWED, IDNA_Error.PUNYCODE, IDNA_Error.LABEL_HAS_DOT, IDNA_Error.INVALID_ACE_LABEL, IDNA_Error.BIDI, IDNA_Error.CONTEXTJ, IDNA_Error.CONTEXTO_PUNCTUATION, IDNA_Error.CONTEXTO_DIGITS]
    }

    private static let _VALUES = IDNA_Error._values()

    public static func values(): Array<IDNA_Error> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): IDNA_Error {
        return (TypeInfo.of<IDNA_Error>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as IDNA_Error
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
