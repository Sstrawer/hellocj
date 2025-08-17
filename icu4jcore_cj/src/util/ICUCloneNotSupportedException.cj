package icu4cj.util

public class ICUCloneNotSupportedException <: ICUException {
    private static let serialVersionUID = -4824446458488194964

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
