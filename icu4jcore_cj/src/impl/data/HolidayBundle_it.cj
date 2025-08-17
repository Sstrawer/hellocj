package icu4cj.impl.data

public class HolidayBundle_it <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["All Saints' Day", "Ognissanti"], ["Armistice Day", "armistizio"], ["Ascension", "ascensione"], ["Ash Wednesday", "mercoled\u{00ec} delle ceneri"], ["Boxing Day", "Santo Stefano"], ["Christmas", "natale"], ["Easter Sunday", "pasqua"], ["Epiphany", "Epifania"], ["Good Friday", "venerd\u{00ec} santo"], ["Halloween", "vigilia di Ognissanti"], ["Maundy Thursday", "gioved\u{00ec} santo"], ["New Year's Day", "anno nuovo"], ["Palm Sunday", "domenica delle palme"], ["Pentecost", "di Pentecoste"], ["Shrove Tuesday", "martedi grasso"], ["St. Stephen's Day", "Santo Stefano"], ["Thanksgiving", "Giorno del Ringraziamento"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
