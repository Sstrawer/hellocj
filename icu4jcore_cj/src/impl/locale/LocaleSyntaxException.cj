package icu4cj.impl.locale

public class LocaleSyntaxException <: Exception {
    private static let serialVersionUID = 1

    private var _index = -1

    public init(msg: String) {
        this(msg, 0)
    }

    public init(msg: String, errorIndex: Int32) {
        super(msg)
        _index = errorIndex
    }

    public func getErrorIndex(): Int32 {
        return _index
    }
}
