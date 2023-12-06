import std/[cmdline, streams, strutils]

type
  ExclusiveRange = object
    lo: uint
    hi: uint
  Mapping = object
    inputRange: ExclusiveRange
    outputLo: uint

# Check if a value is in the range.
proc contains(r: ExclusiveRange, value: uint): bool =
  value >= r.lo and value < r.hi

# Check if two ranges overlap.
proc overlaps(r1: ExclusiveRange, r2: ExclusiveRange): bool =
  r1.hi > r2.lo and r1.lo < r2.hi

# Parse the list of seeds from the input file stream.
proc readSeeds(fs: FileStream): seq[uint] =
  var line: string
  if not fs.readLine(line):
    raise newException(IOError, "seeds not found")

  # Skip the empty line after the seeds.
  discard fs.readLine()

  line.removePrefix("seeds: ")
  result = newSeq[uint]()
  for seed in line.splitWhitespace():
    result.add(seed.parseUInt())

# Parse a single map from the input file stream.
proc readMap(fs: FileStream): seq[Mapping] =
  result = newSeq[Mapping]()
  var line: string
  while fs.readLine(line):
    if line.isEmptyOrWhitespace():
      # No more map data if we encounter an empty line.
      break

    var nums: array[3, uint]
    var numsIdx = 0
    for num in line.splitWhitespace():
      defer: numsIdx += 1
      nums[numsIdx] = num.parseUint()

    result.add(Mapping(
      inputRange: ExclusiveRange(lo: nums[1], hi: nums[1] + nums[2]),
      outputLo: nums[0]
    ))

# Parse all maps from the input file stream.
proc readMaps(fs: FileStream): seq[seq[Mapping]] =
  result = newSeq[seq[Mapping]]()
  while not fs.atEnd():
    # Ignore the line that specifies the name of the map.
    discard fs.readLine()
    result.add(fs.readMap())

proc part01(maps: seq[seq[Mapping]], seeds: seq[uint]): uint =
  result = high(uint)
  for seed in seeds:
    var destination = seed
    # Find the destination of a seed using the given sequence of maps.
    for map in maps:
      for mapping in map:
        if mapping.inputRange.contains(destination):
          # Found an overlapping input range, apply the mapping,
          # the output is then used as the input for the next map.
          destination = mapping.outputLo + (destination - mapping.inputRange.lo)
          break
    result = result.min(destination)

proc part02(maps: seq[seq[Mapping]], seeds: seq[uint]): uint =
  var rangesToVisit = newSeq[ExclusiveRange]()
  var idx = 0
  while idx < seeds.len():
    defer: idx += 2
    let seedLo = seeds[idx]
    let seedHi = seedLo + seeds[idx + 1]
    rangesToVisit.add(ExclusiveRange(lo: seedLo, hi: seedHi))

  for map in maps:
    echo rangesToVisit
    var newRanges = newSeq[ExclusiveRange]()
    while rangesToVisit.len() > 0:
      let inputRange = rangesToVisit.pop()
      var foundOverlappingRange = false
      # Find the mapping whose input range overlaps with the current range.
      for mapping in map:
        if inputRange.overlaps(mapping.inputRange):
          let loMin = inputRange.lo.min(mapping.inputRange.lo)
          let loMax = inputRange.lo.max(mapping.inputRange.lo)
          let hiMin = inputRange.hi.min(mapping.inputRange.hi)
          let hiMax = inputRange.hi.max(mapping.inputRange.hi)
          let newRange = ExclusiveRange(
            lo: mapping.outputLo + loMax - mapping.inputRange.lo,
            hi: mapping.outputLo + hiMin - mapping.inputRange.lo
          )

          # Only consider non-empty ranges.
          if newRange.lo < newRange.hi:
            newRanges.add(newRange)

          # Add remaining ranges on the left-hand-side.
          if inputRange.lo == loMin:
            rangesToVisit.add(ExclusiveRange(lo: loMin, hi: loMax))

          # Add remaining ranges on the right-hand-side.
          if inputRange.hi == hiMax:
            rangesToVisit.add(ExclusiveRange(lo: hiMin, hi: hiMax))

          foundOverlappingRange = true
          break

      # The range can't be mapped, so we keep it as is.
      if not foundOverlappingRange:
        newRanges.add(inputRange)

    # Set the new ranges to visit to be used with the next map.
    rangesToVisit = newRanges

  # Find min of all ranges.
  result = high(uint)
  for r in rangesToVisit:
    result = result.min(r.lo)

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  let seeds = readSeeds(input)
  let maps = readMaps(input)

  let res01 = part01(maps, seeds)
  echo res01

  let res02 = part02(maps, seeds)
  echo res02

when isMainModule: main()
