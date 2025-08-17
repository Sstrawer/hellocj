package icu4cj.util

public class HebrewHoliday <: Holiday {
    private static let gCalendar = HebrewCalendar()

    public init(month: Int32, date: Int32, name: String) {
        this(month, date, 1, name)
    }

    public init(month: Int32, date: Int32, length: Int32, name: String) {
        super(name, SimpleDateRule(month, date, gCalendar))
    }

    public static var ROSH_HASHANAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 1, 2, "Rosh Hashanah")

    public static var GEDALIAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 3, "Fast of Gedaliah")

    public static var YOM_KIPPUR: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 10, "Yom Kippur")

    public static var SUKKOT: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 15, 6, "Sukkot")

    public static var HOSHANAH_RABBAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 21, "Hoshanah Rabbah")

    public static var SHEMINI_ATZERET: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 22, "Shemini Atzeret")

    public static var SIMCHAT_TORAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.TISHRI, 23, "Simchat Torah")

    public static var HANUKKAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.KISLEV, 25, "Hanukkah")

    public static var TEVET_10: HebrewHoliday = HebrewHoliday(HebrewCalendar.TEVET, 10, "Fast of Tevet 10")

    public static var TU_BSHEVAT: HebrewHoliday = HebrewHoliday(HebrewCalendar.SHEVAT, 15, "Tu B'Shevat")

    public static var ESTHER: HebrewHoliday = HebrewHoliday(HebrewCalendar.ADAR, 13, "Fast of Esther")

    public static var PURIM: HebrewHoliday = HebrewHoliday(HebrewCalendar.ADAR, 14, "Purim")

    public static var SHUSHAN_PURIM: HebrewHoliday = HebrewHoliday(HebrewCalendar.ADAR, 15, "Shushan Purim")

    public static var PASSOVER: HebrewHoliday = HebrewHoliday(HebrewCalendar.NISAN, 15, 8, "Passover")

    public static var YOM_HASHOAH: HebrewHoliday = HebrewHoliday(HebrewCalendar.NISAN, 27, "Yom Hashoah")

    public static var YOM_HAZIKARON: HebrewHoliday = HebrewHoliday(HebrewCalendar.IYAR, 4, "Yom Hazikaron")

    public static var YOM_HAATZMAUT: HebrewHoliday = HebrewHoliday(HebrewCalendar.IYAR, 5, "Yom Ha'Atzmaut")

    public static var PESACH_SHEINI: HebrewHoliday = HebrewHoliday(HebrewCalendar.IYAR, 14, "Pesach Sheini")

    public static var LAG_BOMER: HebrewHoliday = HebrewHoliday(HebrewCalendar.IYAR, 18, "Lab B'Omer")

    public static var YOM_YERUSHALAYIM: HebrewHoliday = HebrewHoliday(HebrewCalendar.IYAR, 28, "Yom Yerushalayim")

    public static var SHAVUOT: HebrewHoliday = HebrewHoliday(HebrewCalendar.SIVAN, 6, 2, "Shavuot")

    public static var TAMMUZ_17: HebrewHoliday = HebrewHoliday(HebrewCalendar.TAMUZ, 17, "Fast of Tammuz 17")

    public static var TISHA_BAV: HebrewHoliday = HebrewHoliday(HebrewCalendar.AV, 9, "Fast of Tisha B'Av")

    public static var SELIHOT: HebrewHoliday = HebrewHoliday(HebrewCalendar.ELUL, 21, "Selihot")
}
