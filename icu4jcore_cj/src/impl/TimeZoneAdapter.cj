package icu4cj.impl

public class TimeZoneAdapter <: TimeZone & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -2040072218820018557

    private var zone: TimeZone

    public static func wrap(tz: TimeZone): TimeZone {
        return TimeZoneAdapter(tz)
    }

    public func unwrap(): TimeZone {
        return zone
    }

    public init(zone: TimeZone) {
        TimeZone()
        this.zone = zone
        super.setID(zone.getID())
    }

    public override func setID(ID: String): Unit {
        super.setID(ID)
        zone.setID(ID)
    }

    public override func hasSameRules(other: TimeZone): Bool {
        return checkOptionalIs<TimeZoneAdapter, TimeZone>(other) && zone.hasSameRules(other.zone)
    }

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, millis: Int32): Int32 {
        return zone.getOffset(era, year, month, day, dayOfWeek, millis)
    }

    public override func getRawOffset(): Int32 {
        return zone.getRawOffset()
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        zone.setRawOffset(offsetMillis)
    }

    public override func useDaylightTime(): Bool {
        return zone.useDaylightTime()
    }

    public override func inDaylightTime(date: DateTime): Bool {
        return zone.inDaylightTime(date)
    }

    public override func clone(): Object {
        return TimeZoneAdapter(zone.clone())
    }

    public override func hashCode(): Int64 {
        synchronized (GeneratedLockObject) {
            return zone.hashCode()
        }
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (checkOptionalIs<TimeZoneAdapter, Object>(obj)) {
            let anotherZone = obj.zone
            return zone.equals(anotherZone)
        }
        return false
    }

    public override func toString(): String {
        return "TimeZoneAdapter: " + toString(zone)
    }
}
