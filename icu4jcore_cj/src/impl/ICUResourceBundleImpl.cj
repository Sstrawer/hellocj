package icu4cj.impl

class ICUResourceBundleImpl <: ICUResourceBundle {
    protected var resource: Int32 = 0

    protected init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key)
        this.resource = resource
    }

    init(wholeBundle: ICUResourceBundle_WholeBundle) {
        super(wholeBundle)
        resource = wholeBundle.reader.getRootResource()
    }

    public func getResource(): Int32 {
        return resource
    }

    protected func createBundleObject(_key: String, _resource: Int32, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): ICUResourceBundle {
        match (ICUResourceBundleReader.RES_GET_TYPE(_resource)) {
            case 0 | 6 => return ICUResourceBundleImpl_ResourceString(this, _key, _resource)
            case 1 => return ICUResourceBundleImpl_ResourceBinary(this, _key, _resource)
            case 3 => return getAliasedResource(this, None, 0, _key, _resource, aliasesVisited, requested)
            case 7 => return ICUResourceBundleImpl_ResourceInt(this, _key, _resource)
            case 14 => return ICUResourceBundleImpl_ResourceIntVector(this, _key, _resource)
            case 8 | 9 => return ICUResourceBundleImpl_ResourceArray(this, _key, _resource)
            case 2 | 5 | 4 => return ICUResourceBundleImpl_ResourceTable(this, _key, _resource)
            case _ => throw Exception("The resource type is unknown")
        }
    }
}


class ICUResourceBundleImpl_ResourceBinary <: ICUResourceBundleImpl {
    public override func getType(): Int32 {
        return BINARY
    }

    public override func getBinary(): ByteArrayStream {
        return wholeBundle.reader.getBinary(resource)
    }

    public override func getBinary(ba: Array<UInt8>): Array<UInt8> {
        return wholeBundle.reader.getBinary(resource, ba)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
    }
}


class ICUResourceBundleImpl_ResourceInt <: ICUResourceBundleImpl {
    public override func getType(): Int32 {
        return INT
    }

    public override func getInt(): Int32 {
        return ICUResourceBundleReader.RES_GET_INT(resource)
    }

    public override func getUInt(): Int32 {
        return ICUResourceBundleReader.RES_GET_UINT(resource)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
    }
}


class ICUResourceBundleImpl_ResourceString <: ICUResourceBundleImpl {
    private var value: String

    public override func getType(): Int32 {
        return STRING
    }

    public override func getString(): String {
        if (value.isSome()) {
            return value
        }
        return wholeBundle.reader.getString(resource)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
        let s = wholeBundle.reader.getString(resource)
        if (Int32(s.size) < ICUResourceBundleReader.LARGE_SIZE / 2 || CacheValue.futureInstancesWillBeStrong()) {
            value = s
        }
    }
}


class ICUResourceBundleImpl_ResourceIntVector <: ICUResourceBundleImpl {
    public override func getType(): Int32 {
        return INT_VECTOR
    }

    public override func getIntVector(): Array<Int32> {
        return wholeBundle.reader.getIntVector(resource)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
    }
}


abstract class ICUResourceBundleImpl_ResourceContainer <: ICUResourceBundleImpl {
    protected var value: ICUResourceBundleReader_Container

    public override func getSize(): Int32 {
        return value.getSize()
    }

    public override func getString(index: Int32): String {
        let res = value.getContainerResource(wholeBundle.reader, index)
        if (res == RES_BOGUS) {
            throw IndexOutOfBoundsException()
        }
        let s = wholeBundle.reader.getString(res)
        if (s.isSome()) {
            return s
        }
        return super.getString(index)
    }

    protected func getContainerResource(index: Int32): Int32 {
        return value.getContainerResource(wholeBundle.reader, index)
    }

    protected func createBundleObject(index: Int32, resKey: String, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        let item = getContainerResource(index)
        if (item == RES_BOGUS) {
            throw IndexOutOfBoundsException()
        }
        return createBundleObject(resKey, item, aliasesVisited, requested)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
    }

    init(wholeBundle: ICUResourceBundle_WholeBundle) {
        super(wholeBundle)
    }
}


class ICUResourceBundleImpl_ResourceArray <: ICUResourceBundleImpl_ResourceContainer {
    public override func getType(): Int32 {
        return ARRAY
    }

    override protected func handleGetStringArray(): Array<String> {
        let reader = wholeBundle.reader
        let length = value.getSize()
        let strings = Array<String>(Int64(length))
        var i = 0
        while (i < length) {
            let s = reader.getString(value.getContainerResource(reader, i))
            if (s.isNone()) {
                throw UResourceTypeMismatchException("")
            }
            strings[Int64(i)] = s
            i++
        }
        return strings
    }

    public override func getStringArray(): Array<String> {
        return handleGetStringArray()
    }

    override protected func handleGet(indexStr: String, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        let i = parse<Int32>(indexStr)
        return createBundleObject(i, indexStr, aliasesVisited, requested)
    }

    override protected func handleGet(index: Int32, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        return createBundleObject(index, index.toString(), aliasesVisited, requested)
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
        value = wholeBundle.reader.getArray(resource)
    }
}


class ICUResourceBundleImpl_ResourceTable <: ICUResourceBundleImpl_ResourceContainer {
    public override func getType(): Int32 {
        return TABLE
    }

    protected func getKey(index: Int32): String {
        return value.getKey(wholeBundle.reader, index)
    }

    override protected func handleKeySet(): Set<String> {
        let reader = wholeBundle.reader
        let keySet = TreeSet()
        let table = value
        var i = 0
        while (i < table.getSize()) {
            keySet.put(table.getKey(reader, i))
            i++
        }
        return keySet as Set<String>
    }

    override protected func handleGet(resKey: String, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        let i = value.findTableItem(wholeBundle.reader, resKey)
        if (i < 0) {
            return None
        }
        return createBundleObject(resKey, getContainerResource(i), aliasesVisited, requested)
    }

    override protected func handleGet(index: Int32, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        let itemKey = value.getKey(wholeBundle.reader, index)
        if (itemKey.isNone()) {
            throw IndexOutOfBoundsException()
        }
        return createBundleObject(itemKey, getContainerResource(index), aliasesVisited, requested)
    }

    override protected func handleGetObject(key: String): Object {
        let reader = wholeBundle.reader
        let index = value.findTableItem(reader, key)
        if (index >= 0) {
            let res = value.getContainerResource(reader, index)
            var s = reader.getString(res)
            if (s.isSome()) {
                return s
            }
            let array = reader.getArray(res)
            if (array.isSome()) {
                let length = array.getSize()
                let strings = Array<String>(Int64(length))
                var j = 0
                while (true) {
                    if (j == length) {
                        return strings
                    }
                    s = reader.getString(array.getContainerResource(reader, j))
                    if (s.isNone()) {
                        break
                    }
                    strings[Int64(j)] = s
                    j++
                }
            }
        }
        return super.handleGetObject(key)
    }

    public func findString(key: String): String {
        let reader = wholeBundle.reader
        let index = value.findTableItem(reader, key)
        if (index < 0) {
            return None
        }
        return reader.getString(value.getContainerResource(reader, index))
    }

    init(container: ICUResourceBundleImpl, key: String, resource: Int32) {
        super(container, key, resource)
        value = wholeBundle.reader.getTable(resource)
    }

    init(wholeBundle: ICUResourceBundle_WholeBundle, rootRes: Int32) {
        super(wholeBundle)
        value = wholeBundle.reader.getTable(rootRes)
    }
}
