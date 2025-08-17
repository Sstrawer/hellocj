package icu4cj.text

public class UnicodeDecompressor <: SCSU {
    private var fCurrentWindow = 0

    private var fOffsets: Array<Int32> = Array<Int32>(Int64(NUMWINDOWS)) { _ => 0 }

    private var fMode = SINGLEBYTEMODE

    private static let BUFSIZE = 3

    private var fBuffer: Array<UInt8> = Array<UInt8>(Int64(BUFSIZE)) { _ => 0 }

    private var fBufferLength = 0

    public init() {
        reset()
    }

    public static func decompressStatic(buffer: Array<UInt8>): String {
        let buf = decompressStatic(buffer, 0, Int32(buffer.size))
        return String(buf)
    }

    public static func decompressStatic(buffer: Array<UInt8>, start: Int32, limit: Int32): Array<Char> {
        let comp = UnicodeDecompressor()
        let len = max(2, 2 * (limit - start))
        let temp = Array<Char>(Int64(len)) { _ => '\u{0000}' }
        let charCount = comp.decompress(buffer, start, limit, None, temp, 0, len)
        let result = Array<Char>(Int64(charCount)) { _ => '\u{0000}' }
        arraycopy(temp, 0, result, 0, Int64(charCount))
        return result
    }

    public func decompress(byteBuffer: Array<UInt8>, byteBufferStart: Int32, byteBufferLimit: Int32, bytesRead: Array<Int32>, charBuffer: Array<Char>, charBufferStart: Int32, charBufferLimit: Int32): Int32 {
        var bytePos = byteBufferStart
        var ucPos = charBufferStart
        var aByte = 0
        if (Int32(charBuffer.size) < 2 || (charBufferLimit - charBufferStart) < 2) {
            throw IllegalArgumentException("charBuffer.length < 2")
        }
        if (fBufferLength > 0) {
            var newBytes = 0
            if (fBufferLength != BUFSIZE) {
                newBytes = Int32(fBuffer.size) - fBufferLength
                if (byteBufferLimit - byteBufferStart < newBytes) {
                    newBytes = byteBufferLimit - byteBufferStart
                }
                arraycopy(byteBuffer, Int64(byteBufferStart), fBuffer, Int64(fBufferLength), Int64(newBytes))
            }
            fBufferLength = 0
            let count = decompress(fBuffer, 0, Int32(fBuffer.size), None, charBuffer, charBufferStart, charBufferLimit)
            ucPos += count
            bytePos += newBytes
        }
    public func reset(): Unit {
        fOffsets[0] = 128
        fOffsets[1] = 192
        fOffsets[2] = 1024
        fOffsets[3] = 1536
        fOffsets[4] = 2304
        fOffsets[5] = 12352
        fOffsets[6] = 12448
        fOffsets[7] = 65280
        fCurrentWindow = 0
        fMode = SINGLEBYTEMODE
        fBufferLength = 0
    }
}
