import std/[cmdline, math, re, sets, streams, tables]

# Find the next node given the current one and the instruction.
proc makeStep(
  inst: char,
  current: string,
  map: TableRef[string, tuple[left: string, right: string]]
): string =
  case inst:
    of 'L':
      map[current].left
    of 'R':
      map[current].right
    else:
      raiseAssert "invalid instruction"

# Prime sieve.
proc allPrimes(n: uint): seq[uint] =
  var notPrimes: HashSet[uint]
  notPrimes.init()
  notPrimes.incl(0)
  notPrimes.incl(1)
  result = newSeq[uint]()
  for x in 2..n:
    if not notPrimes.contains(x):
      result.add(x)
      for y in 2..n.div(x):
        notPrimes.incl(x * y)

# Prime factorization.
proc factorize(
  x: uint,
  primes: openarray[uint]
): seq[tuple[prime: uint, power: uint]] =
  var x = x
  result = newSeq[tuple[prime: uint, power: uint]]()
  for prime in primes:
    if x == 0 or x == 1:
      break

    var power = 0.uint
    while x.mod(prime) == 0:
      x = x.div(prime)
      power += 1

    if power > 0:
      result.add((prime, power))

# Lowest common multiple.
proc lcd(x: uint, y: uint, primes: openarray[uint]): uint =
  let xFactors = factorize(x, primes)
  let yFactors = factorize(y, primes)
  var i = 0;
  var j = 0;
  result = 1
  while i < xFactors.len and j < yFactors.len:
    let xFactor = xFactors[i]
    let yFactor = yFactors[j]
    if xFactor.prime < yFactor.prime:
      result *= xFactor.prime ^ xFactor.power
      i += 1
    elif xFactor.prime > yFactor.prime:
      result *= yFactor.prime ^ yFactor.power
      j += 1
    else:
      let power = xFactor.power.max(yFactor.power)
      result *= xFactor.prime ^ power
      i += 1
      j += 1

  for k in i..<xFactors.len:
    let xFactor = xFactors[k]
    result *= xFactor.prime ^ xFactor.power

  for k in j..<yFactors.len:
    let yFactor = yFactors[k]
    result *= yFactor.prime ^ yFactor.power

proc part01(
  instructions: string,
  map: TableRef[string, tuple[left: string, right: string]]
): uint =
  result = 0
  var current = "AAA"
  while (current != "ZZZ"):
    let inst = result.mod(instructions.len.uint)
    current = makeStep(instructions[inst], current, map)
    result += 1

proc part02(
  instructions: string,
  map: TableRef[string, tuple[left: string, right: string]]
): uint =
  # Find the number of steps from each starting node to each ending node.
  var stepsFromAllStartings = newSeq[seq[uint]]()
  for node in map.keys:
    if node[2] == 'A':
      var endings: HashSet[string]
      init(endings)

      var stepsFromCurrent = newSeq[uint]()
      var steps = 0.uint
      var current = node
      var isFinished = false
      while not isFinished:
        if current[2] == 'Z':
          stepsFromCurrent.add(steps)
          isFinished = endings.contains(current)
          endings.incl(current)

        let inst = steps.mod(instructions.len.uint)
        current = makeStep(instructions[inst], current, map)
        steps += 1

      stepsFromAllStartings.add(stepsFromCurrent)

  # Find the maximum number of steps. We'll build a list of primes up to this max.
  var maxSteps = 0.uint
  for steps in stepsFromAllStartings:
    for step in steps:
      maxSteps = maxSteps.max(step)

  # Find LCM of all steps.
  let primes = allPrimes(maxSteps)
  result = 1
  for allSteps in stepsFromAllStartings:
    # For our input, `allSteps[0]` always equals `allSteps[1] - allSteps[0]`.
    # Not quite sure if taking the LCD of all `allSteps[1] - allSteps[0]` is
    # correct in general.
    result = lcd(result, allSteps[1] - allSteps[0], primes)

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  let instructions = input.readline()
  discard input.readline()

  let map = newTable[string, tuple[left: string, right: string]]()
  let pattern = re"\w{3}"
  var line: string
  while input.readLine(line):
    let matches = findAll(line, pattern)
    map[matches[0]] = (matches[1], matches[2])

  let res01 = part01(instructions, map)
  echo res01
  let res02 = part02(instructions, map)
  echo res02

when isMainModule:
  main()
