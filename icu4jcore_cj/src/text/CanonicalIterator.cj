package icu4cj.text

public class CanonicalIterator {
    public init(source: String) {
        let allModes = Norm2AllModes.getNFCInstance()
        nfd = allModes.decomp
        nfcImpl = allModes.impl.ensureCanonIterData()
        setSource(source)
    }

    public func getSource(): String {
        return source
    }

    public func reset(): Unit {
        done = false
        var i = 0
        while (i < Int32(current.size)) {
            current[Int64(i)] = 0
            i++
        }
    }

    public func next(): String {
        if (done) {
            return None
        }
        buffer.setLength(0)
        } while (false)
        let result: String = buffer.toString()
                current[Int64(i)] += 1
                if (current[Int64(i)] < Int32(pieces[Int64(i)].size)) {
                    break
                }
                current[Int64(i)] = 0
                i--
            }
        } while (false)
        return result
    }

    public func setSource(newSource: String): Unit {
        source = nfd.normalize(newSource)
        done = false
        if (Int32(newSource.size) == 0) {
            pieces = Array<Array<String>>(1) { _ => Array<String>(0) }
            current = Array<Int32>(1) { _ => 0 }
            pieces[0] = [""]
            return
        }
        let segmentList = ArrayList<String>()
        var cp: Int32 = 0
        var start = 0
        var i = UTF16.findOffsetFromCodePoint(source, 1)
        while (i < Int32(source.size)) {
            cp = source.codePointAt(i)
            if (nfcImpl.isCanonSegmentStarter(cp)) {
                segmentList.append(source[Int64(start)..Int64(i)])
                start = i
            }
            i += Character.charCount(cp)
        }
        segmentList.append(source[Int64(start)..Int64(i)])
        pieces = Array<Array<String>>(segmentList.size) { _ => Array<String>(0) }
        current = Array<Int32>(segmentList.size) { _ => 0 }
        i = 0
        while (i < Int32(pieces.size)) {
            if (PROGRESS) {
                println("SEGMENT")
            }
            pieces[Int64(i)] = getEquivalents(segmentList[Int64(i)])
            i++
        }
    }

    
    public static func permute(source: String, skipZeros: Bool, output: Set<String>): Unit {
        permute(source, skipZeros, output, 0)
    }

    private static var PERMUTE_DEPTH_LIMIT = 8

    
    private static func permute(source: String, skipZeros: Bool, output: Set<String>, depth: Int32): Unit {
        if (depth > PERMUTE_DEPTH_LIMIT) {
            throw UnsupportedOperationException("Stack too deep:" + depth.toString())
        }
        if (Int32(source.size) <= 2 && UTF16.countCodePoint(source) <= 1) {
            output.put(source)
            return
        }
        let subpermute: Set<String> = HashSet<String>()
        var cp: Int32 = 0
        var i = 0
        while (i < Int32(source.size)) {
            cp = UTF16.toRuneArray()[source, i]
            if (skipZeros && i != 0 && UCharacter.getCombiningClass(cp) == 0) {
                continue
            }
            subpermute.clear()
            permute(source[0..Int64(i)] + source[Int64(i + UTF16.getCharCount(cp))..], skipZeros, subpermute, depth + 1)
            let chStr = UTF16.valueOf(source, i)
            for (s in subpermute) {
                let piece: String = (chStr) + (s)
                output.put(piece)
            }
            i += UTF16.getCharCount(cp)
        }
    }

    private static var PROGRESS = false

    private static var SKIP_ZEROS = true

    private let nfd: Normalizer2

    private let nfcImpl: Normalizer2Impl

    private var source: String

    private var done: Bool = false

    private var pieces: Array<Array<String>>

    private var current: Array<Int32>

     private var buffer: StringBuilder = StringBuilder()

    private func getEquivalents(segment: String): Array<String> {
        let result: Set<String> = HashSet<String>()
        let basic = getEquivalents2(segment)
        let permutations: Set<String> = HashSet<String>()
        let it: Iterator<String> = basic.iterator()
        while (it.hasNext()) {
            let item = it.next()
            permutations.clear()
            permute(item, SKIP_ZEROS, permutations)
            let it2: Iterator<String> = permutations.iterator()
            while (it2.hasNext()) {
                let possible = it2.next()
                if (Normalizer.compare(possible, segment, 0) == 0) {
                    if (PROGRESS) {
                        println("Adding Permutation: " + (Utility.hex(possible)))
                    }
                    result.put(possible)
                } else {
                    if (PROGRESS) {
                        println("-Skipping Permutation: " + (Utility.hex(possible)))
                    }
                }
            }
        }
        let finalResult = Array<String>(result.size)
        result.toArray(finalResult)
        return finalResult
    }

    private func getEquivalents2(segment: String): Set<String> {
        let result: Set<String> = HashSet<String>()
        if (PROGRESS) {
            println("Adding: " + (Utility.hex(segment)))
        }
        result.put(segment)
        let workingBuffer = StringBuffer()
        let starts = UnicodeSet()
        var cp: Int32 = 0
        var i = 0
        while (i < Int32(segment.size)) {
            cp = segment.codePointAt(i)
            if (!nfcImpl.getCanonStartSet(cp, starts)) {
                continue
            }
            let iter = UnicodeSetIterator(starts)
            while (iter.next()) {
                let cp2 = iter.codepoint
                let remainder = extract(cp2, segment, i, workingBuffer)
                if (remainder.isNone()) {
                    continue
                }
                var prefix: String = segment[0..Int64(i)]
                prefix += UTF16.valueOf(cp2)
                for (item in remainder) {
                    result.put((prefix) + (item))
                }
            }
            i += Character.charCount(cp)
        }
        return result
    }

    private func extract(comp: Int32, segment: String, segmentPos: Int32, buf: StringBuffer): Set<String> {
        if (PROGRESS) {
            println(" extract: " + (Utility.hex(UTF16.valueOf(comp))) + ", " + (Utility.hex(segment[Int64(segmentPos)..])))
        }
        var decomp = nfcImpl.getDecomposition(comp)
        if (decomp.isNone()) {
            decomp = UTF16.valueOf(comp)
        }
        var ok = false
        var cp: Int32 = 0
        var decompPos = 0
        var decompCp = UTF16.toRuneArray()[decomp, 0]
        decompPos += UTF16.getCharCount(decompCp)
        buf.setLength(0)
        var i = segmentPos
        while (i < Int32(segment.size)) {
            cp = UTF16.toRuneArray()[segment, i]
            if (cp == decompCp) {
                if (PROGRESS) {
                    println("  matches: " + (Utility.hex(UTF16.valueOf(cp))))
                }
                if (decompPos == Int32(decomp.size)) {
                    buf.append(segment[Int64(i + UTF16.getCharCount(cp))..])
                    ok = true
                    break
                }
                decompCp = UTF16.toRuneArray()[decomp, decompPos]
                decompPos += UTF16.getCharCount(decompCp)
            } else {
                if (PROGRESS) {
                    println("  buffer: " + (Utility.hex(UTF16.valueOf(cp))))
                }
                UTF16.append(buf, cp)
            }
            i += UTF16.getCharCount(cp)
        }
        if (!ok) {
            return None
        }
        if (PROGRESS) {
            println("Matches")
        }
        if (Int32(buf.size) == 0) {
            return SET_WITH_NULL_STRING
        }
        let remainder: String = toString(buf)
        if (0 != Normalizer.compare((UTF16.valueOf(comp)) + (remainder), segment[Int64(segmentPos)..], 0)) {
            return None
        }
        return getEquivalents2(remainder)
    }

    private static let SET_WITH_NULL_STRING: Set<String> = HashSet<String>()

}
