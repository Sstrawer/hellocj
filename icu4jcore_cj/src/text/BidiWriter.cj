package icu4cj.text

class BidiWriter {

    static let LRM_CHAR = Char(8206)

    static let RLM_CHAR = Char(8207)

    static let MASK_R_AL = (shl(1, UCharacter.RIGHT_TO_LEFT) | shl(1, UCharacter.RIGHT_TO_LEFT_ARABIC))

    private static func IsCombining(Type: Int32): Bool {
        return ((shl(1, Type) & (shl(1, Int32(UCharacter.NON_SPACING_MARK)) | shl(1, Int32(UCharacter.COMBINING_SPACING_MARK)) | shl(1, Int32(UCharacter.ENCLOSING_MARK)))) != 0)
    }

    private static func doWriteForward(src: String, options: Int32): String {
        match (options & (Bidi.REMOVE_BIDI_CONTROLS | Bidi.DO_MIRRORING)) {
            case 0 => return src
            case 2 =>
                let dest = StringBuffer(Int32(src.size))
                var i = 0
                var c: Int32 = 0
                return toString(dest)
            case 8 =>
                let dest = StringBuilder()
                var i = 0
                var c: Char = '\u{0000}'
                } while (i < Int32(src.size))
                return dest.toString()
            case _ =>
                let dest = StringBuffer(Int32(src.size))
                var i = 0
                var c: Int32 = 0
                } while (i < Int32(src.size))
                return toString(dest)
        }
    }

    private static func doWriteForward(text: Array<Char>, start: Int32, limit: Int32, options: Int32): String {
        return doWriteForward(String(text)[Int64(start)..Int64(start) + Int64(limit - start)], options)
    }

    static func writeReverse(src: String, options: Int32): String {
        let dest = StringBuffer(Int32(src.size))
        match (options & (Bidi.REMOVE_BIDI_CONTROLS | Bidi.DO_MIRRORING | Int32(Bidi.KEEP_BASE_COMBINING))) {
            case 0 =>
                var srcLength = Int32(src.size)
            case 1 =>
                srcLength = Int32(src.size)
                    dest.append(src[Int64(srcLength)..Int64(i)])
                } while (srcLength > 0)
            case _ =>
                srcLength = Int32(src.size)
                    }
                    if ((options & Int32(Bidi.REMOVE_BIDI_CONTROLS)) != 0 && Bidi.IsBidiControlChar(c)) {
                        continue
                    }
                    var j = srcLength
                    if ((options & Int32(Bidi.DO_MIRRORING)) != 0) {
                        c = UCharacter.getMirror(c)
                        UTF16.append(dest, c)
                        j += UTF16.getCharCount(c)
                    }
                    dest.append(src[Int64(j)..Int64(i)])
                } while (srcLength > 0)
        }
        return toString(dest)
    }

    static func doWriteReverse(text: Array<Char>, start: Int32, limit: Int32, options: Int32): String {
        return writeReverse(String(text)[Int64(start)..Int64(start) + Int64(limit - start)], options)
    }

    static func writeReordered(bidi: Bidi, options: Int32): String {
        var tempoptions = options
        var run: Int32 = 0
        let runCount: Int32
        let dest: StringBuilder
        let text = bidi.text
        runCount = bidi.countRuns()
        if ((bidi.reorderingOptions & Bidi.OPTION_INSERT_MARKS) != 0) {
            tempoptions |= Int32(Bidi.INSERT_LRM_FOR_NUMERIC)
            tempoptions &= 
        }
        if ((bidi.reorderingOptions & Bidi.OPTION_REMOVE_CONTROLS) != 0) {
            tempoptions |= Int32(Bidi.REMOVE_BIDI_CONTROLS)
            tempoptions &= 
        }
        if ((bidi.reorderingMode != Int32(Bidi.REORDER_INVERSE_NUMBERS_AS_L)) && (bidi.reorderingMode != Int32(Bidi.REORDER_INVERSE_LIKE_DIRECT)) && (bidi.reorderingMode != Int32(Bidi.REORDER_INVERSE_FOR_NUMBERS_SPECIAL)) && (bidi.reorderingMode != Int32(Bidi.REORDER_RUNS_ONLY))) {
            tempoptions &= 
        }
        dest = StringBuilder()
        if ((tempoptions & Int32(Bidi.OUTPUT_REVERSE)) == 0) {
            if ((tempoptions & Int32(Bidi.INSERT_LRM_FOR_NUMERIC)) == 0) {
                run = 0
                while (run < runCount) {
                    let bidiRun = bidi.getVisualRun(run)
                    if (bidiRun.isEvenRun()) {
                        dest.append(doWriteForward(text, bidiRun.start, bidiRun.limit, tempoptions & ))
                    } else {
                        dest.append(doWriteReverse(text, bidiRun.start, bidiRun.limit, tempoptions))
                    }
                    run++
                }
            } else {
                let dirProps = bidi.dirProps
                var uc: Char = '\u{0000}'
                var markFlag: Int32 = 0
                run = 0
                while (run < runCount) {
                    let bidiRun = bidi.getVisualRun(run)
                    markFlag = 0
                    markFlag = bidi.runs[Int64(run)].insertRemove
                    if (markFlag < 0) {
                        markFlag = 0
                    }
                    if (bidiRun.isEvenRun()) {
                        if (bidi.isInverseMethod() && dirProps[Int64(bidiRun.start)] != Bidi.L) {
                            markFlag |= Bidi.LRM_BEFORE
                        }
                        if ((markFlag & Bidi.LRM_BEFORE) != 0) {
                            uc = LRM_CHAR
                        } else if ((markFlag & Bidi.RLM_BEFORE) != 0) {
                            uc = RLM_CHAR
                        } else {
                            uc = Char(0)
                        }
                        if (Int32(UInt32(uc)) != 0) {
                            dest.append(uc)
                        }
                        dest.append(doWriteForward(text, bidiRun.start, bidiRun.limit, tempoptions & ))
                        if (bidi.isInverseMethod() && dirProps[Int64(bidiRun.limit - 1)] != Bidi.L) {
                            markFlag |= Bidi.LRM_AFTER
                        }
                        if ((markFlag & Bidi.LRM_AFTER) != 0) {
                            uc = LRM_CHAR
                        } else if ((markFlag & Bidi.RLM_AFTER) != 0) {
                            uc = RLM_CHAR
                        } else {
                            uc = Char(0)
                        }
                        if (Int32(UInt32(uc)) != 0) {
                            dest.append(uc)
                        }
                    } else {
                        if (bidi.isInverseMethod() && !bidi.testDirPropFlagAt(MASK_R_AL, bidiRun.limit - 1)) {
                            markFlag |= Bidi.RLM_BEFORE
                        }
                        if ((markFlag & Bidi.LRM_BEFORE) != 0) {
                            uc = LRM_CHAR
                        } else if ((markFlag & Bidi.RLM_BEFORE) != 0) {
                            uc = RLM_CHAR
                        } else {
                            uc = Char(0)
                        }
                        if (Int32(UInt32(uc)) != 0) {
                            dest.append(uc)
                        }
                        dest.append(doWriteReverse(text, bidiRun.start, bidiRun.limit, tempoptions))
                        if (bidi.isInverseMethod() && (MASK_R_AL & Bidi.DirPropFlag(dirProps[Int64(bidiRun.start)])) == 0) {
                            markFlag |= Bidi.RLM_AFTER
                        }
                        if ((markFlag & Bidi.LRM_AFTER) != 0) {
                            uc = LRM_CHAR
                        } else if ((markFlag & Bidi.RLM_AFTER) != 0) {
                            uc = RLM_CHAR
                        } else {
                            uc = Char(0)
                        }
                        if (Int32(UInt32(uc)) != 0) {
                            dest.append(uc)
                        }
                    }
                    run++
                }
            }
        } else {
            if ((tempoptions & Int32(Bidi.INSERT_LRM_FOR_NUMERIC)) == 0) {
                run = runCount
                while (match (0) { case _ => run--; run } >= 0) {
                    let bidiRun = bidi.getVisualRun(run)
                    if (bidiRun.isEvenRun()) {
                        dest.append(doWriteReverse(text, bidiRun.start, bidiRun.limit, tempoptions & ))
                    } else {
                        dest.append(doWriteForward(text, bidiRun.start, bidiRun.limit, tempoptions))
                    }
                }
            } else {
                let dirProps = bidi.dirProps
                run = runCount
                while (match (0) { case _ => run--; run } >= 0) {
                    let bidiRun = bidi.getVisualRun(run)
                    if (bidiRun.isEvenRun()) {
                        if (dirProps[Int64(bidiRun.limit - 1)] != Bidi.L) {
                            dest.append(LRM_CHAR)
                        }
                        dest.append(doWriteReverse(text, bidiRun.start, bidiRun.limit, tempoptions & ))
                        if (dirProps[Int64(bidiRun.start)] != Bidi.L) {
                            dest.append(LRM_CHAR)
                        }
                    } else {
                        if ((MASK_R_AL & Bidi.DirPropFlag(dirProps[Int64(bidiRun.start)])) == 0) {
                            dest.append(RLM_CHAR)
                        }
                        dest.append(doWriteForward(text, bidiRun.start, bidiRun.limit, tempoptions))
                        if ((MASK_R_AL & Bidi.DirPropFlag(dirProps[Int64(bidiRun.limit - 1)])) == 0) {
                            dest.append(RLM_CHAR)
                        }
                    }
                }
            }
        }
        return dest.toString()
    }
}
