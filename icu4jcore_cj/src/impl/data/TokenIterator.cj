package icu4cj.impl.data


public class TokenIterator {
    private var reader: ResourceReader

    private var line: String

    private var buf: StringBuffer = None

    private var done: Bool = false

    private var pos: Int32 = 0

    private var lastpos: Int32 = 0

    public init(r: ResourceReader) {
        reader = r
        line = None
        done = false
        buf = StringBuffer()
        pos = match (0) { case _ => lastpos = -1; lastpos }
    }

    public func next(): String {
        if (done) {
            return None
        }
        while (true) {
            if (line.isNone()) {
                line = reader.readLineSkippingComments()
                if (line.isNone()) {
                    done = true
                    return None
                }
                pos = 0
            }
            buf.setLength(0)
            lastpos = pos
            pos = nextToken(pos)
            if (pos < 0) {
                line = None
                continue
            }
            return toString(buf)
        }
    }

    public func getLineNumber(): Int32 {
        return reader.getLineNumber()
    }

    public func describePosition(): String {
        return (reader.describePosition()) + ':'.toString() + ((lastpos + 1).toString())
    }

    private func nextToken(position: Int32): Int32 {
        var tempposition = position
        tempposition = PatternProps.skipWhiteSpace(line, tempposition)
        if (tempposition == Int32(line.size)) {
            return -1
        }
        let startpos = tempposition
        var c = Char(line[Int64(match (0) { case _ => tempposition++; tempposition - 1 })])
        var `quote` = Char(0)
        match (c) {
            case '\"' | ''' => `quote` = c
            case '#' => return -1
            case _ => buf.append(c)
        }
        while (tempposition < Int32(line.size)) {
            c = Char(line[Int64(tempposition)])
            if (c == '\') {
                let cpAndLength = Utility.unescapeAndLengthAt(line, tempposition + 1)
                if (cpAndLength < 0) {
                    throw Exception("Invalid escape at " + (reader.describePosition()) + ':'.toString() + tempposition.toString())
                }
                UTF16.append(buf, Utility.cpFromCodePointAndLength(cpAndLength))
                tempposition += 1 + Utility.lengthFromCodePointAndLength(cpAndLength)
            } else if ((Int32(UInt32(`quote`)) != 0 && c == `quote`) || (Int32(UInt32(`quote`)) == 0 && PatternProps.isWhiteSpace(Int32(UInt32(c))))) {
                return match (0) { case _ => tempposition++; tempposition }
            } else if (Int32(UInt32(`quote`)) == 0 && c == '#') {
                return tempposition
            } else {
                buf.append(c)
                tempposition++
            }
        }
        if (Int32(UInt32(`quote`)) != 0) {
            throw Exception("Unterminated quote at " + (reader.describePosition()) + ':'.toString() + startpos.toString())
        }
        return tempposition
    }
}
