package icu4cj.number

public class SkeletonSyntaxException <: IllegalArgumentException {
    private static let serialVersionUID = 7733971331648360554

    public init(message: String, token: String) {
        super("Syntax error in skeleton string: " + (message) + ": " + (token))
    }

    public init(message: String, token: String, cause: Exception) {
        super("Syntax error in skeleton string: " + (message) + ": " + (token))
    }
}
