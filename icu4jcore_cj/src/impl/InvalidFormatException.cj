package icu4cj.impl

public class InvalidFormatException <: Exception {
    static let serialVersionUID = 8883328905089345791

    public init() {
        super()
    }

    public init(cause: Exception) {
        super()
    }

    public init(message: String) {
        super(message)
    }
}
