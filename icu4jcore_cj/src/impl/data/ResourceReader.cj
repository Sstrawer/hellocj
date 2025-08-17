package icu4cj.impl.data


public class ResourceReader <: Closeable {
    private var reader: BufferedReader = None

    private var resourceName: String

    private var encoding: String

    private var root: ClassTypeInfo

    private var lineNo: Int32 = 0

    public init(resourceName: String, encoding: String) {
        this(TypeInfo.of<ICUData>() as ClassTypeInfo, "data/" + (resourceName), encoding)
    }

    public init(resourceName: String) {
        this(TypeInfo.of<ICUData>() as ClassTypeInfo, "data/" + (resourceName))
    }

    public init(rootClass: ClassTypeInfo, resourceName: String, encoding: String) {
        this.root = rootClass
        this.resourceName = resourceName
        this.encoding = encoding
        lineNo = -1
        _reset()
    }

    public init(isTrue: InputStream, resourceName: String, encoding: String) {
        this.root = None
        this.resourceName = resourceName
        this.encoding = encoding
        this.lineNo = -1
        @AssertThrows[IOException]({
            let isr: StringReader<InputStream> = if (encoding.isNone()) { StringReader<InputStream>(isTrue) } else { // Мapping is present but failed: StringReader<InputStream>(isTrue, encoding) }
            this.reader = BufferedReader(isr)
            this.lineNo = 0
        } catch (e: UnsupportedEncodingException) { }
    }

    public init(isTrue: InputStream, resourceName: String) {
        this(isTrue, resourceName, None)
    }

    public init(rootClass: ClassTypeInfo, resourceName: String) {
        this.root = rootClass
        this.resourceName = resourceName
        this.encoding = None
        lineNo = -1
        try {
            _reset()
        } catch (e: UnsupportedEncodingException) { }
    }

    public func readLine(): String {
        if (lineNo == 0) {
            lineNo++
            var line = reader.readLine()
            if (line.isSome() && (Char(line[0]) == '\u{ffef}' || Char(line[0]) == '\u{feff}')) {
                line = line[1..]
            }
            return line
        }
        lineNo++
        return reader.readLine()
    }

    public func readLineSkippingComments(trim: Bool): String {
        while (true) {
            var line = readLine()
            if (line.isNone()) {
                return line
            }
            let pos = PatternProps.skipWhiteSpace(line, 0)
            if (pos == Int32(line.size) || Char(line[Int64(pos)]) == '#') {
                continue
            }
            if (trim) {
                line = line[Int64(pos)..]
            }
            return line
        }
    }

    public func readLineSkippingComments(): String {
        return readLineSkippingComments(false)
    }

    public func getLineNumber(): Int32 {
        return lineNo
    }

    public func describePosition(): String {
        return (resourceName) + ':'.toString() + lineNo.toString()
    }

    public func reset(): Unit {
        try {
            _reset()
        } catch (e: UnsupportedEncodingException) { }
    }

    private func _reset(): Unit {
        try {
            close()
        })
        if (lineNo == 0) {
            return
        }
        let isTrue = ICUData.getStream(root, resourceName)
        if (isTrue.isNone()) {
            throw IllegalArgumentException("Can't " + (resourceName))
        }
        let isr: StringReader<InputStream> = if (encoding.isNone()) { StringReader<InputStream>(isTrue) } else { // Мapping is present but failed: StringReader<InputStream>(isTrue, encoding) }
        reader = BufferedReader(isr)
        lineNo = 0
    }

    public override func close(): Unit {
        if (reader.isSome()) {
            reader = None
        }
    }
}
