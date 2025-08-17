package icu4cj.text

class BidiLine {

    static func setTrailingWSStart(bidi: Bidi): Unit {
        let dirProps = bidi.dirProps
        let levels = bidi.levels
        var start = bidi.length
        let paraLevel = bidi.paraLevel
        if (dirProps[Int64(start - 1)] == Bidi.B) {
            bidi.trailingWSStart = start
            return
        }
        while (start > 0 && (Bidi.DirPropFlag(dirProps[Int64(start - 1)]) & Bidi.MASK_WS) != 0) {
            start--
        }
        while (start > 0 && levels[Int64(start - 1)] == paraLevel) {
            start--
        }
        bidi.trailingWSStart = start
    }

    static func setLine(paraBidi: Bidi, start: Int32, limit: Int32): Bidi {
        let length: Int32
        let lineBidi = Bidi()
        length = match (0) { case _ => lineBidi.length = match (0) { case _ => lineBidi.originalLength = match (0) { case _ => lineBidi.resultLength = limit - start; lineBidi.resultLength }; lineBidi.originalLength }; lineBidi.length }
        lineBidi.text = Array<Char>(Int64(length)) { _ => '\u{0000}' }
        arraycopy(paraBidi.text, Int64(start), lineBidi.text, 0, Int64(length))
        lineBidi.paraLevel = paraBidi.GetParaLevelAt(start)
        lineBidi.paraCount = paraBidi.paraCount
        lineBidi.runs = Array<BidiRun>(0)
        lineBidi.reorderingMode = paraBidi.reorderingMode
        lineBidi.reorderingOptions = paraBidi.reorderingOptions
        if (paraBidi.controlCount > 0) {
            var j: Int32 = 0
            j = start
            while (j < limit) {
                if (Bidi.IsBidiControlChar(Int32(UInt32(paraBidi.text[Int64(j)])))) {
                    lineBidi.controlCount++
                }
                j++
            }
            lineBidi.resultLength -= lineBidi.controlCount
        }
        lineBidi.getDirPropsMemory(length)
        lineBidi.dirProps = lineBidi.dirPropsMemory
        arraycopy(paraBidi.dirProps, Int64(start), lineBidi.dirProps, 0, Int64(length))
        lineBidi.getLevelsMemory(length)
        lineBidi.levels = lineBidi.levelsMemory
        arraycopy(paraBidi.levels, Int64(start), lineBidi.levels, 0, Int64(length))
        lineBidi.runCount = -1
        if (paraBidi.direction != Bidi.MIXED) {
            lineBidi.direction = paraBidi.direction
            if (paraBidi.trailingWSStart <= start) {
                lineBidi.trailingWSStart = 0
            } else if (paraBidi.trailingWSStart < limit) {
                lineBidi.trailingWSStart = paraBidi.trailingWSStart - start
            } else {
                lineBidi.trailingWSStart = length
            }
        } else {
            let levels = lineBidi.levels
            var i: Int32 = 0
            let trailingWSStart: Int32
            let level: UInt8
            setTrailingWSStart(lineBidi)
            trailingWSStart = lineBidi.trailingWSStart
            if (trailingWSStart == 0) {
                lineBidi.direction = UInt8(Int32(lineBidi.paraLevel) & 1)
            } else {
                level = UInt8(Int32(levels[0]) & 1)
                if (trailingWSStart < length && (Int32(lineBidi.paraLevel) & 1) != Int32(level)) {
                    lineBidi.direction = Bidi.MIXED
                } else {
                    i = 1
                    while (true) {
                        if (i == trailingWSStart) {
                            lineBidi.direction = level
                            break
                        } else if ((Int32(levels[Int64(i)]) & 1) != Int32(level)) {
                            lineBidi.direction = Bidi.MIXED
                            break
                        }
                        i++
                    }
                }
            }
            match (lineBidi.direction) {
                case 0u8 =>
                    lineBidi.paraLevel = UInt8((Int32(lineBidi.paraLevel) + 1) & )
                    lineBidi.trailingWSStart = 0
                case 1u8 =>
                    lineBidi.paraLevel |= 1
                    lineBidi.trailingWSStart = 0
                case _ => ()
            }
        }
        lineBidi.paraBidi = paraBidi
        return lineBidi
    }

    static func getLevelAt(bidi: Bidi, charIndex: Int32): UInt8 {
        if (bidi.direction != Bidi.MIXED || charIndex >= bidi.trailingWSStart) {
            return bidi.GetParaLevelAt(charIndex)
        } else {
            return bidi.levels[Int64(charIndex)]
        }
    }

    static func getLevels(bidi: Bidi): Array<UInt8> {
        let start = bidi.trailingWSStart
        let length = bidi.length
        if (start != length) {
            Arrays.fill(bidi.levels, start, length, bidi.paraLevel)
            bidi.trailingWSStart = length
        }
        if (length < Int32(bidi.levels.size)) {
            let levels = Array<UInt8>(Int64(length)) { _ => 0 }
            arraycopy(bidi.levels, 0, levels, 0, Int64(length))
            return levels
        }
        return bidi.levels
    }

    static func getLogicalRun(bidi: Bidi, logicalPosition: Int32): BidiRun {
        let newRun = BidiRun()
        var iRun: BidiRun
        getRuns(bidi)
        let runCount = bidi.runCount
        var visualStart = 0
        var logicalLimit = 0
        iRun = bidi.runs[0]
        var i = 0
        while (i < runCount) {
            iRun = bidi.runs[Int64(i)]
            logicalLimit = iRun.start + iRun.limit - visualStart
            if ((logicalPosition >= iRun.start) && (logicalPosition < logicalLimit)) {
                break
            }
            visualStart = iRun.limit
            i++
        }
        newRun.start = iRun.start
        newRun.limit = logicalLimit
        newRun.level = iRun.level
        return newRun
    }

    static func getVisualRun(bidi: Bidi, runIndex: Int32): BidiRun {
        let start = bidi.runs[Int64(runIndex)].start
        let limit: Int32
        let level = bidi.runs[Int64(runIndex)].level
        if (runIndex > 0) {
            limit = start + bidi.runs[Int64(runIndex)].limit - bidi.runs[Int64(runIndex - 1)].limit
        } else {
            limit = start + bidi.runs[0].limit
        }
        return BidiRun(start, limit, level)
    }

    static func getSingleRun(bidi: Bidi, level: UInt8): Unit {
        bidi.runs = bidi.simpleRuns
        bidi.runCount = 1
        bidi.runs[0] = BidiRun(0, bidi.length, level)
    }

    private static func reorderLine(bidi: Bidi, minLevel: UInt8, maxLevel: UInt8): Unit {
        var tempminLevel = minLevel
        var tempmaxLevel = maxLevel
        if (Int32(tempmaxLevel) <= (Int32(tempminLevel) | 1)) {
            return
        }
        let runs: Array<BidiRun>
        var tempRun: BidiRun
        let levels: Array<UInt8>
        var firstRun: Int32 = 0
        var endRun: Int32 = 0
        var limitRun: Int32 = 0
        var runCount: Int32 = 0
        tempminLevel++
        runs = bidi.runs
        levels = bidi.levels
        runCount = bidi.runCount
        if (bidi.trailingWSStart < bidi.length) {
            runCount--
        }
        while (match (0) { case _ => tempmaxLevel--; tempmaxLevel } >= tempminLevel) {
            firstRun = 0
            while (true) {
                while (firstRun < runCount && levels[Int64(runs[Int64(firstRun)].start)] < tempmaxLevel) {
                    firstRun++
                }
                if (firstRun >= runCount) {
                    break
                }
                limitRun = firstRun
                while (match (0) { case _ => limitRun++; limitRun } < runCount && levels[Int64(runs[Int64(limitRun)].start)] >= tempmaxLevel) { }
                endRun = limitRun - 1
                while (firstRun < endRun) {
                    tempRun = runs[Int64(firstRun)]
                    runs[Int64(firstRun)] = runs[Int64(endRun)]
                    runs[Int64(endRun)] = tempRun
                    firstRun++
                    endRun--
                }
                if (limitRun == runCount) {
                    break
                } else {
                    firstRun = limitRun + 1
                }
            }
        }
        if ((Int32(tempminLevel) & 1) == 0) {
            firstRun = 0
            if (bidi.trailingWSStart == bidi.length) {
                runCount--
            }
            while (firstRun < runCount) {
                tempRun = runs[Int64(firstRun)]
                runs[Int64(firstRun)] = runs[Int64(runCount)]
                runs[Int64(runCount)] = tempRun
                firstRun++
                runCount--
            }
        }
    }

    static func getRunFromLogicalIndex(bidi: Bidi, logicalIndex: Int32): Int32 {
        let runs = bidi.runs
        let runCount = bidi.runCount
        var visualStart = 0
        var i: Int32 = 0
        var length: Int32 = 0
        var logicalStart: Int32 = 0
        i = 0
        while (i < runCount) {
            length = runs[Int64(i)].limit - visualStart
            logicalStart = runs[Int64(i)].start
            if ((logicalIndex >= logicalStart) && (logicalIndex < (logicalStart + length))) {
                return i
            }
            visualStart += length
            i++
        }
        throw Exception("Internal ICU error in getRunFromLogicalIndex")
    }

    static func getRuns(bidi: Bidi): Unit {
        if (bidi.runCount >= 0) {
            return
        }
        if (bidi.direction != Bidi.MIXED) {
            getSingleRun(bidi, bidi.paraLevel)
        } else {
            let length = bidi.length
            var limit: Int32 = 0
            let levels = bidi.levels
            var i: Int32 = 0
            var runCount: Int32 = 0
            var level = 255u8
            limit = bidi.trailingWSStart
            runCount = 0
            i = 0
            while (i < limit) {
                if (levels[Int64(i)] != level) {
                    runCount++
                    level = levels[Int64(i)]
                }
                i++
            }
            if (runCount == 1 && limit == length) {
                getSingleRun(bidi, levels[0])
            } else {
                let runs: Array<BidiRun>
                var runIndex: Int32 = 0
                var start: Int32 = 0
                var minLevel = UInt8(Int32(Bidi.MAX_EXPLICIT_LEVEL) + 1)
                var maxLevel = 0u8
                if (limit < length) {
                    runCount++
                }
                bidi.getRunsMemory(runCount)
                runs = bidi.runsMemory
                runIndex = 0
                i = 0
                    if (level > maxLevel) {
                        maxLevel = level
                    }
                    while (match (0) { case _ => i++; i } < limit && levels[Int64(i)] == level) { }
                    runs[Int64(runIndex)] = BidiRun(start, i - start, level)
                    runIndex++
                } while (i < limit)
                if (limit < length) {
                    runs[Int64(runIndex)] = BidiRun(limit, length - limit, bidi.paraLevel)
                    if (bidi.paraLevel < minLevel) {
                        minLevel = bidi.paraLevel
                    }
                }
                bidi.runs = runs
                bidi.runCount = runCount
                reorderLine(bidi, minLevel, maxLevel)
                limit = 0
                i = 0
                while (i < runCount) {
                    runs[Int64(i)].level = levels[Int64(runs[Int64(i)].start)]
                    limit = (limit
                    i++
                }
                if (runIndex < runCount) {
                    let trailingRun = if ((Int32(bidi.paraLevel) & 1) != 0) { 0 } else { runIndex }
                    runs[Int64(trailingRun)].level = bidi.paraLevel
                }
            }
        }
        if (bidi.insertPoints.size > 0) {
            var point: Bidi_Point
            var runIndex: Int32 = 0
            var ip: Int32 = 0
            ip = 0
            while (ip < bidi.insertPoints.size) {
                point = bidi.insertPoints.points[Int64(ip)]
                runIndex = getRunFromLogicalIndex(bidi, point.pos)
                bidi.runs[Int64(runIndex)].insertRemove |= point.flag
                ip++
            }
        }
        if (bidi.controlCount > 0) {
            var runIndex: Int32 = 0
            var ic: Int32 = 0
            var c: Char = '\u{0000}'
            ic = 0
            while (ic < bidi.length) {
                c = bidi.text[Int64(ic)]
                if (Bidi.IsBidiControlChar(Int32(UInt32(c)))) {
                    runIndex = getRunFromLogicalIndex(bidi, ic)
                    bidi.runs[Int64(runIndex)].insertRemove--
                }
                ic++
            }
        }
    }

    static func prepareReorder(levels: Array<UInt8>, pMinLevel: Array<UInt8>, pMaxLevel: Array<UInt8>): Array<Int32> {
        var start: Int32 = 0
        var level: UInt8 = 0
        var minLevel: UInt8 = 0
        var maxLevel: UInt8 = 0
        if (levels.isNone() || Int32(levels.size) <= 0) {
            return None
        }
        minLevel = UInt8(Int32(Bidi.MAX_EXPLICIT_LEVEL) + 1)
        maxLevel = 0
        start = Int32(levels.size)
        while (start > 0) {
            level = levels[Int64(match (0) { case _ => start--; start })]
            if (Int32(level) < 0) {
                return None
            }
            if (Int32(level) > (Int32(Bidi.MAX_EXPLICIT_LEVEL) + 1)) {
                return None
            }
            if (level < minLevel) {
                minLevel = level
            }
            if (level > maxLevel) {
                maxLevel = level
            }
        }
        pMinLevel[0] = minLevel
        pMaxLevel[0] = maxLevel
        let indexMap = Array<Int32>(levels.size) { _ => 0 }
        start = Int32(levels.size)
        while (start > 0) {
            start--
            indexMap[Int64(start)] = start
        }
        return indexMap
    }

    static func reorderLogical(levels: Array<UInt8>): Array<Int32> {
        let aMinLevel = Array<UInt8>(1) { _ => 0 }
        let aMaxLevel = Array<UInt8>(1) { _ => 0 }
        var start: Int32 = 0
        var limit: Int32 = 0
        var sumOfSosEos: Int32 = 0
        var minLevel: UInt8 = 0
        var maxLevel: UInt8 = 0
        let indexMap = prepareReorder(levels, aMinLevel, aMaxLevel)
        if (indexMap.isNone()) {
            return None
        }
        minLevel = aMinLevel[0]
        maxLevel = aMaxLevel[0]
        if (minLevel == maxLevel && (Int32(minLevel) & 1) == 0) {
            return indexMap
        }
        minLevel |= 1
                if (start >= Int32(levels.size)) {
                    break
                }
                limit = start
                while (match (0) { case _ => limit++; limit } < Int32(levels.size) && levels[Int64(limit)] >= maxLevel) { }
                sumOfSosEos = start + limit - 1
                if (limit == Int32(levels.size)) {
                    break
                } else {
                    start = limit + 1
                }
            }
        } while (match (0) { case _ => maxLevel--; maxLevel } >= minLevel)
        return indexMap
    }

    static func reorderVisual(levels: Array<UInt8>): Array<Int32> {
        let aMinLevel = Array<UInt8>(1) { _ => 0 }
        let aMaxLevel = Array<UInt8>(1) { _ => 0 }
        var start: Int32 = 0
        var end: Int32 = 0
        var limit: Int32 = 0
        var temp: Int32 = 0
        var minLevel: UInt8 = 0
        var maxLevel: UInt8 = 0
        let indexMap = prepareReorder(levels, aMinLevel, aMaxLevel)
        if (indexMap.isNone()) {
            return None
        }
        minLevel = aMinLevel[0]
        maxLevel = aMaxLevel[0]
        if (minLevel == maxLevel && (Int32(minLevel) & 1) == 0) {
            return indexMap
        }
        minLevel |= 1
                if (start >= Int32(levels.size)) {
                    break
                }
                limit = start
                while (match (0) { case _ => limit++; limit } < Int32(levels.size) && levels[Int64(limit)] >= maxLevel) { }
                end = limit - 1
                while (start < end) {
                    temp = indexMap[Int64(start)]
                    indexMap[Int64(start)] = indexMap[Int64(end)]
                    indexMap[Int64(end)] = temp
                    start++
                    end--
                }
                if (limit == Int32(levels.size)) {
                    break
                } else {
                    start = limit + 1
                }
            }
        } while (match (0) { case _ => maxLevel--; maxLevel } >= minLevel)
        return indexMap
    }

    static func getVisualIndex(bidi: Bidi, logicalIndex: Int32): Int32 {
        var visualIndex = Bidi.MAP_NOWHERE
        match (bidi.direction) {
            case 0u8 => visualIndex = logicalIndex
            case 1u8 => visualIndex = bidi.length - logicalIndex - 1
            case _ =>
                getRuns(bidi)
                let runs = bidi.runs
                var i: Int32 = 0
                var visualStart = 0
                var offset: Int32 = 0
                var length: Int32 = 0
                i = 0
                while (i < bidi.runCount) {
                    length = runs[Int64(i)].limit - visualStart
                    offset = logicalIndex - runs[Int64(i)].start
                    if (offset >= 0 && offset < length) {
                        if (runs[Int64(i)].isEvenRun()) {
                            visualIndex = visualStart + offset
                        } else {
                            visualIndex = visualStart + length - offset - 1
                        }
                        break
                    }
                    visualStart += length
                    i++
                }
                if (i >= bidi.runCount) {
                    return Bidi.MAP_NOWHERE
                }
        }
        if (bidi.insertPoints.size > 0) {
            let runs = bidi.runs
            var i: Int32 = 0
            var length: Int32 = 0
            var insertRemove: Int32 = 0
            var visualStart = 0
            var markFound = 0
            i = 0
            while (true) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove & (Bidi.LRM_BEFORE | Bidi.RLM_BEFORE)) > 0) {
                    markFound++
                }
                if (visualIndex < runs[Int64(i)].limit) {
                    return visualIndex + markFound
                }
                if ((insertRemove & (Bidi.LRM_AFTER | Bidi.RLM_AFTER)) > 0) {
                    markFound++
                }
                i++
                visualStart += length
            }
        } else if (bidi.controlCount > 0) {
            let runs = bidi.runs
            var i: Int32 = 0
            var j: Int32 = 0
            let start: Int32
            let limit: Int32
            var length: Int32 = 0
            var insertRemove: Int32 = 0
            var visualStart = 0
            var controlFound = 0
            var uchar = bidi.text[Int64(logicalIndex)]
            if (Bidi.IsBidiControlChar(Int32(UInt32(uchar)))) {
                return Bidi.MAP_NOWHERE
            }
            i = 0
            while (true) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if (visualIndex >= runs[Int64(i)].limit) {
                    controlFound -= insertRemove
                    continue
                }
                if (insertRemove == 0) {
                    return visualIndex - controlFound
                }
                if (runs[Int64(i)].isEvenRun()) {
                    start = runs[Int64(i)].start
                    limit = logicalIndex
                } else {
                    start = logicalIndex + 1
                    limit = runs[Int64(i)].start + length
                }
                j = start
                while (j < limit) {
                    uchar = bidi.text[Int64(j)]
                    if (Bidi.IsBidiControlChar(Int32(UInt32(uchar)))) {
                        controlFound++
                    }
                    j++
                }
                return visualIndex - controlFound
                i++
                visualStart += length
            }
        }
        return visualIndex
    }

    static func getLogicalIndex(bidi: Bidi, visualIndex: Int32): Int32 {
        var tempvisualIndex = visualIndex
        let runs: Array<BidiRun>
        var i: Int32 = 0
        let runCount: Int32
        let start: Int32
        runs = bidi.runs
        runCount = bidi.runCount
        if (bidi.insertPoints.size > 0) {
            var markFound = 0
            var insertRemove: Int32 = 0
            var visualStart = 0
            var length: Int32 = 0
            i = 0
            while (true) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove & (Bidi.LRM_BEFORE | Bidi.RLM_BEFORE)) > 0) {
                    if (tempvisualIndex <= (visualStart + markFound)) {
                        return Bidi.MAP_NOWHERE
                    }
                    markFound++
                }
                if (tempvisualIndex < (runs[Int64(i)].limit + markFound)) {
                    tempvisualIndex -= markFound
                    break
                }
                if ((insertRemove & (Bidi.LRM_AFTER | Bidi.RLM_AFTER)) > 0) {
                    if (tempvisualIndex == (visualStart + length + markFound)) {
                        return Bidi.MAP_NOWHERE
                    }
                    markFound++
                }
                i++
                visualStart += length
            }
        } else if (bidi.controlCount > 0) {
            var controlFound = 0
            var insertRemove: Int32 = 0
            var length: Int32 = 0
            let logicalStart: Int32
            let logicalEnd: Int32
            var visualStart = 0
            var j: Int32 = 0
            var k: Int32 = 0
            var uchar: Char = '\u{0000}'
            let evenRun: Bool
            i = 0
            while (true) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if (tempvisualIndex >= (runs[Int64(i)].limit - controlFound + insertRemove)) {
                    controlFound -= insertRemove
                    continue
                }
                if (insertRemove == 0) {
                    tempvisualIndex += controlFound
                    break
                }
                logicalStart = runs[Int64(i)].start
                evenRun = runs[Int64(i)].isEvenRun()
                logicalEnd = logicalStart + length - 1
                j = 0
                while (j < length) {
                    k = if (evenRun) { logicalStart + j } else { logicalEnd - j }
                    uchar = bidi.text[Int64(k)]
                    if (Bidi.IsBidiControlChar(Int32(UInt32(uchar)))) {
                        controlFound++
                    }
                    if ((tempvisualIndex + controlFound) == (visualStart + j)) {
                        break
                    }
                    j++
                }
                tempvisualIndex += controlFound
                break
                i++
                visualStart += length
            }
        }
        if (runCount <= 10) {
            i = 0
            while (tempvisualIndex >= runs[Int64(i)].limit) {
                i++
            }
        } else {
            var begin = 0
            var limit = runCount
            while (true) {
                i = ushr((begin + limit), 1)
                if (tempvisualIndex >= runs[Int64(i)].limit) {
                    begin = i + 1
                } else if (i == 0 || tempvisualIndex >= runs[Int64(i - 1)].limit) {
                    break
                } else {
                    limit = i
                }
            }
        }
        start = runs[Int64(i)].start
        if (runs[Int64(i)].isEvenRun()) {
            if (i > 0) {
                tempvisualIndex -= runs[Int64(i - 1)].limit
            }
            return start + tempvisualIndex
        } else {
            return start + runs[Int64(i)].limit - tempvisualIndex - 1
        }
    }

    static func getLogicalMap(bidi: Bidi): Array<Int32> {
        var runs = bidi.runs
        var logicalStart: Int32 = 0
        var visualStart: Int32 = 0
        var logicalLimit: Int32 = 0
        var visualLimit: Int32 = 0
        let indexMap = Array<Int32>(Int64(bidi.length)) { _ => 0 }
        if (bidi.length > bidi.resultLength) {
            Arrays.fill(indexMap, Bidi.MAP_NOWHERE)
        }
        visualStart = 0
                } else {
                    logicalStart += visualLimit - visualStart
                }
                j++
            }
        } while (false)
        if (bidi.insertPoints.size > 0) {
            var markFound = 0
            let runCount = bidi.runCount
            var length: Int32 = 0
            var insertRemove: Int32 = 0
            var i: Int32 = 0
            var j: Int32 = 0
            runs = bidi.runs
            visualStart = 0
            i = 0
            while (i < runCount) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove & (Bidi.LRM_BEFORE | Bidi.RLM_BEFORE)) > 0) {
                    markFound++
                }
                if (markFound > 0) {
                    logicalStart = runs[Int64(i)].start
                    logicalLimit = logicalStart + length
                    j = logicalStart
                    while (j < logicalLimit) {
                        indexMap[Int64(j)] += markFound
                        j++
                    }
                }
                if ((insertRemove & (Bidi.LRM_AFTER | Bidi.RLM_AFTER)) > 0) {
                    markFound++
                }
                i++
                visualStart += length
            }
        } else if (bidi.controlCount > 0) {
            var controlFound = 0
            let runCount = bidi.runCount
            var length: Int32 = 0
            var insertRemove: Int32 = 0
            var i: Int32 = 0
            var j: Int32 = 0
            var k: Int32 = 0
            var evenRun: Bool = false
            var uchar: Char = '\u{0000}'
            runs = bidi.runs
            visualStart = 0
            i = 0
            while (i < runCount) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if ((controlFound - insertRemove) == 0) {
                    continue
                }
                logicalStart = runs[Int64(i)].start
                evenRun = runs[Int64(i)].isEvenRun()
                logicalLimit = logicalStart + length
                if (insertRemove == 0) {
                    j = logicalStart
                    while (j < logicalLimit) {
                        indexMap[Int64(j)] -= controlFound
                        j++
                    }
                    continue
                }
                j = 0
                while (j < length) {
                    k = if (evenRun) { logicalStart + j } else { logicalLimit - j - 1 }
                    uchar = bidi.text[Int64(k)]
                    if (Bidi.IsBidiControlChar(Int32(UInt32(uchar)))) {
                        controlFound++
                        indexMap[Int64(k)] = Bidi.MAP_NOWHERE
                        continue
                    }
                    indexMap[Int64(k)] -= controlFound
                    j++
                }
                i++
                visualStart += length
            }
        }
        return indexMap
    }

    static func getVisualMap(bidi: Bidi): Array<Int32> {
        var runs = bidi.runs
        var logicalStart: Int32 = 0
        var visualStart: Int32 = 0
        var visualLimit: Int32 = 0
        let allocLength = if (bidi.length > bidi.resultLength) { bidi.length } else { bidi.resultLength }
        let indexMap = Array<Int32>(Int64(allocLength)) { _ => 0 }
        visualStart = 0
        var idx = 0
                } else {
                    logicalStart += visualLimit - visualStart
                }
                j++
            }
        } while (false)
        if (bidi.insertPoints.size > 0) {
            var markFound = 0
            let runCount = bidi.runCount
            var insertRemove: Int32 = 0
            var i: Int32 = 0
            var j: Int32 = 0
            var k: Int32 = 0
            runs = bidi.runs
            i = 0
            while (i < runCount) {
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove & (Bidi.LRM_BEFORE | Bidi.RLM_BEFORE)) > 0) {
                    markFound++
                }
                if ((insertRemove & (Bidi.LRM_AFTER | Bidi.RLM_AFTER)) > 0) {
                    markFound++
                }
                i++
            }
            k = bidi.resultLength
            i = runCount - 1
            while (i >= 0 && markFound > 0) {
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove & (Bidi.LRM_AFTER | Bidi.RLM_AFTER)) > 0) {
                    indexMap[Int64(match (0) { case _ => k--; k })] = Bidi.MAP_NOWHERE
                    markFound--
                }
                visualStart = if (i > 0) { runs[Int64(i - 1)].limit } else { 0 }
                j = runs[Int64(i)].limit - 1
                while (j >= visualStart && markFound > 0) {
                    indexMap[Int64(match (0) { case _ => k--; k })] = indexMap[Int64(j)]
                    j--
                }
                if ((insertRemove & (Bidi.LRM_BEFORE | Bidi.RLM_BEFORE)) > 0) {
                    indexMap[Int64(match (0) { case _ => k--; k })] = Bidi.MAP_NOWHERE
                    markFound--
                }
                i--
            }
        } else if (bidi.controlCount > 0) {
            let runCount = bidi.runCount
            var logicalEnd: Int32 = 0
            var insertRemove: Int32 = 0
            var length: Int32 = 0
            var i: Int32 = 0
            var j: Int32 = 0
            var k: Int32 = 0
            var m: Int32 = 0
            var uchar: Char = '\u{0000}'
            var evenRun: Bool = false
            runs = bidi.runs
            visualStart = 0
            k = 0
            i = 0
            while (i < runCount) {
                length = runs[Int64(i)].limit - visualStart
                insertRemove = runs[Int64(i)].insertRemove
                if ((insertRemove == 0) && (k == visualStart)) {
                    k += length
                    continue
                }
                if (insertRemove == 0) {
                    visualLimit = runs[Int64(i)].limit
                    j = visualStart
                    while (j < visualLimit) {
                        indexMap[Int64(match (0) { case _ => k++; k - 1 })] = indexMap[Int64(j)]
                        j++
                    }
                    continue
                }
                logicalStart = runs[Int64(i)].start
                evenRun = runs[Int64(i)].isEvenRun()
                logicalEnd = logicalStart + length - 1
                j = 0
                while (j < length) {
                    m = if (evenRun) { logicalStart + j } else { logicalEnd - j }
                    uchar = bidi.text[Int64(m)]
                    if (!Bidi.IsBidiControlChar(Int32(UInt32(uchar)))) {
                        indexMap[Int64(match (0) { case _ => k++; k - 1 })] = m
                    }
                    j++
                }
                i++
                visualStart += length
            }
        }
        if (allocLength == bidi.resultLength) {
            return indexMap
        }
        let newMap = Array<Int32>(Int64(bidi.resultLength)) { _ => 0 }
        arraycopy(indexMap, 0, newMap, 0, Int64(bidi.resultLength))
        return newMap
    }

    static func invertMap(srcMap: Array<Int32>): Array<Int32> {
        let srcLength = Int32(srcMap.size)
        var destLength = -1
        var count = 0
        var i: Int32 = 0
        var srcEntry: Int32 = 0
        i = 0
        while (i < srcLength) {
            srcEntry = srcMap[Int64(i)]
            if (srcEntry > destLength) {
                destLength = srcEntry
            }
            if (srcEntry >= 0) {
                count++
            }
            i++
        }
        destLength++
        let destMap = Array<Int32>(Int64(destLength)) { _ => 0 }
        if (count < destLength) {
            Arrays.fill(destMap, Bidi.MAP_NOWHERE)
        }
        i = 0
        while (i < srcLength) {
            srcEntry = srcMap[Int64(i)]
            if (srcEntry >= 0) {
                destMap[Int64(srcEntry)] = i
            }
            i++
        }
        return destMap
    }
}
