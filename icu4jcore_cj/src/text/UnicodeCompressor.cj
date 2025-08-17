package icu4cj.text

public class UnicodeCompressor <: SCSU {
    private static var sSingleTagTable: Array<Bool> = [false, true, true, true, true, true, true, true, true, false, false, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]

    private static var sUnicodeTagTable: Array<Bool> = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false]

    private var fCurrentWindow = 0

    private var fOffsets: Array<Int32> = Array<Int32>(Int64(NUMWINDOWS)) { _ => 0 }

    private var fMode = SINGLEBYTEMODE

    private var fIndexCount: Array<Int32> = Array<Int32>(Int64(MAXINDEX + 1)) { _ => 0 }

    private var fTimeStamps: Array<Int32> = Array<Int32>(Int64(NUMWINDOWS)) { _ => 0 }

    private var fTimeStamp = 0

    public init() {
        reset()
    }

    public static func compressStatic(buffer: String): Array<UInt8> {
        return compressStatic(buffer.toRuneArray(), 0, Int32(buffer.size))
    }

    public static func compressStatic(buffer: Array<Char>, start: Int32, limit: Int32): Array<UInt8> {
        let comp = UnicodeCompressor()
        let len = max(4, 3 * (limit - start) + 1)
        let temp = Array<UInt8>(Int64(len)) { _ => 0 }
        let byteCount = comp.compress(buffer, start, limit, None, temp, 0, len)
        let result = Array<UInt8>(Int64(byteCount)) { _ => 0 }
        arraycopy(temp, 0, result, 0, Int64(byteCount))
        return result
    }

    public func compress(charBuffer: Array<Char>, charBufferStart: Int32, charBufferLimit: Int32, charsRead: Array<Int32>, byteBuffer: Array<UInt8>, byteBufferStart: Int32, byteBufferLimit: Int32): Int32 {
        var bytePos = byteBufferStart
        var ucPos = charBufferStart
        var curUC = INVALIDCHAR
        var curIndex = -1
        var nextUC = INVALIDCHAR
        var forwardUC = INVALIDCHAR
        var whichWindow = 0
        var hiByte = 0
        var loByte = 0
        if (Int32(byteBuffer.size) < 4 || (byteBufferLimit - byteBufferStart) < 4) {
            throw IllegalArgumentException("byteBuffer.length < 4")
        }
    public func reset(): Unit {
        var i: Int32 = 0
        fOffsets[0] = 128
        fOffsets[1] = 192
        fOffsets[2] = 1024
        fOffsets[3] = 1536
        fOffsets[4] = 2304
        fOffsets[5] = 12352
        fOffsets[6] = 12448
        fOffsets[7] = 65280
        i = 0
        while (i < NUMWINDOWS) {
            fTimeStamps[Int64(i)] = 0
            i++
        }
        i = 0
        while (i <= MAXINDEX) {
            fIndexCount[Int64(i)] = 0
            i++
        }
        fTimeStamp = 0
        fCurrentWindow = 0
        fMode = SINGLEBYTEMODE
    }

    private static func makeIndex(c: Int32): Int32 {
        if (c >= 192 && c < 320) {
            return LATININDEX
        } else if (c >= 592 && c < 720) {
            return IPAEXTENSIONINDEX
        } else if (c >= 880 && c < 1008) {
            return GREEKINDEX
        } else if (c >= 1328 && c < 1424) {
            return ARMENIANINDEX
        } else if (c >= 12352 && c < 12448) {
            return HIRAGANAINDEX
        } else if (c >= 12448 && c < 12576) {
            return KATAKANAINDEX
        } else if (c >= 65376 && c < 65439) {
            return HALFWIDTHKATAKANAINDEX
        } else if (c >= 128 && c < 13312) {
            return (c / 128) & 255
        } else if (c >= 57344 && c <= 65535) {
            return ((c - 44032) / 128) & 255
        } else {
            return RESERVEDINDEX
        }
    }

    private func inDynamicWindow(c: Int32, whichWindow: Int32): Bool {
        return (c >= fOffsets[Int64(whichWindow)] && c < (fOffsets[Int64(whichWindow)] + 128))
    }

    private static func inStaticWindow(c: Int32, whichWindow: Int32): Bool {
        return (c >= sOffsets[Int64(whichWindow)] && c < (sOffsets[Int64(whichWindow)] + 128))
    }

    private static func isCompressible(c: Int32): Bool {
        return (c < 13312 || c >= 57344)
    }

    private func findDynamicWindow(c: Int32): Int32 {
        var i = NUMWINDOWS - 1
        while (i >= 0) {
            if (inDynamicWindow(c, i)) {
                fTimeStamps[Int64(i)] += 1
                return i
            }
            i--
        }
        return INVALIDWINDOW
    }

    private static func findStaticWindow(c: Int32): Int32 {
        var i = NUMSTATICWINDOWS - 1
        while (i >= 0) {
            if (inStaticWindow(c, i)) {
                return i
            }
            i--
        }
        return INVALIDWINDOW
    }

    private func getLRDefinedWindow(): Int32 {
        var leastRU = Int32.Max
        var whichWindow = INVALIDWINDOW
        var i = NUMWINDOWS - 1
        while (i >= 0) {
            if (fTimeStamps[Int64(i)] < leastRU) {
                leastRU = fTimeStamps[Int64(i)]
                whichWindow = i
            }
            i--
        }
        return whichWindow
    }
}
