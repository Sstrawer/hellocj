package icu4cj.util

public class Region <: Comparable<Region> {
    private static let GeneratedStaticLockObject = Monitor()

    private var id: String

    private var code: Int32 = 0

    private var Type: Region_RegionType

    private var containingRegion: Region

    private var containedRegions: Set<Region> = TreeSet() as Set<Region>

    private var preferredValues: ArrayList<Region>

    private static var regionDataIsLoaded = false

    private static var regionIDMap: Map<String, Region> = None

    private static var numericCodeMap: Map<Int32, Region> = None

    private static var regionAliases: Map<String, Region> = None

    private static var regions: ArrayList<Region>

    private static var availableRegions: ArrayList<Set<Region>>

    private static let UNKNOWN_REGION_ID = "ZZ"

    private static let OUTLYING_OCEANIA_REGION_ID = "QO"

    private static let WORLD_ID = "001"


    private static func loadRegionData(): Unit {
        synchronized (GeneratedStaticLockObject) {
            if (regionDataIsLoaded) {
                return
            }
            regionAliases = HashMap<String, Region>()
            regionIDMap = HashMap<String, Region>()
            numericCodeMap = HashMap<Int32, Region>()
            availableRegions = ArrayList<Set<Region>>(Region_RegionType.values().size)
            var metadataAlias: UResourceBundle
            var territoryAlias: UResourceBundle
            var codeMappings: UResourceBundle
            var idValidity: UResourceBundle
            var regionList: UResourceBundle
            var regionRegular: UResourceBundle
            var regionMacro: UResourceBundle
            var regionUnknown: UResourceBundle
            var worldContainment: UResourceBundle
            var territoryContainment: UResourceBundle
            var groupingContainment: UResourceBundle
            let metadata = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metadata", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            metadataAlias = metadata.get("alias")
            territoryAlias = metadataAlias.get("territory")
            let supplementalData = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            codeMappings = supplementalData.get("codeMappings")
            idValidity = supplementalData.get("idValidity")
            regionList = idValidity.get("region")
            regionRegular = regionList.get("regular")
            regionMacro = regionList.get("macroregion")
            regionUnknown = regionList.get("unknown")
            territoryContainment = supplementalData.get("territoryContainment")
            worldContainment = territoryContainment.get("001")
            groupingContainment = territoryContainment.get("grouping")
            let continentsArr = worldContainment.getStringArray()
            let continents = ArrayList(continentsArr)
            let groupings = groupingContainment.getKeys()
            let regionCodes = ArrayList<String>()
            let allRegions = ArrayList<String>()
            allRegions.appendAll(regionRegular.getStringArray())
            allRegions.appendAll(regionMacro.getStringArray())
            allRegions.append(regionUnknown.getString())
            for (r in allRegions) {
                let rangeMarkerLocation = indexOfWrap(r.indexOf("~"))
                if (rangeMarkerLocation > 0) {
                    let regionName = StringBuilder(r)
                    let endRange = regionName.get(Int64(rangeMarkerLocation + 1))
                    regionName.setLength(Int64(rangeMarkerLocation))
                    var lastChar = regionName.get(Int64(rangeMarkerLocation - 1))
                    while (lastChar <= endRange) {
                        let newRegion: String = regionName.toString()
                        regionCodes.append(newRegion)
                        lastChar++
                        regionName.insert(Int64(rangeMarkerLocation - 1), lastChar)
                    }
                } else {
                    regionCodes.append(r)
                }
            }
            regions = ArrayList<Region>(regionCodes.size)
            for (id in regionCodes) {
                let r = Region()
                r.id = id
                r.Type = Region_RegionType.TERRITORY
                regionIDMap.put(id, r)
                if (id.matches("[0-9]{3}")) {
                    r.code = parse<Int32>(id)
                    numericCodeMap.put(r.code, r)
                    r.Type = Region_RegionType.SUBCONTINENT
                } else {
                    r.code = -1
                }
                regions.append(r)
            }
                        let r: Region
                        if (regionIDMap.contains(aliasFrom)) {
                            r = regionIDMap.get(aliasFrom)
                        } else {
                            r = Region()
                            r.id = aliasFrom
                            regionIDMap.put(aliasFrom, r)
                            if (aliasFrom.matches("[0-9]{3}")) {
                                r.code = parse<Int32>(aliasFrom)
                                numericCodeMap.put(r.code, r)
                            } else {
                                r.code = -1
                            }
                            regions.append(r)
                        }
                        r.Type = Region_RegionType.DEPRECATED
                        let aliasToRegionStrings = ArrayList(<--(" ")) : ArrayList<T> => ArrayList<String> -->
                        r.preferredValues = ArrayList<Region>()
                        for (s in aliasToRegionStrings) {
                            if (regionIDMap.contains(s)) {
                                r.preferredValues.append(regionIDMap.get(s))
                            }
                        }
                    }
                    i++
                }
            } while (false)
                    }
                    i++
                }
            } while (false)
            var r: Region
            if (regionIDMap.contains(WORLD_ID)) {
                r = regionIDMap.get(WORLD_ID)
                r.Type = Region_RegionType.WORLD
            }
            if (regionIDMap.contains(UNKNOWN_REGION_ID)) {
                r = regionIDMap.get(UNKNOWN_REGION_ID)
                r.Type = Region_RegionType.UNKNOWN
            }
            for (continent in continents) {
                if (regionIDMap.contains(continent)) {
                    r = regionIDMap.get(continent)
                    r.Type = Region_RegionType.CONTINENT
                }
            }
            while (groupings.hasMoreElements()) {
                let grouping = groupings.nextElement()
                if (regionIDMap.contains(grouping)) {
                    r = regionIDMap.get(grouping)
                    r.Type = Region_RegionType.GROUPING
                }
            }
            if (regionIDMap.contains(OUTLYING_OCEANIA_REGION_ID)) {
                r = regionIDMap.get(OUTLYING_OCEANIA_REGION_ID)
                r.Type = Region_RegionType.SUBCONTINENT
            }
                    let parentRegion = regionIDMap.get(parent)
                            }
                            j++
                        }
                    } while (false)
                    i++
                }
            } while (false)
                            j++
                        }
                    } while (false)
                    i++
                }
            } while (false)
            } while (false)
            for (ar in regions) {
                let currentSet = availableRegions[Int64(ar.Type.ordinal)]
                currentSet.put(ar)
                availableRegions.set(Int64(ar.Type.ordinal), currentSet)
            }
            regionDataIsLoaded = true
        }
    }

    public static func getInstance(id: String): Region {
        if (id.isNone()) {
            throw NoneValueException()
        }
        loadRegionData()
        var r = regionIDMap.get(id)
        if (r.isNone()) {
            r = regionAliases.get(id)
        }
        if (r.isNone()) {
            throw IllegalArgumentException("Unknown region id: " + (id))
        }
        if (refEq(r.Type, Region_RegionType.DEPRECATED) && Int32(r.preferredValues.size) == 1) {
            r = r.preferredValues[0]
        }
        return r
    }

    public static func getInstance(code: Int32): Region {
        loadRegionData()
        var r = numericCodeMap.get(code)
        if (r.isNone()) {
            var pad: String = ""
            if (code < 10) {
                pad = "00"
            } else if (code < 100) {
                pad = "0"
            }
            let id: String = (pad) + code.toString()
            r = regionAliases.get(id)
        }
        if (r.isNone()) {
            throw IllegalArgumentException("Unknown region code: " + code.toString())
        }
        if (refEq(r.Type, Region_RegionType.DEPRECATED) && Int32(r.preferredValues.size) == 1) {
            r = r.preferredValues[0]
        }
        return r
    }

    public static func getAvailable(Type: Region_RegionType): Set<Region> {
        loadRegionData()
        return Collections.unmodifiableSet(availableRegions[Int64(Type.ordinal)])
    }

    public func getContainingRegion(): Region {
        loadRegionData()
        return containingRegion
    }

    public func getContainingRegion(Type: Region_RegionType): Region {
        loadRegionData()
        if (containingRegion.isNone()) {
            return None
        }
        if (refEq(containingRegion.Type, Type)) {
            return containingRegion
        } else {
            return containingRegion.getContainingRegion(Type)
        }
    }

    public func getContainedRegions(): Set<Region> {
        loadRegionData()
        return Collections.unmodifiableSet(containedRegions)
    }

    public func getContainedRegions(Type: Region_RegionType): Set<Region> {
        loadRegionData()
        let result = TreeSet()
        let cr = getContainedRegions()
        for (r in cr) {
            if (refEq(r.getType(), Type)) {
                result.put(r)
            } else {
                result.putAll(r.getContainedRegions(Type))
            }
        }
        return Collections.unmodifiableSet(result as Set<T>)
    }

    public func getPreferredValues(): ArrayList<Region> {
        loadRegionData()
        if (refEq(Type, Region_RegionType.DEPRECATED)) {
            return Collections.unmodifiableList(preferredValues)
        } else {
            return None
        }
    }

    public func contains(other: Region): Bool {
        loadRegionData()
        if (containedRegions.contains(other)) {
            return true
        } else {
            for (cr in containedRegions) {
                if (cr.contains(other)) {
                    return true
                }
            }
        }
        return false
    }

    public override func toString(): String {
        return id
    }

    public func getNumericCode(): Int32 {
        return code
    }

    public func getType(): Region_RegionType {
        return Type
    }

    public override func compareTo(other: Region): Int32 {
        return id.compare(other.id).value()
    }
}


public class Region_RegionType <: Enum<Region_RegionType> {
    public static let UNKNOWN = Region_RegionType("UNKNOWN", 0)

    public static let TERRITORY = Region_RegionType("TERRITORY", 1)

    public static let WORLD = Region_RegionType("WORLD", 2)

    public static let CONTINENT = Region_RegionType("CONTINENT", 3)

    public static let SUBCONTINENT = Region_RegionType("SUBCONTINENT", 4)

    public static let GROUPING = Region_RegionType("GROUPING", 5)

    public static let DEPRECATED = Region_RegionType("DEPRECATED", 6)

    private static func _values(): Array<Region_RegionType> {
        return [Region_RegionType.UNKNOWN, Region_RegionType.TERRITORY, Region_RegionType.WORLD, Region_RegionType.CONTINENT, Region_RegionType.SUBCONTINENT, Region_RegionType.GROUPING, Region_RegionType.DEPRECATED]
    }

    private static let _VALUES = Region_RegionType._values()

    public static func values(): Array<Region_RegionType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Region_RegionType {
        return (TypeInfo.of<Region_RegionType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Region_RegionType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
