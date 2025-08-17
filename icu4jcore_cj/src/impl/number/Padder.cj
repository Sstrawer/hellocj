package icu4cj.impl.number


public class Padder {
    public static let FALLBACK_PADDING_STRING = " "

    public static let NONE = Padder(None, -1, None)

    var paddingString: String

    var targetWidth: Int32 = 0

    var position: Padder_PadPosition

    public init(paddingString: String, targetWidth: Int32, position: Padder_PadPosition) {
        this.paddingString = if (paddingString.isNone()) { FALLBACK_PADDING_STRING } else { paddingString }
        this.targetWidth = targetWidth
        this.position = if (position.isNone()) { Padder_PadPosition.BEFORE_PREFIX } else { position }
    }

    public static func none(): Padder {
        return NONE
    }

    public static func codePoints(cp: Int32, targetWidth: Int32, position: Padder_PadPosition): Padder {
        if (targetWidth >= 0) {
            let paddingString = String.valueOf(Character.toChars(cp))
            return Padder(paddingString, targetWidth, position)
        } else {
            throw IllegalArgumentException("Padding width must not be negative")
        }
    }

    public static func forProperties(properties: DecimalFormatProperties): Padder {
        return Padder(properties.getPadString(), properties.getFormatWidth(), properties.getPadPosition())
    }

    public func isValid(): Bool {
        return targetWidth > 0
    }

    public func padAndApply(mod1: Modifier, mod2: Modifier, string: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        let modLength = mod1.getCodePointCount() + mod2.getCodePointCount()
        let requiredPadding = targetWidth - modLength - string.codePointCount()
        if (!(leftIndex == 0 && rightIndex == string.lengthMethod())) {
            throw AssertionError()
        }
        var length = 0
        if (requiredPadding <= 0) {
            length += mod1.apply(string, leftIndex, rightIndex)
            length += mod2.apply(string, leftIndex, rightIndex + length)
            return length
        }
        if (refEq(position, Padder_PadPosition.AFTER_PREFIX)) {
            length += addPaddingHelper(paddingString, requiredPadding, string, leftIndex)
        } else if (refEq(position, Padder_PadPosition.BEFORE_SUFFIX)) {
            length += addPaddingHelper(paddingString, requiredPadding, string, rightIndex + length)
        }
        length += mod1.apply(string, leftIndex, rightIndex + length)
        length += mod2.apply(string, leftIndex, rightIndex + length)
        if (refEq(position, Padder_PadPosition.BEFORE_PREFIX)) {
            length += addPaddingHelper(paddingString, requiredPadding, string, leftIndex)
        } else if (refEq(position, Padder_PadPosition.AFTER_SUFFIX)) {
            length += addPaddingHelper(paddingString, requiredPadding, string, rightIndex + length)
        }
        return length
    }

    private static func addPaddingHelper(paddingString: String, requiredPadding: Int32, string: FormattedStringBuilder, index: Int32): Int32 {
        var i = 0
        while (i < requiredPadding) {
            string.insert(index, paddingString, None)
            i++
        }
        return Int32(paddingString.size) * requiredPadding
    }
}


public class Padder_PadPosition <: Enum<Padder_PadPosition> {
    public static let BEFORE_PREFIX = Padder_PadPosition("BEFORE_PREFIX", 0)

    public static let AFTER_PREFIX = Padder_PadPosition("AFTER_PREFIX", 1)

    public static let BEFORE_SUFFIX = Padder_PadPosition("BEFORE_SUFFIX", 2)

    public static let AFTER_SUFFIX = Padder_PadPosition("AFTER_SUFFIX", 3)

    private static func _values(): Array<Padder_PadPosition> {
        return [Padder_PadPosition.BEFORE_PREFIX, Padder_PadPosition.AFTER_PREFIX, Padder_PadPosition.BEFORE_SUFFIX, Padder_PadPosition.AFTER_SUFFIX]
    }

    private static let _VALUES = Padder_PadPosition._values()

    public static func values(): Array<Padder_PadPosition> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Padder_PadPosition {
        return (TypeInfo.of<Padder_PadPosition>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Padder_PadPosition
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static func fromOld(old: Int32): Padder_PadPosition {
        match (old) {
            case 0 => return Padder_PadPosition.BEFORE_PREFIX
            case 1 => return Padder_PadPosition.AFTER_PREFIX
            case 2 => return Padder_PadPosition.BEFORE_SUFFIX
            case 3 => return Padder_PadPosition.AFTER_SUFFIX
            case _ => throw IllegalArgumentException("Don't know how to map " + old.toString())
        }
    }

    public func toOld(): Int32 {
        match (this) {
            case Padder_PadPosition.BEFORE_PREFIX => return DecimalFormat.PAD_BEFORE_PREFIX
            case Padder_PadPosition.AFTER_PREFIX => return DecimalFormat.PAD_AFTER_PREFIX
            case Padder_PadPosition.BEFORE_SUFFIX => return DecimalFormat.PAD_BEFORE_SUFFIX
            case Padder_PadPosition.AFTER_SUFFIX => return DecimalFormat.PAD_AFTER_SUFFIX
            case _ => return -1
        }
    }
}
