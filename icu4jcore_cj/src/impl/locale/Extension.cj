package icu4cj.impl.locale

public class Extension {
    private var _key: Char = '\u{0000}'

    protected var _value: String

    protected init(key: Char) {
        _key = key
    }

    init(key: Char, value: String) {
        _key = key
        _value = value
    }

    public func getKey(): Char {
        return _key
    }

    public func getValue(): String {
        return _value
    }

    public func getID(): String {
        return _key.toString() + LanguageTag.SEP + (_value)
    }

    public override func toString(): String {
        return getID()
    }
}
