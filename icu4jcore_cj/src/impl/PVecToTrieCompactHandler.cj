package icu4cj.impl

public class PVecToTrieCompactHandler <: PropsVectors_CompactHandler {

    public var builder: IntTrieBuilder

    public var initialValue: Int32 = 0

    public override func setRowIndexForErrorValue(rowIndex: Int32): Unit { }

    public override func setRowIndexForInitialValue(rowIndex: Int32): Unit {
        initialValue = rowIndex
    }

    public override func setRowIndexForRange(start: Int32, end: Int32, rowIndex: Int32): Unit {
        builder.setRange(start, end + 1, rowIndex, true)
    }

    public override func startRealValues(rowIndex: Int32): Unit {
        if (rowIndex > 65535) {
            throw IndexOutOfBoundsException()
        } else {
            builder = IntTrieBuilder(None, 100000, initialValue, initialValue, false)
        }
    }
}
