package icu4cj.impl.breakiter


class CharsDictionaryMatcher <: DictionaryMatcher {
    private var characters: String

    public init(chars: String) {
        super()
        characters = chars
    }

    public override func matches(text_: CharacterIterator, maxLength: Int32, lengths: Array<Int32>, count_: Array<Int32>, limit: Int32, values: Array<Int32>): Int32 {
        let text = UCharacterIterator.getInstance(text_)
        let uct = CharsTrie(characters, 0)
        var c = text.nextCodePoint()
        if (c == UCharacterIterator.DONE) {
            return 0
        }
        var result = uct.firstForCodePoint(c)
        var numChars = 1
        var count = 0
        while (true) {
            if (result.hasValue()) {
                if (count < limit) {
                    if (values.isSome()) {
                        values[Int64(count)] = uct.getValue()
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
            result = uct.nextForCodePoint(c)
        }
        count_[0] = count
        return numChars
    }

    public override func getType(): Int32 {
        return DictionaryData.TRIE_TYPE_UCHARS
    }
}
