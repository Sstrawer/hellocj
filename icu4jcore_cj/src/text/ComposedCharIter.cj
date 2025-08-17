package icu4cj.text


public class ComposedCharIter {
    
    public static let DONE = Char(Normalizer.DONE)

    
    public init() {
        this(false, 0)
    }

    
    public init(compat: Bool, options: Int32) {
        if (compat) {
            n2impl = Norm2AllModes.getNFKCInstance().impl
        } else {
            n2impl = Norm2AllModes.getNFCInstance().impl
        }
    }

    
    public func hasNext(): Bool {
        if (nextChar == Normalizer.DONE) {
            findNextChar()
        }
        return nextChar != Normalizer.DONE
    }

    
    public func next(): Char {
        if (nextChar == Normalizer.DONE) {
            findNextChar()
        }
        curChar = nextChar
        nextChar = Normalizer.DONE
        return Char(curChar)
    }

    
    public func decomposition(): String {
        if (decompBuf.isSome()) {
            return decompBuf
        } else {
            return ""
        }
    }

    private func findNextChar(): Unit {
        var c = curChar + 1
        decompBuf = None
        while (true) {
            if (c < 65535) {
                decompBuf = n2impl.getDecomposition(c)
                if (decompBuf.isSome()) {
                    break
                }
                c++
            } else {
                c = Normalizer.DONE
                break
            }
        }
        nextChar = c
    }

    private let n2impl: Normalizer2Impl

    private var decompBuf: String

    private var curChar = 0

    private var nextChar = Normalizer.DONE
}
