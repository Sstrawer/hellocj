package icu4cj.util

public class ICUInputTooLongException <: ICUException {
    private static let serialVersionUID = -2602876786689338226

    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public init(cause: Exception) {
        super(cause)
    }

    public init(message: String, cause: Exception) {
        super(message, cause)
    }
}
