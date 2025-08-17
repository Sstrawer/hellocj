package icu4cj.impl


public class CalendarAstronomer {
    public static let SIDEREAL_DAY = 23.93446960027

    public static let SOLAR_DAY = 24.065709816

    public static let SYNODIC_MONTH = 29.530588853

    public static let SIDEREAL_MONTH = 27.32166

    public static let TROPICAL_YEAR = 365.242191

    public static let SIDEREAL_YEAR = 365.25636

    public static let SECOND_MS = 1000

    public static let MINUTE_MS = 60 * SECOND_MS

    public static let HOUR_MS = 60 * MINUTE_MS

    public static let DAY_MS = Int64(24 * HOUR_MS)

    public static let JULIAN_EPOCH_MS = -210866760000000

    static let EPOCH_2000_MS = 946598400000

    private static let PI = 3.141592653589793

    private static let PI2 = PI * 2.0

    private static let RAD_HOUR = 12.0 / PI

    private static let DEG_RAD = PI / 180.0

    static let RAD_DEG = 180.0 / PI

    public init() {
        this(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    public init(aTime: Int64) {
        time = aTime
    }

    public func setTime(aTime: Int64): Unit {
        time = aTime
        clearCache()
    }

    public func setJulianDay(jdn: Float64): Unit {
        time = Int64(jdn * Float64(DAY_MS)) + JULIAN_EPOCH_MS
        clearCache()
        julianDay = jdn
    }

    public func getTime(): Int64 {
        return time
    }

    public func getDate(): DateTime {
        return Date(time)
    }

    public func getJulianDay(): Float64 {
        if (julianDay == INVALID) {
            julianDay = Float64(time - JULIAN_EPOCH_MS) / Float64(DAY_MS)
        }
        return julianDay
    }

    public func eclipticToEquatorial(eclipLong: Float64, eclipLat: Float64): CalendarAstronomer_Equatorial {
        let obliq = eclipticObliquity()
        let sinE = sin(obliq)
        let cosE = cos(obliq)
        let sinL = sin(eclipLong)
        let cosL = cos(eclipLong)
        let sinB = sin(eclipLat)
        let cosB = cos(eclipLat)
        let tanB = tan(eclipLat)
        return CalendarAstronomer_Equatorial(Math.atan2(sinL * cosE - tanB * sinE, cosL), Math.asin(sinB * cosE + cosB * sinE * sinL))
    }

    static let JD_EPOCH = 2447891.5

    static let SUN_ETA_G = 279.403303 * PI / 180.0

    static let SUN_OMEGA_G = 282.768422 * PI / 180.0

    static let SUN_E = 0.016713

    public func getSunLongitude(): Float64 {
        if (sunLongitude == INVALID) {
            let result = getSunLongitude(getJulianDay())
            sunLongitude = result[0]
            meanAnomalySun = result[1]
        }
        return sunLongitude
    }

    public func getSunLongitude(julian: Float64): Array<Float64> {
        let day = julian - JD_EPOCH
        let epochAngle = norm2PI(PI2 / TROPICAL_YEAR * day)
        let meanAnomaly = norm2PI(epochAngle + SUN_ETA_G - SUN_OMEGA_G)
        return [norm2PI(trueAnomaly(meanAnomaly, SUN_E) + SUN_OMEGA_G), meanAnomaly]
    }

    public static let WINTER_SOLSTICE = CalendarAstronomer_SolarLongitude((PI * 3.0) / 2.0)

    public func getSunTime(desired: Float64, next: Bool): Int64 {
        return timeOfAngle(CalendarAstronomer_1(this), desired, TROPICAL_YEAR, Int64(MINUTE_MS), next)
    }

    public func getSunTime(desired: CalendarAstronomer_SolarLongitude, next: Bool): Int64 {
        return getSunTime(desired.value, next)
    }

    static let moonL0 = 318.351648 * PI / 180.0

    static let moonP0 = 36.34041 * PI / 180.0

    static let moonN0 = 318.510107 * PI / 180.0

    static let moonI = 5.145366 * PI / 180.0

    static let moonE = 0.0549

    static let moonA = 384401.0

    static let moonT0 = 0.5181 * PI / 180.0

    static let moonPi = 0.9507 * PI / 180.0

    public func getMoonPosition(): CalendarAstronomer_Equatorial {
        if (moonPosition.isNone()) {
            let sunLong = getSunLongitude()
            let day = getJulianDay() - JD_EPOCH
            let meanLongitude = norm2PI(13.1763966 * PI / 180.0 * day + moonL0)
            var meanAnomalyMoon = norm2PI(meanLongitude - 0.1114041 * PI / 180.0 * day - moonP0)
            let evection = 1.2739 * PI / 180.0 * sin(2.0 * (meanLongitude - sunLong) - meanAnomalyMoon)
            let annual = 0.1858 * PI / 180.0 * sin(meanAnomalySun)
            let a3 = 0.37 * PI / 180.0 * sin(meanAnomalySun)
            meanAnomalyMoon += evection - annual - a3
            let center = 6.2886 * PI / 180.0 * sin(meanAnomalyMoon)
            let a4 = 0.214 * PI / 180.0 * sin(2.0 * meanAnomalyMoon)
            var moonLongitude = meanLongitude + evection + center - annual + a4
            let variation = 0.6583 * PI / 180.0 * sin(2.0 * (moonLongitude - sunLong))
            moonLongitude += variation
            var nodeLongitude = norm2PI(moonN0 - 0.0529539 * PI / 180.0 * day)
            nodeLongitude -= 0.16 * PI / 180.0 * sin(meanAnomalySun)
            let y = sin(moonLongitude - nodeLongitude)
            let x = cos(moonLongitude - nodeLongitude)
            moonEclipLong = Math.atan2(y * cos(moonI), x) + nodeLongitude
            let moonEclipLat = Math.asin(y * sin(moonI))
            moonPosition = eclipticToEquatorial(moonEclipLong, moonEclipLat)
        }
        return moonPosition
    }

    public func getMoonAge(): Float64 {
        getMoonPosition()
        return norm2PI(moonEclipLong - sunLongitude)
    }

    public static let NEW_MOON = CalendarAstronomer_MoonAge(0.0)

    public func getMoonTime(desired: Float64, next: Bool): Int64 {
        return timeOfAngle(CalendarAstronomer_2(this), desired, SYNODIC_MONTH, Int64(MINUTE_MS), next)
    }

    public func getMoonTime(desired: CalendarAstronomer_MoonAge, next: Bool): Int64 {
        return getMoonTime(desired.value, next)
    }

    private func timeOfAngle(func: CalendarAstronomer_AngleFunc, desired: Float64, periodDays: Float64, epsilon: Int64, next: Bool): Int64 {
        var lastAngle = func.eval()
        let deltaAngle = norm2PI(desired - lastAngle)
        var deltaT = (deltaAngle + (if (next) { 0.0 } else { -PI2 })) * (periodDays * Float64(DAY_MS)) / PI2
        var lastDeltaT = deltaT
        let startTime = time
        setTime(time + Int64(deltaT))
            lastDeltaT = deltaT
            lastAngle = angle
            setTime(time + Int64(deltaT))
        } while (abs(deltaT) > Float64(epsilon))
        return time
    }

    private static func normalize(value: Float64, range: Float64): Float64 {
        return value - range * floor(value / range)
    }

    private static func norm2PI(angle: Float64): Float64 {
        return normalize(angle, PI2)
    }

    private static func normPI(angle: Float64): Float64 {
        return normalize(angle + PI, PI2) - PI
    }

    private func trueAnomaly(meanAnomaly: Float64, eccentricity: Float64): Float64 {
        var delta: Float64 = 0.0
        var E = meanAnomaly
        return 2.0 * Math.atan(tan(E / 2.0) * sqrt((1.0 + eccentricity) / (1.0 - eccentricity)))
    }

    private func eclipticObliquity(): Float64 {
        let epoch = 2451545.0
        let T = (getJulianDay() - epoch) / 36525.0
        let eclipObliquity = 23.439292 - 46.815 / 3600.0 * T - 6.0E-4 / 3600.0 * T * T + 0.00181 / 3600.0 * T * T * T
        return eclipObliquity * DEG_RAD
    }

    private var time: Int64 = 0

    private static let INVALID = Float64.Min

     private var julianDay = INVALID

     private var sunLongitude = INVALID

     private var meanAnomalySun = INVALID

     private var moonEclipLong = INVALID

     private var moonPosition: CalendarAstronomer_Equatorial

    private func clearCache(): Unit {
        julianDay = INVALID
        sunLongitude = INVALID
        meanAnomalySun = INVALID
        moonEclipLong = INVALID
        moonPosition = None
    }

    static func radToHms(angle: Float64): String {
        let hrs = Int32(angle * RAD_HOUR)
        let min = Int32((angle * RAD_HOUR - Float64(hrs)) * 60.0)
        let sec = Int32((angle * RAD_HOUR - Float64(hrs) - Float64(min) / 60.0) * 3600.0)
        return hrs.toString() + "h" + min.toString() + "m" + sec.toString() + "s"
    }

    static func radToDms(angle: Float64): String {
        let deg = Int32(angle * RAD_DEG)
        let min = Int32((angle * RAD_DEG - Float64(deg)) * 60.0)
        let sec = Int32((angle * RAD_DEG - Float64(deg) - Float64(min) / 60.0) * 3600.0)
        return deg.toString() + "\u{00b0}" + min.toString() + "'" + sec.toString() + "\""
    }
}


class CalendarAstronomer_SolarLongitude {
    var value: Float64 = 0.0

    init(val: Float64) {
        value = val
    }
}


class CalendarAstronomer_1 <: CalendarAstronomer_AngleFunc {
    let this_0: CalendarAstronomer

    init(this_0: CalendarAstronomer) {
        this.this_0 = this_0
    }

    public override func eval(): Float64 {
        return this_0.getSunLongitude()
    }
}


class CalendarAstronomer_MoonAge {
    var value: Float64 = 0.0

    init(val: Float64) {
        value = val
    }
}


class CalendarAstronomer_2 <: CalendarAstronomer_AngleFunc {
    let this_0: CalendarAstronomer

    init(this_0: CalendarAstronomer) {
        this.this_0 = this_0
    }

    public override func eval(): Float64 {
        return this_0.getMoonAge()
    }
}


interface CalendarAstronomer_AngleFunc {
    public func eval(): Float64
}

public class CalendarAstronomer_Ecliptic {
    public init(lat: Float64, lon: Float64) {
        latitude = lat
        longitude = lon
    }

    public override func toString(): String {
        return (longitude * CalendarAstronomer.RAD_DEG).toString() + "," + ((latitude * CalendarAstronomer.RAD_DEG).toString())
    }

    public let latitude: Float64

    public let longitude: Float64
}


public class CalendarAstronomer_Equatorial {
    public init(asc: Float64, dec: Float64) {
        ascension = asc
        declination = dec
    }

    public override func toString(): String {
        return (ascension * CalendarAstronomer.RAD_DEG).toString() + "," + ((declination * CalendarAstronomer.RAD_DEG).toString())
    }

    public func toHmsString(): String {
        return (CalendarAstronomer.radToHms(ascension)) + "," + (CalendarAstronomer.radToDms(declination))
    }

    public let ascension: Float64

    public let declination: Float64
}
