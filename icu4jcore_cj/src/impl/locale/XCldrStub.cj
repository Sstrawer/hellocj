package icu4cj.impl.locale


public class XCldrStub {

    public static func join<T>(source: Array<T>, separator: String): String {
        let result = StringBuilder()
        var i = 0
        while (i < Int32(source.size)) {
            if (i != 0) {
                result.append(separator)
            }
            result.append(source[Int64(i)])
            i++
        }
        return result.toString()
    }

    public static func join<T>(source: Iterable<T>, separator: String): String {
        let result = StringBuilder()
        var first = true
        for (item in source) {
            if (!first) {
                result.append(separator)
            } else {
                first = false
            }
            result.append(toString(item))
        }
        return result.toString()
    }
}


public class XCldrStub_Multimap<K, V> {
    private let map: Map<K, Set<V>>

    private let setClass: ClassTypeInfo

    init(map: Map<K, Set<V>>, setClass: ClassTypeInfo) {
        this.map = map
        this.setClass = if (setClass.isSome()) { setClass } else { TypeInfo.of<HashSet<Any>>() as ClassTypeInfo }
    }

    
    public func putAll(key: K, values: Array<V>): XCldrStub_Multimap<K, V> {
        if (Int32(values.size) != 0) {
            createSetIfMissing(key).putAll(values)
        }
        return this
    }

    public func putAll(key: K, values: Collection<V>): Unit {
        if (!values.isEmpty()) {
            createSetIfMissing(key).putAll(values)
        }
    }

    public func putAll(keys: Collection<K>, value: V): Unit {
        for (key in keys) {
            put(key, value)
        }
    }

    public func putAll(source: XCldrStub_Multimap<K, V>): Unit {
        for (entry in source.map.entrySet()) {
            putAll(entry.getKey(), entry.getValue())
        }
    }

    public func put(key: K, value: V): Unit {
        createSetIfMissing(key).put(value)
    }

    private func createSetIfMissing(key: K): Set<V> {
        var old = map.get(key)
        if (old.isNone()) {
            map.put(key, match (0) { case _ => old = getInstance(); old })
        }
        return old
    }

    private func getInstance(): Set<V> {
        try {
            return setClass.construct([0]) as Set<V>
        } catch (e: Exception) {
            throw ICUException(e)
        }
    }

    public func get(key: K): Set<V> {
        let result = map.get(key)
        return result
    }

    public func keySet(): Set<K> {
        return // Мapping is present but failed: SetCollectionView<K>(map.keys()) as Set<K>
    }

    public func asMap(): Map<K, Set<V>> {
        return map
    }

    public func values(): Set<V> {
        let values: Collection<Set<V>> = map.values()
        if (Int32(values.size) == 0) {
            return Collections.emptySet<<--> -->()
        }
        let result = getInstance()
        for (valueSet in values) {
            result.addAll(valueSet)
        }
        return result
    }

    public func size(): Int32 {
        return Int32(map.size)
    }

    public func entries(): Iterable<Map_Entry> {
        return XCldrStub_MultimapIterator<K, V>(map) as Iterable<Map_Entry>
    }

    public override func equals(obj: Object): Bool {
        return refEq(this, obj) || (obj.isSome() && refEq(TypeInfo.of(obj), TypeInfo.of(this)) && // Мapping is present but failed: refEq(map, obj.map))
    }

    public override func hashCode(): Int64 {
        return map.hashCode()
    }
}

public class XCldrStub_Multimaps {

    public static func invertFrom<K, V, R>(source: XCldrStub_Multimap<V, K>, target: R): R {
        for (entry in source.asMap().entrySet()) {
            target.putAll(entry.getValue(), entry.getKey())
        }
        return target
    }

    public static func invertFrom<K, V, R>(source: Map<V, K>, target: R): R {
        for (entry in source.entrySet()) {
            target.put(entry.getValue(), entry.getKey())
        }
        return target
    }

    public static func forMap<K, V>(map: Map<K, V>): Map<K, V> {
        return map
    }
}


class XCldrStub_MultimapIterator<K, V> {
    private let it1: Iterator<Map_Entry>

    private var it2: Iterator<V>

    private let entry = XCldrStub_ReusableEntry<K, V>()

    init(map: Map<K, Set<V>>) {
        it1 = map.entrySet().iterator()
    }

    public override func hasNext(): Bool {
        return it1.hasNext() || it2.isSome() && it2.hasNext()
    }

    public override func next(): Map_Entry {
        if (it2.isSome() && it2.hasNext()) {
            entry.value = it2.next()
        } else {
            let e = it1.next()
            entry.key = e.getKey()
            it2 = e.getValue().iterator()
        }
        return entry as Map_Entry
    }

    public override func iterator(): Iterator<Map_Entry> {
        return this as Iterator<Map_Entry>
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }
}

class XCldrStub_ReusableEntry<K, V> <: Map_Entry {

    var key: K

    var value: V

    public override func getKey(): K {
        return key
    }

    public override func getValue(): V {
        return value
    }

    public override func setValue(value: V): V {
        throw UnsupportedOperationException()
    }
}

public class XCldrStub_HashMultimap<K, V> <: XCldrStub_Multimap<K, V> {
    private init() {
        super(HashMap<K, Set<V>>() as Map<K, Set<V>>, TypeInfo.of<HashSet<Any>>() as ClassTypeInfo)
    }

    public static func create<K, V>(): XCldrStub_HashMultimap<K, V> {
        return XCldrStub_HashMultimap<K, V>()
    }
}

public class XCldrStub_TreeMultimap<K, V> <: XCldrStub_Multimap<K, V> {
    private init() {
        super(TreeMap() as Map<K, Set<V>>, TypeInfo.of<TreeSet>() as ClassTypeInfo)
    }

    public static func create<K, V>(): XCldrStub_TreeMultimap<K, V> {
        return XCldrStub_TreeMultimap<K, V>()
    }
}

public class XCldrStub_LinkedHashMultimap<K, V> <: XCldrStub_Multimap<K, V> {
    private init() {
        super(LinkedHashMap() as Map<K, Set<V>>, TypeInfo.of<LinkedHashSet>() as ClassTypeInfo)
    }

    public static func create<K, V>(): XCldrStub_LinkedHashMultimap<K, V> {
        return XCldrStub_LinkedHashMultimap<K, V>()
    }
}

public class XCldrStub_CollectionUtilities {

    public static func join<T, U>(source: U, separator: String): String {
        return XCldrStub.join(source, separator)
    }
}


public class XCldrStub_Joiner {
    private let separator: String

    private init(separator: String) {
        this.separator = separator
    }

    public static func on(separator: String): XCldrStub_Joiner {
        return XCldrStub_Joiner(separator)
    }

    public func join<T>(source: Array<T>): String {
        return XCldrStub.join(source, separator)
    }

    public func join<T>(source: Iterable<T>): String {
        return XCldrStub.join(source, separator)
    }
}


public class XCldrStub_Splitter {
    var pattern: Pattern = None

    var trimResults = false

    public init(c: Char) {
        this(Pattern.compile("\\Q" + c.toString() + "\\E"))
    }

    public init(p: Pattern) {
        pattern = p
    }

    public static func on(c: Char): XCldrStub_Splitter {
        return XCldrStub_Splitter(c)
    }

    public static func on(p: Pattern): XCldrStub_Splitter {
        return XCldrStub_Splitter(p)
    }

    public func splitToList(input: String): ArrayList<String> {
        let items = pattern.split(input)
        if (trimResults) {
            var i = 0
            while (i < Int32(items.size)) {
                items[Int64(i)] = items[Int64(i)].trimAscii()
                i++
            }
        }
        return ArrayList(items)
    }

    public func trimResultsMethod(): XCldrStub_Splitter {
        trimResults = true
        return this
    }

    public func split(input: String): Iterable<String> {
        return splitToList(input)
    }
}


public class XCldrStub_ImmutableSet {

    public static func copyOf<T>(values: Set<T>): Set<T> {
        return Collections.unmodifiableSet(LinkedHashSet(values) as Set<T>)
    }
}


public class XCldrStub_ImmutableMap {

    public static func copyOf<K, V>(values: Map<K, V>): Map<K, V> {
        return Collections.unmodifiableMap(LinkedHashMap(values) as Map<K, V>)
    }
}


public class XCldrStub_ImmutableMultimap {

    public static func copyOf<K, V>(values: XCldrStub_Multimap<K, V>): XCldrStub_Multimap<K, V> {
        let temp = LinkedHashMap()
        for (entry in values.asMap().entrySet()) {
            let value = entry.getValue()
            temp.put(entry.getKey(), if (value.size() == 1) { Collections.singleton(value.iterator().next()) } else { Collections.unmodifiableSet(LinkedHashSet(value) as Set<T>) })
        }
        return XCldrStub_Multimap<K, V>(Collections.unmodifiableMap(temp as Map<K, V>), None)
    }
}


public class XCldrStub_FileUtilities {

    public static let UTF8 = Charset.forName("utf-8")

    public static func openFile(class1: ClassTypeInfo, file: String): BufferedReader {
        return openFile(class1, file, UTF8)
    }

    public static func openFile(class1: ClassTypeInfo, file: String, charset: Charset): BufferedReader {
        var tempcharset = charset
        try {
            let resourceAsStream: InputStream = getInputStreamFromFile(file)
            if (tempcharset.isNone()) {
                tempcharset = UTF8
            }
            let reader = // Мapping is present but failed: StringReader<InputStream>(resourceAsStream, tempcharset)
            let bufferedReader = BufferedReader(reader, 1024 * 64)
            return bufferedReader
        } catch (e: Exception) {
            let className: String = if (class1.isNone()) { None } else { class1.getCanonicalName() }
            var canonicalName: String
            try {
                let relativeFileName = getRelativeFileName(class1, "../util/")
                canonicalName = File(relativeFileName).getCanonicalPath()
            } catch (e1: Exception) {
                throw ICUUncheckedIOException("Couldn't file: " + (file) + "; relative to class: " + (className), e)
            }
            throw ICUUncheckedIOException("Couldn't file " + (file) + "; in path " + (canonicalName) + "; relative to class: " + (className), e)
        }
    }

    public static func getRelativeFileName(class1: ClassTypeInfo, filename: String): String {
        let resource = if (class1.isNone()) { TypeInfo.of<XCldrStub_FileUtilities>().getResource(filename) } else { class1.getResource(filename) }
        let resourceString: String = toString(resource)
        if (resourceString.startsWith("file:")) {
            return resourceString[5..]
        } else if (resourceString.startsWith("jar:file:")) {
            return resourceString[9..]
        } else {
            throw ICUUncheckedIOException("File not found: " + (resourceString))
        }
    }
}


public class XCldrStub_RegexUtilities {

    public static func findMismatch(m: Matcher, s: String): Int32 {
        var i: Int32 = 0
        i = 1
        while (i < s.size) {
            let matches = m.reset(s.subSequence(0, i)).matches()
            if (!matches && !m.hitEnd()) {
                break
            }
            i++
        }
        return i - 1
    }

    public static func showMismatch(m: Matcher, s: String): String {
        let failPoint = findMismatch(m, s)
        let show: String = (s.subSequence(0, failPoint)) + "\u{2639}" + (s.subSequence(failPoint, s.size))
        return show
    }
}


public interface XCldrStub_Predicate<T> {
    func test(t: T): Bool
}