package icu4cj.impl.number

public class AdoptingModifierStore <: ModifierStore {
    private let positive: Modifier

    private let posZero: Modifier

    private let negZero: Modifier

    private let negative: Modifier

    let mods: Array<Modifier>

    var frozen: Bool = false

    public init(positive: Modifier, posZero: Modifier, negZero: Modifier, negative: Modifier) {
        this.positive = positive
        this.posZero = posZero
        this.negZero = negZero
        this.negative = negative
        this.mods = None
        this.frozen = true
    }

    public init() {
        this.positive = None
        this.posZero = None
        this.negZero = None
        this.negative = None
        this.mods = Array<Modifier>(Int64(4 * StandardPlural.COUNT))
        this.frozen = false
    }

    public func setModifier(signum: Modifier_Signum, plural: StandardPlural, mod: Modifier): Unit {
        if (!(!frozen)) {
            throw AssertionError()
        }
        mods[Int64(getModIndex(signum, plural))] = mod
    }

    public func freeze(): Unit {
        frozen = true
    }

    public func getModifierWithoutPlural(signum: Modifier_Signum): Modifier {
        if (!frozen) {
            throw AssertionError()
        }
        if (!mods.isNone()) {
            throw AssertionError()
        }
        if (!signum.isSome()) {
            throw AssertionError()
        }
        match (signum) {
            case Modifier_Signum.POS => return positive
            case Modifier_Signum.POS_ZERO => return posZero
            case Modifier_Signum.NEG_ZERO => return negZero
            case Modifier_Signum.NEG => return negative
            case _ => throw Exception("Unreachable")
        }
    }

    public override func getModifier(signum: Modifier_Signum, plural: StandardPlural): Modifier {
        if (!frozen) {
            throw AssertionError()
        }
        if (!positive.isNone()) {
            throw AssertionError()
        }
        return mods[Int64(getModIndex(signum, plural))]
    }

    private static func getModIndex(signum: Modifier_Signum, plural: StandardPlural): Int32 {
        if (!signum.isSome()) {
            throw AssertionError()
        }
        if (!plural.isSome()) {
            throw AssertionError()
        }
        return plural.ordinal * Modifier_Signum.COUNT + signum.ordinal
    }
}
