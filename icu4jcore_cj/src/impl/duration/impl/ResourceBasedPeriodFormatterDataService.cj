package icu4cj.impl.duration.impl


public class ResourceBasedPeriodFormatterDataService <: PeriodFormatterDataService & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private var availableLocales: Collection<String>

    private var lastData: PeriodFormatterData

    private var lastLocale: String

    private var cache: Map<String, PeriodFormatterData> = HashMap<String, PeriodFormatterData>()

    private static let PATH = "data/"

    private static let singleton = ResourceBasedPeriodFormatterDataService()

    public static func getInstance(): ResourceBasedPeriodFormatterDataService {
        return singleton
    }

    private init() {
        super()
        let localeNames = ArrayList<String>()
        let isTrue = ICUData.getRequiredStream(TypeInfo.of(this), PATH + "index.txt")
        try {
            let br = BufferedReader(// Мapping is present but failed: StringReader<InputStream>(isTrue, "UTF-8"))
            var string: String
            while ((match (0) { case _ => string = br.readLine(); string }).isSome()) {
                string = string.trimAscii()
                if (string.startsWith("#") || Int32(string.size) == 0) {
                    continue
                }
                localeNames.append(string)
            }
        } catch (e: IOException) {
            throw Exception("IO Error reading " + PATH + "index.txt: " + e.toString())
        } finally {
            try {
            } catch (ignored: IOException) { }
        }
        availableLocales = Collections.unmodifiableList(localeNames)
    }

    public override func get(localeName: String): PeriodFormatterData {
        var templocaleName = localeName
        let x = indexOfWrap(templocaleName.indexOf(UInt8(UInt32('@'))))
        if (x != -1) {
            templocaleName = templocaleName[0..Int64(x)]
        }
        synchronized (getMonitorByObject(this)) {
            if (lastLocale.isSome() && lastLocale.equals(templocaleName)) {
                return lastData
            }
            var ld = cache.get(templocaleName)
            if (ld.isNone()) {
                var ln = templocaleName
                while (!availableLocales.contains(ln)) {
                    let ix = indexOfWrap(ln.lastIndexOf("_"))
                    if (ix > -1) {
                        ln = ln[0..Int64(ix)]
                    } else if (!"test".equals(ln)) {
                        ln = "test"
                    } else {
                        ln = None
                        break
                    }
                }
                if (ln.isSome()) {
                    let name: String = PATH + "pfd_" + (ln) + ".xml"
                    try {
                        let reader = // Мapping is present but failed: StringReader<InputStream>(ICUData.getRequiredStream(TypeInfo.of(this), name), "UTF-8")
                        let dr = DataRecord.read(ln, XMLRecordReader(reader))
                        if (dr.isSome()) {
                            ld = PeriodFormatterData(templocaleName, dr)
                        }
                    } catch (e: UnsupportedEncodingException) {
                        throw MissingResourceException("Unhandled encoding for resource " + (name), name, "")
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException("Failed to close() resource " + (name), e)
                    }
                } else {
                    throw MissingResourceException("Duration data not found for  " + (templocaleName), PATH, templocaleName)
                }
                cache.put(templocaleName, ld)
            }
            lastData = ld
            lastLocale = templocaleName
            return ld
        }
    }

    public override func getAvailableLocales(): Collection<String> {
        return availableLocales
    }
}
