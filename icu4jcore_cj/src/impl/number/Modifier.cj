package icu4cj.impl.number


public interface Modifier {
    public func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32

    public func getPrefixLength(): Int32

    public func getCodePointCount(): Int32

    public func isStrong(): Bool

    public func containsField(currency: Format_Field): Bool

    public func getParameters(): Modifier_Parameters

    public func strictEquals(other: Modifier): Bool

    func semanticallyEquivalent(other: Modifier): Bool {
        let paramsThis = this.getParameters()
        let paramsOther = other.getParameters()
        if (paramsThis.isNone() && paramsOther.isNone()) {
            return this.strictEquals(other)
        } else if (paramsThis.isNone() || paramsOther.isNone()) {
            return false
        } else if (paramsThis.obj.isNone() && paramsOther.obj.isNone()) {
            return this.strictEquals(other)
        } else if (paramsThis.obj.isNone() || paramsOther.obj.isNone()) {
            return false
        }
        for (signum in Modifier_Signum.VALUES) {
            for (plural in StandardPlural.VALUES) {
                let mod1 = paramsThis.obj.getModifier(signum, plural)
                let mod2 = paramsOther.obj.getModifier(signum, plural)
                if (refEq(mod1, mod2)) {
                    continue
                } else if (mod1.isNone() || mod2.isNone()) {
                    return false
                } else if (!mod1.strictEquals(mod2)) {
                    return false
                } else {
                    continue
                }
            }
        }
        return true
    }
}

public static class Modifier_Signum <: Enum<Modifier_Signum> {
    public static let NEG = Modifier_Signum("NEG", 0)

    public static let NEG_ZERO = Modifier_Signum("NEG_ZERO", 1)

    public static let POS_ZERO = Modifier_Signum("POS_ZERO", 2)

    public static let POS = Modifier_Signum("POS", 3)

    private static func _values(): Array<Modifier_Signum> {
        return [Modifier_Signum.NEG, Modifier_Signum.NEG_ZERO, Modifier_Signum.POS_ZERO, Modifier_Signum.POS]
    }

    private static let _VALUES = Modifier_Signum._values()

    public static func values(): Array<Modifier_Signum> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Modifier_Signum {
        return (TypeInfo.of<Modifier_Signum>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Modifier_Signum
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    static let COUNT = Int32(Modifier_Signum.values().size)

    public static let VALUES = Modifier_Signum.values()
}


public static class Modifier_Parameters {

    public var obj: ModifierStore

    public var signum: Modifier_Signum

    public var plural: StandardPlural
}
