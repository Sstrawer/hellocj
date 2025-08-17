package icu4cj.util

public class ICUException <: Exception {
    private static let serialVersionUID = -3067399656455755650

    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    public init(cause: Exception) {
        super()
    }

    public init(message: String, cause: Exception) {
        super(message)
    }
}
