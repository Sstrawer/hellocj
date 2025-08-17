package icu4cj.util

public class ICUUncheckedIOException <: Exception {
    private static let serialVersionUID = 1210263498513384449

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
