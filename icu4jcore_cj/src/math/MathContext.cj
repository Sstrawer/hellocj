package icu4cj.math


public class MathContext <: Serializable {
    public static let PLAIN = 0

    public static let SCIENTIFIC = 1

    public static let ENGINEERING = 2

    public static let ROUND_CEILING = 2

    public static let ROUND_DOWN = 1

    public static let ROUND_FLOOR = 3

    public static let ROUND_HALF_DOWN = 5

    public static let ROUND_HALF_EVEN = 6

    public static let ROUND_HALF_UP = 4

    public static let ROUND_UNNECESSARY = 7

    public static let ROUND_UP = 0

    var digits: Int32 = 0

    var form: Int32 = 0

    var lostDigits: Bool = false

    var roundingMode: Int32 = 0

    private static let DEFAULT_FORM = SCIENTIFIC

    private static let DEFAULT_DIGITS = 9

    private static let DEFAULT_LOSTDIGITS = false

    private static let DEFAULT_ROUNDINGMODE = ROUND_HALF_UP

    private static let MIN_DIGITS = 0

    private static let MAX_DIGITS = 999999999

    private static let ROUNDS = [ROUND_HALF_UP, ROUND_UNNECESSARY, ROUND_CEILING, ROUND_DOWN, ROUND_FLOOR, ROUND_HALF_DOWN, ROUND_HALF_EVEN, ROUND_UP]

    private static let ROUNDWORDS: Array<String> = ["ROUND_HALF_UP", "ROUND_UNNECESSARY", "ROUND_CEILING", "ROUND_DOWN", "ROUND_FLOOR", "ROUND_HALF_DOWN", "ROUND_HALF_EVEN", "ROUND_UP"]

    private static let serialVersionUID = 7163376998892515376

    public static let DEFAULT = MathContext(DEFAULT_DIGITS, DEFAULT_FORM, DEFAULT_LOSTDIGITS, DEFAULT_ROUNDINGMODE)

    public init(setdigits: Int32) {
        this(setdigits, DEFAULT_FORM, DEFAULT_LOSTDIGITS, DEFAULT_ROUNDINGMODE)
        return
    }

    public init(setdigits: Int32, setform: Int32) {
        this(setdigits, setform, DEFAULT_LOSTDIGITS, DEFAULT_ROUNDINGMODE)
        return
    }

    public init(setdigits: Int32, setform: Int32, setlostdigits: Bool) {
        this(setdigits, setform, setlostdigits, DEFAULT_ROUNDINGMODE)
        return
    }

    public init(setdigits: Int32, setform: Int32, setlostdigits: Bool, setroundingmode: Int32) {
        if (setdigits != DEFAULT_DIGITS) {
            if (setdigits < MIN_DIGITS) {
                throw IllegalArgumentException("Digits too small: " + setdigits.toString())
            }
            if (setdigits > MAX_DIGITS) {
                throw IllegalArgumentException("Digits too large: " + setdigits.toString())
            }
        }
        if (!(isValidRound(setroundingmode))) {
            throw IllegalArgumentException("Bad roundingMode value: " + setroundingmode.toString())
        }
        digits = setdigits
        form = setform
        lostDigits = setlostdigits
        roundingMode = setroundingmode
        return
    }

    public func getDigits(): Int32 {
        return digits
    }

    public func getForm(): Int32 {
        return form
    }

    public func getLostDigits(): Bool {
        return lostDigits
    }

    public func getRoundingMode(): Int32 {
        return roundingMode
    }

    public override func toString(): String {
        var formstr: String
        var r = 0
        var roundword: String
                formstr = "ENGINEERING"
            } else {
                formstr = "PLAIN"
            }
                _2--
                r++
            }
        return false
    }
}
