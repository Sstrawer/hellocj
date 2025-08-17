package icu4cj.impl.data

public class HolidayBundle_da <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fContents: Array<Array<Object>> = [["Armistice Day", "v\u{00e5}benhvile"], ["Ascension", "himmelfart"], ["Boxing Day", "anden juledag"], ["Christmas Eve", "juleaften"], ["Easter", "p\u{00e5}ske"], ["Epiphany", "helligtrekongersdag"], ["Good Friday", "langfredag"], ["Halloween", "allehelgensaften"], ["Maundy Thursday", "sk\u{00e6}rtorsdag"], ["Palm Sunday", "palmes\u{00f8}ndag"], ["Pentecost", "pinse"], ["Shrove Tuesday", "hvidetirsdag"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
