package icu4cj.util

public class IllformedLocaleException <: Exception {
    private static let serialVersionUID = 1

    private var _errIdx = -1

    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public init(message: String, errorIndex: Int32) {
        super((message) + (if (errorIndex < 0) { "" } else { " [at index " + errorIndex.toString() + "]" }))
        _errIdx = errorIndex
    }

    public func getErrorIndex(): Int32 {
        return _errIdx
    }
}
