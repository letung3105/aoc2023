import std/[cmdline, math, sequtils, streams, strutils]

proc calculateNumberOfOptions(maxTime: uint, distance: uint): uint =
  # Solving
  #     (maxTime - holdTime) * holdTime > distance
  # which is equivalent to
  #     -(holdTime^2) + maxTime * holdTime - distance > 0
  let maxTimeFloat = float(maxTime)
  let delta = sqrt(maxTimeFloat ^ 2 - 4 * float(distance))
  let x1 = (maxTimeFloat - delta) / 2
  let x2 = (maxTimeFloat + delta) / 2
  # We transform x1 and x2 a bit to make sure that:
  # (1) only whole number is considered.
  # (2) the resulting distance is greater than the given distance.
  uint(ceil(x2 - 1) - floor(x1 + 1) + 1)

proc parseNumbers(line: string): tuple[big: uint, small: seq[uint]] =
  var big = ""
  var small = newSeq[uint]()
  for s in line.split(':')[1].strip().splitWhitespace():
    big.add(s)
    small.add(s.parseUInt())
  (big.parseUInt(), small)

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  var times = parseNumbers(input.readLine())
  var distances = parseNumbers(input.readLine())

  var res01 = uint(1)
  for (t, d) in times.small.zip(distances.small):
    res01 *= calculateNumberOfOptions(t, d)

  var res02 = calculateNumberOfOptions(times.big, distances.big)

  echo res01
  echo res02

when isMainModule: main()
