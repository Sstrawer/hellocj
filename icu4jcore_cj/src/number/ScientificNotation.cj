package icu4cj.number


public class ScientificNotation <: Notation {
    var engineeringInterval: Int32 = 0

    var requireMinInt: Bool = false

    var minExponentDigits: Int32 = 0

    var exponentSignDisplay: NumberFormatter_SignDisplay

    init(engineeringInterval: Int32, requireMinInt: Bool, minExponentDigits: Int32, exponentSignDisplay: NumberFormatter_SignDisplay) {
        super()
        this.engineeringInterval = engineeringInterval
        this.requireMinInt = requireMinInt
        this.minExponentDigits = minExponentDigits
        this.exponentSignDisplay = exponentSignDisplay
    }

    public func withMinExponentDigits(minExponentDigits: Int32): ScientificNotation {
        if (minExponentDigits >= 1 && minExponentDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            let other = createCopy()
            other.minExponentDigits = minExponentDigits
            return other
        } else {
            throw IllegalArgumentException("Integer digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public func withExponentSignDisplay(exponentSignDisplay: NumberFormatter_SignDisplay): ScientificNotation {
        let other = createCopy()
        other.exponentSignDisplay = exponentSignDisplay
        return other
    }

    public func createCopy(): ScientificNotation {
        return ScientificNotation(engineeringInterval, requireMinInt, minExponentDigits, exponentSignDisplay)
    }

    public func withLocaleData(symbols: DecimalFormatSymbols, build: Bool, parent: MicroPropsGenerator): MicroPropsGenerator {
        return ScientificNotation_ScientificHandler(this, symbols, build, parent)
    }
}


class ScientificNotation_ScientificHandler <: MicroPropsGenerator & MultiplierProducer & Modifier {
    let notation: ScientificNotation

    let symbols: DecimalFormatSymbols

    let precomputedMods: Array<ScientificNotation_ScientificModifier>

    let parent: MicroPropsGenerator

    var exponent: Int32 = 0

    init(notation: ScientificNotation, symbols: DecimalFormatSymbols, safe: Bool, parent: MicroPropsGenerator) {
        this.notation = notation
        this.symbols = symbols
        this.parent = parent
        if (safe) {
            precomputedMods = Array<ScientificNotation_ScientificModifier>(25)
            var i = -12
            while (i <= 12) {
                precomputedMods[Int64(i + 12)] = ScientificNotation_ScientificModifier(i, this)
                i++
            }
        } else {
            precomputedMods = None
        }
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(quantity)
        if (!micros.rounder.isSome()) {
            throw AssertionError()
        }
        if (quantity.isInfinite() || quantity.isNaN()) {
            micros.modInner = ConstantAffixModifier.EMPTY
            return micros
        }
        let exponent: Int32
        if (quantity.isZeroish()) {
            if (notation.requireMinInt && checkOptionalIs<Precision_SignificantRounderImpl, Precision>(micros.rounder)) {
                micros.rounder.apply(quantity, notation.engineeringInterval)
                exponent = 0
            } else {
                micros.rounder.apply(quantity)
                exponent = 0
            }
        } else {
            exponent = -micros.rounder.chooseMultiplierAndApply(quantity, this)
        }
        if (precomputedMods.isSome() && exponent >= -12 && exponent <= 12) {
            micros.modInner = precomputedMods[Int64(exponent + 12)]
        } else if (precomputedMods.isSome()) {
            micros.modInner = ScientificNotation_ScientificModifier(exponent, this)
        } else {
            this.exponent = exponent
            micros.modInner = this
        }
        quantity.adjustExponent(exponent)
        micros.rounder = None
        return micros
    }

    public override func getMultiplier(magnitude: Int32): Int32 {
        let interval = notation.engineeringInterval
        let digitsShown: Int32
        if (notation.requireMinInt) {
            digitsShown = interval
        } else if (interval <= 1) {
            digitsShown = 1
        } else {
            digitsShown = ((magnitude % interval + interval) % interval) + 1
        }
        return digitsShown - magnitude - 1
    }

    public override func getPrefixLength(): Int32 {
        return 0
    }

    public override func getCodePointCount(): Int32 {
        return 999
    }

    public override func isStrong(): Bool {
        return true
    }

    public override func containsField(field: Format_Field): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    public override func getParameters(): Modifier_Parameters {
        if (!false) {
            throw AssertionError()
        }
        return None
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        return doApply(exponent, output, rightIndex)
    }

    public func doApply(exponent: Int32, output: FormattedStringBuilder, rightIndex: Int32): Int32 {
        var i = rightIndex
        i += output.insert(i, symbols.getExponentSeparator(), NumberFormat_Field.EXPONENT_SYMBOL)
        if (exponent < 0 && !refEq(notation.exponentSignDisplay, NumberFormatter_SignDisplay.NEVER)) {
            i += output.insert(i, symbols.getMinusSignString(), NumberFormat_Field.EXPONENT_SIGN)
        } else if (exponent >= 0 && refEq(notation.exponentSignDisplay, NumberFormatter_SignDisplay.ALWAYS)) {
            i += output.insert(i, symbols.getPlusSignString(), NumberFormat_Field.EXPONENT_SIGN)
        }
        var disp = abs(exponent)
        var j = 0
        while (j < notation.minExponentDigits || disp > 0) {
            let d = disp % 10
            let digitString = symbols.getDigitStringsLocal()[Int64(d)]
            i += output.insert(i - j, digitString, NumberFormat_Field.EXPONENT)
            j++
            disp /= 10
        }
        return i - rightIndex
    }
}


class ScientificNotation_ScientificModifier <: Modifier {
    let exponent: Int32

    let handler: ScientificNotation_ScientificHandler

    init(exponent: Int32, handler: ScientificNotation_ScientificHandler) {
        this.exponent = exponent
        this.handler = handler
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        return handler.doApply(exponent, output, rightIndex)
    }

    public override func getPrefixLength(): Int32 {
        return 0
    }

    public override func getCodePointCount(): Int32 {
        return 999
    }

    public override func isStrong(): Bool {
        return true
    }

    public override func containsField(field: Format_Field): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    public override func getParameters(): Modifier_Parameters {
        return None
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!(checkOptionalIs<ScientificNotation_ScientificModifier, Modifier>(other))) {
            return false
        }
        let _other = other
        return exponent == _other.exponent
    }
}
