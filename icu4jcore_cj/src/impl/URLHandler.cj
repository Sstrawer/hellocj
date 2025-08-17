package icu4cj.impl


public abstract class URLHandler {

    public static let PROPNAME = "urlhandler.props"

    private static let handlers: Map<String, Method>

    static let DEBUG = ICUDebug.enabled("URLHandler")


    public static func get(url: URL): URLHandler {
        if (url.isNone()) {
            return None
        }
        let protocol = url.getProtocol()
        if (handlers.isSome()) {
            let m = handlers.get(protocol)
            if (m.isSome()) {
                try {
                    let handler = m.invoke(None, [url])
                    if (handler.isSome()) {
                        return handler
                    }
                } catch (e: IllegalAccessException) {
                    if (DEBUG) {
                        eprintln(toString(e))
                    }
                } catch (e: IllegalArgumentException) {
                    if (DEBUG) {
                        eprintln(e.toString())
                    }
                } catch (e: InvocationTargetException) {
                    if (DEBUG) {
                        eprintln(toString(e))
                    }
                }
            }
        }
        return getDefault(url)
    }

    protected static func getDefault(url: URL): URLHandler {
        var handler: URLHandler
        let protocol = url.getProtocol()
        try {
            if (protocol == "file") {
                handler = URLHandler_FileURLHandler(url)
            } else if (protocol == "jar" || protocol == "wsjar") {
                handler = URLHandler_JarURLHandler(url)
            }
        })
        return handler
    }

    public func guide(visitor: URLHandler_URLVisitor, recurse: Bool): Unit {
        guide(visitor, recurse, true)
    }

    public func guide(visitor: URLHandler_URLVisitor, recurse: Bool, strip: Bool): Unit
}


class URLHandler_FileURLHandler <: URLHandler {
    var file: File = None

    init(url: URL) {
        super()
        try {
            file = File(url.toURI())
        } catch (use: URISyntaxException) { }
        if (file.isNone() || !file.exists()) {
            if (URLHandler.DEBUG) {
                eprintln("file does not exist - " + toString(url))
            }
            throw IllegalArgumentException()
        }
    }

    public override func guide(v: URLHandler_URLVisitor, recurse: Bool, strip: Bool): Unit {
        if (file.isDirectory()) {
            process(v, recurse, strip, "/", file.listFiles())
        } else {
            v.visit(file.getName())
        }
    }

    private func process(v: URLHandler_URLVisitor, recurse: Bool, strip: Bool, path: String, files: Array<File>): Unit {
        if (files.isSome()) {
            var i = 0
            while (i < Int32(files.size)) {
                let f = files[Int64(i)]
                if (f.isDirectory()) {
                    if (recurse) {
                        process(v, recurse, strip, (path) + (f.getName()) + '/'.toString(), f.listFiles())
                    }
                } else {
                    v.visit(if (strip) { f.getName() } else { (path) + (f.getName()) })
                }
                i++
            }
        }
    }
}


class URLHandler_JarURLHandler <: URLHandler {
    var jarFile: JarFile = None

    var prefix: String

    init(url: URL) {
        super()
        var tempurl = url
        try {
            prefix = tempurl.getPath()
            let ix = indexOfWrap(prefix.lastIndexOf("!/"))
            if (ix >= 0) {
                prefix = prefix[Int64(ix + 2)..]
            }
            let protocol = tempurl.getProtocol()
            if (!(protocol == "jar")) {
                let urlStr: String = toString(tempurl)
                let idx = indexOfWrap(urlStr.indexOf(":"))
                if (idx != -1) {
                    tempurl = URL("jar" + urlStr[Int64(idx)..])
                }
            }
            let conn = tempurl.openConnection()
            jarFile = conn.getJarFile()
        } catch (e: Exception) {
            if (DEBUG) {
                eprintln("icurb jar error: " + e.toString())
            }
            throw IllegalArgumentException("jar error: " + e.message)
        }
    }

    public override func guide(v: URLHandler_URLVisitor, recurse: Bool, strip: Bool): Unit {
        try {
            let entries = jarFile.entries()
            while (entries.hasMoreElements()) {
                let entry = entries.nextElement()
                if (!entry.isDirectory()) {
                    var name = entry.getName()
                    if (name.startsWith(prefix)) {
                        name = name[prefix.size..]
                        let ix = indexOfWrap(name.lastIndexOf(UInt8(UInt32('/'))))
                        if (ix > 0 && !recurse) {
                            continue
                        }
                        if (strip && ix != -1) {
                            name = name[Int64(ix + 1)..]
                        }
                        v.visit(name)
                    }
                }
            }
        } catch (e: Exception) {
            if (DEBUG) {
                eprintln("icurb jar error: " + e.toString())
            }
        }
    }
}


public interface URLHandler_URLVisitor {
    func visit(str: String): Unit
}