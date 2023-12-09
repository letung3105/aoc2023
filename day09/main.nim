import std/[cmdline, math, sets, streams, strutils, tables]

proc expandHistory(history: openarray[int]): seq[seq[int]] =
  var lvlCurr = newSeq[int]()
  for x in history:
    lvlCurr.add(x)

  result = newSeq[seq[int]]()
  var finished = false
  while not finished:
    result.add(lvlCurr)
    var lvlNext = newSeq[int]()
    for idx in 1 ..< lvlCurr.len:
      lvlNext.add(lvlCurr[idx] - lvlCurr[idx - 1])

    finished = true
    for x in lvlNext:
      if x != 0:
        finished = false
        break

    lvlCurr = lvlNext

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  var histories = newSeq[seq[int]]()
  var line: string
  while input.readLine(line):
    var history = newSeq[int]()
    for digits in line.splitWhiteSpace():
      history.add(digits.parseInt())
    histories.add(history)

  var sum01 = 0
  var sum02 = 0
  for history in histories:
    let expanded = history.expandHistory()
    var extrapolatedForward = 0
    var extrapolatedBackward = 0
    for idx in countDown(expanded.len() - 1, 0):
      let lvl = expanded[idx]
      extrapolatedForward += lvl[lvl.len() - 1]
      extrapolatedBackward = lvl[0] - extrapolatedBackward

    sum01 += extrapolatedForward
    sum02 += extrapolatedBackward

  echo sum01
  echo sum02

when isMainModule:
  main()
