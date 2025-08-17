package icu4cj.impl.locale

public class ParseStatus {

    var _parseLength = 0

    var _errorIndex = -1

    var _errorMsg: String

    public func reset(): Unit {
        _parseLength = 0
        _errorIndex = -1
        _errorMsg = None
    }

    public func isError(): Bool {
        return (_errorIndex >= 0)
    }

    public func getErrorIndex(): Int32 {
        return _errorIndex
    }

    public func getParseLength(): Int32 {
        return _parseLength
    }

    public func getErrorMessage(): String {
        return _errorMsg
    }
}
