package icu4cj.message2



public class MFParseException <: ParseException {
    private static let serialVersionUID = -7634219305388292407

    public init(message: String, errorOffset: Int32) {
        ParseException(message, errorOffset)
    }

    public override func getMessage(): String {
        return super.message
    }
}
