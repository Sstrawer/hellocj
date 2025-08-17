package icu4cj.text


public abstract class Normalizer2 {
    public static func getNFCInstance(): Normalizer2 {
        return Norm2AllModes.getNFCInstance().comp
    }

    public static func getNFDInstance(): Normalizer2 {
        return Norm2AllModes.getNFCInstance().decomp
    }

    public static func getNFKCInstance(): Normalizer2 {
        return Norm2AllModes.getNFKCInstance().comp
    }

    public static func getNFKDInstance(): Normalizer2 {
        return Norm2AllModes.getNFKCInstance().decomp
    }

    public static func getNFKCCasefoldInstance(): Normalizer2 {
        return Norm2AllModes.getNFKC_CFInstance().comp
    }

    public static func getNFKCSimpleCasefoldInstance(): Normalizer2 {
        return Norm2AllModes.getNFKC_SCFInstance().comp
    }

    public static func getInstance(data: InputStream, name: String, mode: Normalizer2_Mode): Normalizer2 {
        var bytes: ByteArrayStream = None
        if (data.isSome()) {
            try {
                bytes = ICUBinary.getByteBufferFromInputStreamAndCloseStream(data)
            } catch (e: IOException) {
                throw ICUUncheckedIOException(e)
            }
        }
        let all2Modes = Norm2AllModes.getInstance(bytes, name)
        match (mode) {
            case Normalizer2_Mode.COMPOSE => return all2Modes.comp
            case Normalizer2_Mode.DECOMPOSE => return all2Modes.decomp
            case Normalizer2_Mode.FCD => return all2Modes.fcd
            case Normalizer2_Mode.COMPOSE_CONTIGUOUS => return all2Modes.fcc
            case _ => return None
        }
    }

    public func normalize(src: String): String {
        if (src) {
            let spanLength = spanQuickCheckYes(src)
            if (spanLength == src.size) {
                return src
            }
            if (spanLength != 0) {
                let sb = StringBuilder().append(src, 0, spanLength)
                return normalizeSecondAndAppend(sb, src.subSequence(spanLength, src.size)).toString()
            }
        }
        return normalize(src, StringBuilder()).toString()
    }

    public func normalize(src: String, dest: StringBuilder): StringBuilder

    public func normalize(src: String, dest: Appendable): Appendable

    public func normalizeSecondAndAppend(first: StringBuilder, second: String): StringBuilder

    public func append(first: StringBuilder, second: String): StringBuilder

    public func getDecomposition(c: Int32): String

    public func getRawDecomposition(c: Int32): String {
        return None
    }

    public func composePair(a: Int32, b: Int32): Int32 {
        return -1
    }

    public func getCombiningClass(c: Int32): Int32 {
        return 0
    }

    public func isNormalized(s: String): Bool

    public func quickCheck(s: String): Normalizer_QuickCheckResult

    public func spanQuickCheckYes(s: String): Int32

    public func hasBoundaryBefore(c: Int32): Bool

    public func hasBoundaryAfter(c: Int32): Bool

    public func isInert(c: Int32): Bool

    
    protected init() { }
}


public class Normalizer2_Mode <: Enum<Normalizer2_Mode> {
    public static let COMPOSE = Normalizer2_Mode("COMPOSE", 0)

    public static let DECOMPOSE = Normalizer2_Mode("DECOMPOSE", 1)

    public static let FCD = Normalizer2_Mode("FCD", 2)

    public static let COMPOSE_CONTIGUOUS = Normalizer2_Mode("COMPOSE_CONTIGUOUS", 3)

    private static func _values(): Array<Normalizer2_Mode> {
        return [Normalizer2_Mode.COMPOSE, Normalizer2_Mode.DECOMPOSE, Normalizer2_Mode.FCD, Normalizer2_Mode.COMPOSE_CONTIGUOUS]
    }

    private static let _VALUES = Normalizer2_Mode._values()

    public static func values(): Array<Normalizer2_Mode> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Normalizer2_Mode {
        return (TypeInfo.of<Normalizer2_Mode>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Normalizer2_Mode
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
