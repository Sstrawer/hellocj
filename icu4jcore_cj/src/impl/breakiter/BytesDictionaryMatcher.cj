package icu4cj.impl.breakiter


class BytesDictionaryMatcher <: DictionaryMatcher {
    private let characters: Array<UInt8>

    private let transform: Int32

    public init(chars: Array<UInt8>, transform: Int32) {
        super()
        characters = chars
        Assert.assrt((transform & DictionaryData.TRANSFORM_TYPE_MASK) == DictionaryData.TRANSFORM_TYPE_OFFSET)
        this.transform = transform
    }

    private func transformMethod(c: Int32): Int32 {
        if (c == 8205) {
            return 255
        } else if (c == 8204) {
            return 254
        }
        let delta = c - (transform & DictionaryData.TRANSFORM_OFFSET_MASK)
        if (delta < 0 || 253 < delta) {
            return -1
        }
        return delta
    }

    public override func matches(text_: CharacterIterator, maxLength: Int32, lengths: Array<Int32>, count_: Array<Int32>, limit: Int32, values: Array<Int32>): Int32 {
        let text = UCharacterIterator.getInstance(text_)
        let bt = BytesTrie(characters, 0)
        var c = text.nextCodePoint()
        if (c == UCharacterIterator.DONE) {
            return 0
        }
        var result = bt.first(transformMethod(c))
        var numChars = 1
        var count = 0
        while (true) {
            if (result.hasValue()) {
                if (count < limit) {
                    if (values.isSome()) {
                        values[Int64(count)] = bt.getValue()
                    }
                    lengths[Int64(count)] = numChars
                    count++
                }
                if (refEq(result, BytesTrie_Result.FINAL_VALUE)) {
                    break
                }
            } else if (refEq(result, BytesTrie_Result.NO_MATCH)) {
                break
            }
            if (numChars >= maxLength) {
                break
            }
            c = text.nextCodePoint()
            if (c == UCharacterIterator.DONE) {
                break
            }
            numChars++
            result = bt.next(transformMethod(c))
        }
        count_[0] = count
        return numChars
    }

    public override func getType(): Int32 {
        return DictionaryData.TRIE_TYPE_BYTES
    }
}
