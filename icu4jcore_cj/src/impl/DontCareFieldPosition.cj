package icu4cj.impl

public class DontCareFieldPosition <: FieldPosition {
    public static let INSTANCE = DontCareFieldPosition()

    private init() {
        FieldPosition(-913028704)
    }

    public override func setBeginIndex(i: Int32): Unit { }

    public override func setEndIndex(i: Int32): Unit { }
}
