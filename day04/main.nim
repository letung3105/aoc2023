import std/[cmdline, math, sequtils, streams, strutils]

proc part01(lines: openarray[string]): int =
  var sum = 0
  for line in lines:
    let scratchCard = line.split(":")[1].strip().split("|")
    var count = 0
    var havings = newSeq[uint]()
    for x in scratchCard[0].splitWhitespace():
      havings.add(x.parseUint())

    for x in scratchCard[1].splitWhitespace():
      let winning = x.parseUint()
      for having in havings:
        if having == winning:
          count += 1
          break

    if count > 0: sum += 2 ^ (count - 1)

  sum

proc part02(lines: openarray[string]): int =
  var copies = newSeqWith[uint](lines.len(), 1)
  for cardIndex, line in lines.pairs():
    let scratchCard = line.split(":")[1].strip().split("|")
    var count = 0
    var havings = newSeq[uint]()
    for x in scratchCard[0].splitWhitespace():
      havings.add(x.parseUint())

    for x in scratchCard[1].splitWhitespace():
      let winning = x.parseUint()
      for having in havings:
        if having == winning:
          count += 1
          break

    for offset in 1 .. count:
      let idx = cardIndex + offset
      if idx >= copies.len(): break
      copies[idx] += copies[cardIndex]

  copies.sum()

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  var lines = newSeq[string]()
  for line in input.lines():
    if line.isEmptyOrWhitespace(): continue
    lines.add(line)

  let res01 = part01(lines)
  let res02 = part02(lines)
  echo res01
  echo res02

when isMainModule: main()
