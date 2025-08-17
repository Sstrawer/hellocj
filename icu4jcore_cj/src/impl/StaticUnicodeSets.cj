package icu4cj.impl

public class StaticUnicodeSets {

    private static let unicodeSets = EnumMap(TypeInfo.of<StaticUnicodeSets_Key>() as ClassTypeInfo)

    public static func get(key: StaticUnicodeSets_Key): UnicodeSet {
        let candidate = unicodeSets.get(key)
        if (candidate.isNone()) {
            return UnicodeSet.EMPTY
        }
        return candidate
    }

    public static func chooseFrom(str: String, key1: StaticUnicodeSets_Key): StaticUnicodeSets_Key {
        return if (get(key1).contains(str)) { key1 } else { None }
    }

    public static func chooseFrom(str: String, key1: StaticUnicodeSets_Key, key2: StaticUnicodeSets_Key): StaticUnicodeSets_Key {
        return if (get(key1).contains(str)) { key1 } else { chooseFrom(str, key2) }
    }

    public static func chooseCurrency(str: String): StaticUnicodeSets_Key {
        if (get(StaticUnicodeSets_Key.DOLLAR_SIGN).contains(str)) {
            return StaticUnicodeSets_Key.DOLLAR_SIGN
        } else if (get(StaticUnicodeSets_Key.POUND_SIGN).contains(str)) {
            return StaticUnicodeSets_Key.POUND_SIGN
        } else if (get(StaticUnicodeSets_Key.RUPEE_SIGN).contains(str)) {
            return StaticUnicodeSets_Key.RUPEE_SIGN
        } else if (get(StaticUnicodeSets_Key.YEN_SIGN).contains(str)) {
            return StaticUnicodeSets_Key.YEN_SIGN
        } else if (get(StaticUnicodeSets_Key.WON_SIGN).contains(str)) {
            return StaticUnicodeSets_Key.WON_SIGN
        } else {
            return None
        }
    }

    private static func computeUnion(k1: StaticUnicodeSets_Key, k2: StaticUnicodeSets_Key): UnicodeSet {
        return UnicodeSet().addAll(get(k1)).addAll(get(k2)).freeze()
    }

    private static func computeUnion(k1: StaticUnicodeSets_Key, k2: StaticUnicodeSets_Key, k3: StaticUnicodeSets_Key): UnicodeSet {
        return UnicodeSet().addAll(get(k1)).addAll(get(k2)).addAll(get(k3)).freeze()
    }

    static func saveSet(key: StaticUnicodeSets_Key, unicodeSetPattern: String): Unit {
        if (!unicodeSets.get(key).isNone()) {
            throw AssertionError()
        }
        unicodeSets.put(key, UnicodeSet(unicodeSetPattern).freeze())
    }

}


public class StaticUnicodeSets_Key <: Enum<StaticUnicodeSets_Key> {
    public static let EMPTY = StaticUnicodeSets_Key("EMPTY", 0)

    public static let DEFAULT_IGNORABLES = StaticUnicodeSets_Key("DEFAULT_IGNORABLES", 1)

    public static let STRICT_IGNORABLES = StaticUnicodeSets_Key("STRICT_IGNORABLES", 2)

    public static let COMMA = StaticUnicodeSets_Key("COMMA", 3)

    public static let PERIOD = StaticUnicodeSets_Key("PERIOD", 4)

    public static let STRICT_COMMA = StaticUnicodeSets_Key("STRICT_COMMA", 5)

    public static let STRICT_PERIOD = StaticUnicodeSets_Key("STRICT_PERIOD", 6)

    public static let APOSTROPHE_SIGN = StaticUnicodeSets_Key("APOSTROPHE_SIGN", 7)

    public static let OTHER_GROUPING_SEPARATORS = StaticUnicodeSets_Key("OTHER_GROUPING_SEPARATORS", 8)

    public static let ALL_SEPARATORS = StaticUnicodeSets_Key("ALL_SEPARATORS", 9)

    public static let STRICT_ALL_SEPARATORS = StaticUnicodeSets_Key("STRICT_ALL_SEPARATORS", 10)

    public static let MINUS_SIGN = StaticUnicodeSets_Key("MINUS_SIGN", 11)

    public static let PLUS_SIGN = StaticUnicodeSets_Key("PLUS_SIGN", 12)

    public static let PERCENT_SIGN = StaticUnicodeSets_Key("PERCENT_SIGN", 13)

    public static let PERMILLE_SIGN = StaticUnicodeSets_Key("PERMILLE_SIGN", 14)

    public static let INFINITY_SIGN = StaticUnicodeSets_Key("INFINITY_SIGN", 15)

    public static let DOLLAR_SIGN = StaticUnicodeSets_Key("DOLLAR_SIGN", 16)

    public static let POUND_SIGN = StaticUnicodeSets_Key("POUND_SIGN", 17)

    public static let RUPEE_SIGN = StaticUnicodeSets_Key("RUPEE_SIGN", 18)

    public static let YEN_SIGN = StaticUnicodeSets_Key("YEN_SIGN", 19)

    public static let WON_SIGN = StaticUnicodeSets_Key("WON_SIGN", 20)

    public static let DIGITS = StaticUnicodeSets_Key("DIGITS", 21)

    public static let DIGITS_OR_ALL_SEPARATORS = StaticUnicodeSets_Key("DIGITS_OR_ALL_SEPARATORS", 22)

    public static let DIGITS_OR_STRICT_ALL_SEPARATORS = StaticUnicodeSets_Key("DIGITS_OR_STRICT_ALL_SEPARATORS", 23)

    private static func _values(): Array<StaticUnicodeSets_Key> {
        return [StaticUnicodeSets_Key.EMPTY, StaticUnicodeSets_Key.DEFAULT_IGNORABLES, StaticUnicodeSets_Key.STRICT_IGNORABLES, StaticUnicodeSets_Key.COMMA, StaticUnicodeSets_Key.PERIOD, StaticUnicodeSets_Key.STRICT_COMMA, StaticUnicodeSets_Key.STRICT_PERIOD, StaticUnicodeSets_Key.APOSTROPHE_SIGN, StaticUnicodeSets_Key.OTHER_GROUPING_SEPARATORS, StaticUnicodeSets_Key.ALL_SEPARATORS, StaticUnicodeSets_Key.STRICT_ALL_SEPARATORS, StaticUnicodeSets_Key.MINUS_SIGN, StaticUnicodeSets_Key.PLUS_SIGN, StaticUnicodeSets_Key.PERCENT_SIGN, StaticUnicodeSets_Key.PERMILLE_SIGN, StaticUnicodeSets_Key.INFINITY_SIGN, StaticUnicodeSets_Key.DOLLAR_SIGN, StaticUnicodeSets_Key.POUND_SIGN, StaticUnicodeSets_Key.RUPEE_SIGN, StaticUnicodeSets_Key.YEN_SIGN, StaticUnicodeSets_Key.WON_SIGN, StaticUnicodeSets_Key.DIGITS, StaticUnicodeSets_Key.DIGITS_OR_ALL_SEPARATORS, StaticUnicodeSets_Key.DIGITS_OR_STRICT_ALL_SEPARATORS]
    }

    private static let _VALUES = StaticUnicodeSets_Key._values()

    public static func values(): Array<StaticUnicodeSets_Key> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): StaticUnicodeSets_Key {
        return (TypeInfo.of<StaticUnicodeSets_Key>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as StaticUnicodeSets_Key
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class StaticUnicodeSets_ParseDataSink <: UResource_Sink {
    init() {
        super()
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let contextsTable = value.getTable()
        var i = 0
        while (contextsTable.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("date")) { } else {
                if (!(key.contentEquals("general") || key.contentEquals("number"))) {
                    throw AssertionError()
                }
                let strictnessTable = value.getTable()
                var j = 0
                while (strictnessTable.getKeyAndValue(j, key, value)) {
                    let isLenient = key.contentEquals("lenient")
                    let array = value.getArray()
                    var k = 0
                    while (k < array.getSize()) {
                        array.getValue(k, value)
                        let str: String = value.toString()
                        if (indexOfWrap(str.indexOf(UInt8(UInt32('.')))) != -1) {
                            StaticUnicodeSets.saveSet(if (isLenient) { StaticUnicodeSets_Key.PERIOD } else { StaticUnicodeSets_Key.STRICT_PERIOD }, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32(',')))) != -1) {
                            StaticUnicodeSets.saveSet(if (isLenient) { StaticUnicodeSets_Key.COMMA } else { StaticUnicodeSets_Key.STRICT_COMMA }, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('+')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.PLUS_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('-')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.MINUS_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('$')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.DOLLAR_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{00a3}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.POUND_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{20b9}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.RUPEE_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{00a5}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.YEN_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{20a9}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.WON_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('%')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.PERCENT_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{2030}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.PERMILLE_SIGN, str)
                        } else if (indexOfWrap(str.indexOf(UInt8(UInt32('\u{2019}')))) != -1) {
                            StaticUnicodeSets.saveSet(StaticUnicodeSets_Key.APOSTROPHE_SIGN, str)
                        } else {
                            throw Exception("Unknown class of parse lenients: " + (str))
                        }
                        k++
                    }
                    j++
                }
            }
            i++
        }
    }
}
