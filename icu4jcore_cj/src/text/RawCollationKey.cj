package icu4cj.text


public class RawCollationKey <: ByteArrayWrapper {
    public init() {
        super()
    }

    public init(capacity: Int32) {
        super()
        bytes = Array<UInt8>(Int64(capacity)) { _ => 0 }
    }

    public init(bytes: Array<UInt8>) {
        super()
        this.bytes = bytes
    }

    public init(bytesToAdopt: Array<UInt8>, size: Int32) {
        super(bytesToAdopt, size)
    }

    public func compareTo(rhs: RawCollationKey): Int32 {
        let result = super.compareTo(rhs)
        return if (result < 0) { -1 } else { if (result == 0) { 0 } else { 1 } }
    }
}
