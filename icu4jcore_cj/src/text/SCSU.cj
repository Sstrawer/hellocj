package icu4cj.text

interface SCSU {
    static let COMPRESSIONOFFSET = 128

    static let NUMWINDOWS = 8

    static let NUMSTATICWINDOWS = 8

    static let INVALIDWINDOW = -1

    static let INVALIDCHAR = -1

    static let SINGLEBYTEMODE = 0

    static let UNICODEMODE = 1

    static let MAXINDEX = 255

    static let RESERVEDINDEX = 0

    static let LATININDEX = 249

    static let IPAEXTENSIONINDEX = 250

    static let GREEKINDEX = 251

    static let ARMENIANINDEX = 252

    static let HIRAGANAINDEX = 253

    static let KATAKANAINDEX = 254

    static let HALFWIDTHKATAKANAINDEX = 255

    static let SDEFINEX = 11

    static let SRESERVED = 12

    static let SQUOTEU = 14

    static let SCHANGEU = 15

    static let SQUOTE0 = 1

    static let SQUOTE1 = 2

    static let SQUOTE2 = 3

    static let SQUOTE3 = 4

    static let SQUOTE4 = 5

    static let SQUOTE5 = 6

    static let SQUOTE6 = 7

    static let SQUOTE7 = 8

    static let SCHANGE0 = 16

    static let SCHANGE1 = 17

    static let SCHANGE2 = 18

    static let SCHANGE3 = 19

    static let SCHANGE4 = 20

    static let SCHANGE5 = 21

    static let SCHANGE6 = 22

    static let SCHANGE7 = 23

    static let SDEFINE0 = 24

    static let SDEFINE1 = 25

    static let SDEFINE2 = 26

    static let SDEFINE3 = 27

    static let SDEFINE4 = 28

    static let SDEFINE5 = 29

    static let SDEFINE6 = 30

    static let SDEFINE7 = 31

    static let UCHANGE0 = 224

    static let UCHANGE1 = 225

    static let UCHANGE2 = 226

    static let UCHANGE3 = 227

    static let UCHANGE4 = 228

    static let UCHANGE5 = 229

    static let UCHANGE6 = 230

    static let UCHANGE7 = 231

    static let UDEFINE0 = 232

    static let UDEFINE1 = 233

    static let UDEFINE2 = 234

    static let UDEFINE3 = 235

    static let UDEFINE4 = 236

    static let UDEFINE5 = 237

    static let UDEFINE6 = 238

    static let UDEFINE7 = 239

    static let UQUOTEU = 240

    static let UDEFINEX = 241

    static let URESERVED = 242

    static let sOffsetTable = [0, 128, 256, 384, 512, 640, 768, 896, 1024, 1152, 1280, 1408, 1536, 1664, 1792, 1920, 2048, 2176, 2304, 2432, 2560, 2688, 2816, 2944, 3072, 3200, 3328, 3456, 3584, 3712, 3840, 3968, 4096, 4224, 4352, 4480, 4608, 4736, 4864, 4992, 5120, 5248, 5376, 5504, 5632, 5760, 5888, 6016, 6144, 6272, 6400, 6528, 6656, 6784, 6912, 7040, 7168, 7296, 7424, 7552, 7680, 7808, 7936, 8064, 8192, 8320, 8448, 8576, 8704, 8832, 8960, 9088, 9216, 9344, 9472, 9600, 9728, 9856, 9984, 10112, 10240, 10368, 10496, 10624, 10752, 10880, 11008, 11136, 11264, 11392, 11520, 11648, 11776, 11904, 12032, 12160, 12288, 12416, 12544, 12672, 12800, 12928, 13056, 13184, 57344, 57472, 57600, 57728, 57856, 57984, 58112, 58240, 58368, 58496, 58624, 58752, 58880, 59008, 59136, 59264, 59392, 59520, 59648, 59776, 59904, 60032, 60160, 60288, 60416, 60544, 60672, 60800, 60928, 61056, 61184, 61312, 61440, 61568, 61696, 61824, 61952, 62080, 62208, 62336, 62464, 62592, 62720, 62848, 62976, 63104, 63232, 63360, 63488, 63616, 63744, 63872, 64000, 64128, 64256, 64384, 64512, 64640, 64768, 64896, 65024, 65152, 65280, 65408, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 192, 592, 880, 1328, 12352, 12448, 65376]

    static let sOffsets = [0, 128, 256, 768, 8192, 8320, 8448, 12288]
}