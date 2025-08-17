package icu4cj.text

public interface Replaceable {
    func length(): Int32

    func charAt(offset: Int32): Char

    func char32At(offset: Int32): Int32

    func getChars(srcStart: Int32, srcLimit: Int32, dst: Array<Char>, dstStart: Int32): Unit

    func replace(start: Int32, limit: Int32, text: String): Unit

    func replace(start: Int32, limit: Int32, chars: Array<Char>, charsStart: Int32, charsLen: Int32): Unit

    func copy(start: Int32, limit: Int32, dest: Int32): Unit

    func hasMetaData(): Bool
}