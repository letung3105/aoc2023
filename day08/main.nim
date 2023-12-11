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
      endings.init()
      endings.incl(node)

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

  # Find LCM of all steps.
  var periods = newSeq[uint]()
  for allSteps in stepsFromAllStartings:
    # The input has `allSteps[0] == allSteps[1] - allSteps[0]`, and each ghost only
    # goes to a single node ending in 'Z', so finding the LCM is correct. This might
    # not be true for other inputs. A generalized solution to this problem could be
    # using the Chinese remainder theorem.
    periods.add(allSteps[1] - allSteps[0])

  lcm(periods)

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
