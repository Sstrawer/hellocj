package icu4cj.text

public class BidiTransform {
    private var bidi: Bidi

    private var text: String

    private var reorderingOptions: Int32 = 0

    private var shapingOptions: Int32 = 0


    public func transform(text: String, inParaLevel: UInt8, inOrder: BidiTransform_Order, outParaLevel: UInt8, outOrder: BidiTransform_Order, doMirroring: BidiTransform_Mirroring, shapingOptions: Int32): String {
        if (text.isNone() || inOrder.isNone() || outOrder.isNone() || doMirroring.isNone()) {
            throw IllegalArgumentException()
        }
        this.text = toString(text)
        let levels = [inParaLevel, outParaLevel]
        resolveBaseDirection(levels)
        let currentScheme = findMatchingScheme(levels[0], inOrder, levels[1], outOrder)
        if (currentScheme.isSome()) {
            this.bidi = Bidi()
            this.reorderingOptions = if (refEq(BidiTransform_Mirroring.ON, doMirroring)) { Int32(Bidi.DO_MIRRORING) } else { Int32(Bidi.REORDER_DEFAULT) }
            this.shapingOptions = shapingOptions & 
            currentScheme.doTransform(this)
        }
        return this.text
    }

    private func resolveBaseDirection(levels: Array<UInt8>): Unit {
        if (Bidi.IsDefaultLevel(levels[0])) {
            let level = Bidi.getBaseDirection(text)
            levels[0] = if (level != Bidi.NEUTRAL) { level } else { if (levels[0] == Bidi.LEVEL_DEFAULT_RTL) { Bidi.RTL } else { Bidi.LTR } }
        } else {
            levels[0] &= 1
        }
        if (Bidi.IsDefaultLevel(levels[1])) {
            levels[1] = levels[0]
        } else {
            levels[1] &= 1
        }
    }

    private func findMatchingScheme(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): BidiTransform_ReorderingScheme {
        for (scheme in BidiTransform_ReorderingScheme.values()) {
            if (scheme.matches(inLevel, inOrder, outLevel, outOrder)) {
                return scheme
            }
        }
        return None
    }

    public func resolve(level: UInt8, options: Int32): Unit {
        bidi.setInverse((options & Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT)) != 0)
        bidi.setReorderingMode(options)
        bidi.setPara(text, level, None)
    }

    public func reorder(): Unit {
        text = bidi.writeReordered(reorderingOptions)
        reorderingOptions = Int32(Bidi.REORDER_DEFAULT)
    }

    public func reverse(): Unit {
        text = Bidi.writeReverse(text, Bidi.OPTION_DEFAULT)
    }

    public func mirror(): Unit {
        if ((reorderingOptions & Int32(Bidi.DO_MIRRORING)) == 0) {
            return
        }
        let sb = StringBuffer(text)
        let levels = bidi.getLevels()
        var i = 0
        let n = Int32(levels.size)
        while (i < n) {
            let ch = UTF16.toRuneArray()[sb, i]
            if ((Int32(levels[Int64(i)]) & 1) != 0) {
                UTF16.setCharAt(sb, i, UCharacter.getMirror(ch))
            }
            i += UTF16.getCharCount(ch)
        }
        text = toString(sb)
        reorderingOptions &= 
    }

    public func shapeArabic(digitsDir: Int32, lettersDir: Int32): Unit {
        if (digitsDir == lettersDir) {
            shapeArabic(shapingOptions | digitsDir)
        } else {
            shapeArabic((shapingOptions & ) | digitsDir)
            shapeArabic((shapingOptions & ) | lettersDir)
        }
    }

    private func shapeArabic(options: Int32): Unit {
        if (options != 0) {
            let shaper = ArabicShaping(options)
            @AssertThrows[ArabicShapingException]({
                text = shaper.shape(text)
            })
        }
    }

    static func IsLTR(level: UInt8): Bool {
        return (Int32(level) & 1) == 0
    }

    static func IsRTL(level: UInt8): Bool {
        return (Int32(level) & 1) == 1
    }

    static func IsLogical(order: BidiTransform_Order): Bool {
        return refEq(BidiTransform_Order.LOGICAL, order)
    }

    static func IsVisual(order: BidiTransform_Order): Bool {
        return refEq(BidiTransform_Order.VISUAL, order)
    }
}


public class BidiTransform_Order <: Enum<BidiTransform_Order> {
    public static let LOGICAL = BidiTransform_Order("LOGICAL", 0)

    public static let VISUAL = BidiTransform_Order("VISUAL", 1)

    private static func _values(): Array<BidiTransform_Order> {
        return [BidiTransform_Order.LOGICAL, BidiTransform_Order.VISUAL]
    }

    private static let _VALUES = BidiTransform_Order._values()

    public static func values(): Array<BidiTransform_Order> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): BidiTransform_Order {
        return (TypeInfo.of<BidiTransform_Order>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as BidiTransform_Order
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class BidiTransform_Mirroring <: Enum<BidiTransform_Mirroring> {
    public static let OFF = BidiTransform_Mirroring("OFF", 0)

    public static let ON = BidiTransform_Mirroring("ON", 1)

    private static func _values(): Array<BidiTransform_Mirroring> {
        return [BidiTransform_Mirroring.OFF, BidiTransform_Mirroring.ON]
    }

    private static let _VALUES = BidiTransform_Mirroring._values()

    public static func values(): Array<BidiTransform_Mirroring> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): BidiTransform_Mirroring {
        return (TypeInfo.of<BidiTransform_Mirroring>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as BidiTransform_Mirroring
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class BidiTransform_ReorderingScheme <: Enum<BidiTransform_ReorderingScheme> {
    public static let LOG_LTR_TO_VIS_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_1("LOG_LTR_TO_VIS_LTR", 0)

    public static let LOG_RTL_TO_VIS_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_2("LOG_RTL_TO_VIS_LTR", 1)

    public static let LOG_LTR_TO_VIS_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_3("LOG_LTR_TO_VIS_RTL", 2)

    public static let LOG_RTL_TO_VIS_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_4("LOG_RTL_TO_VIS_RTL", 3)

    public static let VIS_LTR_TO_LOG_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_5("VIS_LTR_TO_LOG_RTL", 4)

    public static let VIS_RTL_TO_LOG_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_6("VIS_RTL_TO_LOG_RTL", 5)

    public static let VIS_LTR_TO_LOG_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_7("VIS_LTR_TO_LOG_LTR", 6)

    public static let VIS_RTL_TO_LOG_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_8("VIS_RTL_TO_LOG_LTR", 7)

    public static let LOG_LTR_TO_LOG_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_9("LOG_LTR_TO_LOG_RTL", 8)

    public static let LOG_RTL_TO_LOG_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_10("LOG_RTL_TO_LOG_LTR", 9)

    public static let VIS_LTR_TO_VIS_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_11("VIS_LTR_TO_VIS_RTL", 10)

    public static let VIS_RTL_TO_VIS_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_12("VIS_RTL_TO_VIS_LTR", 11)

    public static let LOG_LTR_TO_LOG_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_13("LOG_LTR_TO_LOG_LTR", 12)

    public static let LOG_RTL_TO_LOG_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_14("LOG_RTL_TO_LOG_RTL", 13)

    public static let VIS_LTR_TO_VIS_LTR: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_15("VIS_LTR_TO_VIS_LTR", 14)

    public static let VIS_RTL_TO_VIS_RTL: BidiTransform_ReorderingScheme = BidiTransform_ReorderingScheme_16("VIS_RTL_TO_VIS_RTL", 15)

    private static func _values(): Array<BidiTransform_ReorderingScheme> {
        return [BidiTransform_ReorderingScheme.LOG_LTR_TO_VIS_LTR, BidiTransform_ReorderingScheme.LOG_RTL_TO_VIS_LTR, BidiTransform_ReorderingScheme.LOG_LTR_TO_VIS_RTL, BidiTransform_ReorderingScheme.LOG_RTL_TO_VIS_RTL, BidiTransform_ReorderingScheme.VIS_LTR_TO_LOG_RTL, BidiTransform_ReorderingScheme.VIS_RTL_TO_LOG_RTL, BidiTransform_ReorderingScheme.VIS_LTR_TO_LOG_LTR, BidiTransform_ReorderingScheme.VIS_RTL_TO_LOG_LTR, BidiTransform_ReorderingScheme.LOG_LTR_TO_LOG_RTL, BidiTransform_ReorderingScheme.LOG_RTL_TO_LOG_LTR, BidiTransform_ReorderingScheme.VIS_LTR_TO_VIS_RTL, BidiTransform_ReorderingScheme.VIS_RTL_TO_VIS_LTR, BidiTransform_ReorderingScheme.LOG_LTR_TO_LOG_LTR, BidiTransform_ReorderingScheme.LOG_RTL_TO_LOG_RTL, BidiTransform_ReorderingScheme.VIS_LTR_TO_VIS_LTR, BidiTransform_ReorderingScheme.VIS_RTL_TO_VIS_RTL]
    }

    private static let _VALUES = BidiTransform_ReorderingScheme._values()

    public static func values(): Array<BidiTransform_ReorderingScheme> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): BidiTransform_ReorderingScheme {
        return (TypeInfo.of<BidiTransform_ReorderingScheme>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as BidiTransform_ReorderingScheme
    }

    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool

    public func doTransform(transform: BidiTransform): Unit
}


class BidiTransform_ReorderingScheme_1 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.reorder()
    }
}

class BidiTransform_ReorderingScheme_2 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_DEFAULT))
        transform.reorder()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
    }
}

class BidiTransform_ReorderingScheme_3 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.reorder()
        transform.reverse()
    }
}

class BidiTransform_ReorderingScheme_4 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_DEFAULT))
        transform.reorder()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
        transform.reverse()
    }
}

class BidiTransform_ReorderingScheme_5 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT))
        transform.reorder()
    }
}

class BidiTransform_ReorderingScheme_6 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.reverse()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT))
        transform.reorder()
    }
}

class BidiTransform_ReorderingScheme_7 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT))
        transform.reorder()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
    }
}

class BidiTransform_ReorderingScheme_8 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.reverse()
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT))
        transform.reorder()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
    }
}

class BidiTransform_ReorderingScheme_9 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_RUNS_ONLY))
        transform.reorder()
    }
}

class BidiTransform_ReorderingScheme_10 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_RUNS_ONLY))
        transform.reorder()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
    }
}

class BidiTransform_ReorderingScheme_11 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
        transform.reverse()
    }
}

class BidiTransform_ReorderingScheme_12 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.reverse()
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
    }
}

class BidiTransform_ReorderingScheme_13 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_LOGICAL)
    }
}

class BidiTransform_ReorderingScheme_14 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsLogical(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsLogical(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.RTL, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_VISUAL_LTR, ArabicShaping.TEXT_DIRECTION_LOGICAL)
    }
}

class BidiTransform_ReorderingScheme_15 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsLTR(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsLTR(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
    }
}

class BidiTransform_ReorderingScheme_16 <: BidiTransform_ReorderingScheme {
    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public override func matches(inLevel: UInt8, inOrder: BidiTransform_Order, outLevel: UInt8, outOrder: BidiTransform_Order): Bool {
        return BidiTransform.IsRTL(inLevel) && BidiTransform.IsVisual(inOrder) && BidiTransform.IsRTL(outLevel) && BidiTransform.IsVisual(outOrder)
    }

    public override func doTransform(transform: BidiTransform): Unit {
        transform.reverse()
        transform.resolve(Bidi.LTR, Int32(Bidi.REORDER_DEFAULT))
        transform.mirror()
        transform.shapeArabic(ArabicShaping.TEXT_DIRECTION_LOGICAL, ArabicShaping.TEXT_DIRECTION_VISUAL_LTR)
        transform.reverse()
    }
}