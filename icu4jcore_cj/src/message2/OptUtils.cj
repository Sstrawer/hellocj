package icu4cj.message2


class OptUtils {
    private init() { }

    static func asNumber(value: Object): Number {
        if (checkOptionalIs<Number, Object>(value)) {
            return value
        }
        if (value) {
            @AssertThrows[TimeParseException]({
                return parse<Float64>(toString(value))
            })
        }
        return None
    }

    static func getInteger(options: Map<String, Object>, key: String): Int32 {
        let value = options.get(key)
        if (value.isNone()) {
            return None
        }
        let nrValue = asNumber(value)
        if (nrValue.isSome()) {
            return nrValue.intValue()
        }
        return None
    }

    static func getString(options: Map<String, Object>, key: String, defaultVal: String): String {
        let value = options.get(key)
        if (value) {
            return toString(value)
        }
        return defaultVal
    }

    static func getString(options: Map<String, Object>, key: String): String {
        return getString(options, key, None)
    }
}
