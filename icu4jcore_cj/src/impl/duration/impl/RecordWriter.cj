package icu4cj.impl.duration.impl

interface RecordWriter {
    func open(title: String): Bool

    func close(): Bool

    func bool(name: String, value: Bool): Unit

    func boolArray(name: String, values: Array<Bool>): Unit

    func character(name: String, value: Char): Unit

    func characterArray(name: String, values: Array<Char>): Unit

    func namedIndex(name: String, names: Array<String>, value: Int32): Unit

    func namedIndexArray(name: String, names: Array<String>, values: Array<UInt8>): Unit

    func string(name: String, value: String): Unit

    func stringArray(name: String, values: Array<String>): Unit

    func stringTable(name: String, values: Array<Array<String>>): Unit
}