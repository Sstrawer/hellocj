package icu4cj.message2


class TextSelectorFactory <: SelectorFactory {
    init() { }

    public override func createSelector(locale: Locale, fixedOptions: Map<String, Object>): Selector {
        return TextSelectorFactory_TextSelector()
    }
}


class TextSelectorFactory_TextSelector <: Selector {
    init() { }

    public override func matches(value: Object, keys: ArrayList<String>, variableOptions: Map<String, Object>): ArrayList<String> {
        let result = ArrayList<String>()
        if (value.isNone()) {
            return result
        }
        for (key in keys) {
            if (matches(value, key)) {
                result.append(key)
            }
        }
        result.sort(// Unimplemented feature MEMBER_REFERENCE: String::compareTo)
        return result
    }

    private func matches(value: Object, key: String): Bool {
        if ("*".equals(key)) {
            return true
        }
        return key.equals(Objects.toString(value))
    }
}
