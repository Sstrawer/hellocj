package icu4cj.impl


public class JavaTimeZone <: TimeZone {
    private static let serialVersionUID = 6977448185543929364

    private static let AVAILABLESET: TreeSet

    private var javatz: TimeZone = None

     private var javacal: Calendar = None

    private static var mObservesDaylightTime: Method = None


    public init() {
        this(TimeZone.getDefault(), None)
    }

    public init(jtz: TimeZone, id: String) {
        super()
        var tempid = id
        if (tempid.isNone()) {
            tempid = jtz.getID()
        }
        javatz = jtz
        setID(tempid)
        javacal = GregorianCalendar(javatz)
    }

    public static func createTimeZone(id: String): JavaTimeZone {
        var jtz: TimeZone = None
        if (AVAILABLESET.contains(id)) {
            jtz = TimeZone.getTimeZone(id)
        }
        if (jtz.isNone()) {
            let isSystemID = Array<Bool>(1) { _ => false }
            let canonicalID = TimeZone.getCanonicalID(id, isSystemID)
            if (isSystemID[0] && AVAILABLESET.contains(canonicalID)) {
                jtz = TimeZone.getTimeZone(canonicalID)
            }
        }
        if (jtz.isNone()) {
            return None
        }
        return JavaTimeZone(jtz, id)
    }

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32 {
        return javatz.getOffset(era, year, month, day, dayOfWeek, milliseconds)
    }

    public override func getOffset(date: Int64, local: Bool, offsets: Array<Int32>): Unit {
        synchronized (getMonitorByObject(javacal)) {
            if (local) {
                let fields = Array<Int32>(6) { _ => 0 }
                Grego.timeToFields(date, fields)
                let hour: Int32
                let min: Int32
                let sec: Int32
                let mil: Int32
                var tmp = fields[5]
                mil = tmp % 1000
                tmp /= 1000
                sec = tmp % 60
                tmp /= 60
                min = tmp % 60
                hour = tmp / 60
                javacal.clear()
                javacal.set(fields[0], fields[1], fields[2], hour, min, sec)
                javacal.set(Calendar.MILLISECOND, mil)
                let doy1: Int32
                let hour1: Int32
                let min1: Int32
                let sec1: Int32
                let mil1: Int32
                doy1 = javacal.get(Calendar.DAY_OF_YEAR)
                hour1 = javacal.get(Calendar.HOUR_OF_DAY)
                min1 = javacal.get(Calendar.MINUTE)
                sec1 = javacal.get(Calendar.SECOND)
                mil1 = javacal.get(Calendar.MILLISECOND)
                if (fields[4] != doy1 || hour != hour1 || min != min1 || sec != sec1 || mil != mil1) {
                    let dayDelta = if (abs(doy1 - fields[4]) > 1) { 1 } else { doy1 - fields[4] }
                    let delta = ((((dayDelta * 24) + hour1 - hour) * 60 + min1 - min) * 60 + sec1 - sec) * 1000 + mil1 - mil
                    javacal.setTimeInMillis(javacal.getTimeInMillis() - Int64(delta) - 1)
                }
            } else {
                javacal.setTimeInMillis(date)
            }
            offsets[0] = javacal.get(Calendar.ZONE_OFFSET)
            offsets[1] = javacal.get(Calendar.DST_OFFSET)
        }
    }

    public override func getRawOffset(): Int32 {
        return javatz.getRawOffset()
    }

    public override func inDaylightTime(date: DateTime): Bool {
        return javatz.inDaylightTime(date)
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen JavaTimeZone instance.")
        }
        javatz.setRawOffset(offsetMillis)
    }

    public override func useDaylightTime(): Bool {
        return javatz.useDaylightTime()
    }

    public override func observesDaylightTime(): Bool {
        if (mObservesDaylightTime.isSome()) {
            try {
                return mObservesDaylightTime.invoke(javatz, None).booleanValue()
            } catch (e: IllegalAccessException) { }) catch (e: InvocationTargetException) { }
        }
        return super.observesDaylightTime()
    }

    public override func getDSTSavings(): Int32 {
        return javatz.getDSTSavings()
    }

    public func unwrap(): TimeZone {
        return javatz
    }

    public override func clone(): Object {
        if (isFrozenMethod()) {
            return this
        }
        return cloneAsThawed()
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(super.hashCode()) + Int32(javatz.toString()))
    }

    private func readObject(s: ObjectInputStream): Unit {
        s.defaultReadObject()
        javacal = GregorianCalendar(javatz)
    }

      private var isFrozen = false

    public override func isFrozenMethod(): Bool {
        return isFrozen
    }

    public override func freeze(): TimeZone {
        isFrozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZone {
        let tz = super.cloneAsThawed()
        tz.javatz = javatz.clone()
        tz.javacal = GregorianCalendar(javatz)
        tz.isFrozen = false
        return tz
    }
}
