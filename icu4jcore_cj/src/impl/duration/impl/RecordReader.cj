package icu4cj.impl.duration.impl

interface RecordReader {
    func open(title: String): Bool

    func close(): Bool

    func bool(name: String): Bool

    func boolArray(name: String): Array<Bool>

    func character(name: String): Char

    func characterArray(name: String): Array<Char>

    func namedIndex(name: String, names: Array<String>): UInt8

    func namedIndexArray(name: String, names: Array<String>): Array<UInt8>

    func string(name: String): String

    func stringArray(name: String): Array<String>

    func stringTable(name: String): Array<Array<String>>
}