import std/[cmdline, math, sequtils, streams, strutils]

type ScratchCard = object
  havings: seq[uint]
  winnings: seq[uint]

proc parse(card: var ScratchCard, line: string) =
  let cardData = line.split(":")[1].strip().split("|")
  card.havings = newSeq[uint]()
  card.winnings = newSeq[uint]()
  for x in cardData[0].splitWhitespace():
    card.havings.add(x.parseUint())
  for x in cardData[1].splitWhitespace():
    card.winnings.add(x.parseUint())

proc countMatchings(card: ScratchCard): int =
  result = 0
  for winning in card.winnings:
    for having in card.havings:
      if having == winning:
        result += 1
        break

proc part01(cards: openarray[ScratchCard]): int =
  result = 0
  for card in cards:
    let count = card.countMatchings()
    if count > 0:
      result += 2 ^ (count - 1)

proc part02(cards: openarray[ScratchCard]): int =
  result = 0
  var copies = newSeqWith[uint](cards.len(), 1)
  for cardIndex, card in cards.pairs():
    result += copies[cardIndex]
    for offset in 1 .. card.countMatchings():
      let idx = cardIndex + offset
      if idx >= copies.len(): break
      copies[idx] += copies[cardIndex]

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  var cards = newSeq[ScratchCard]()
  for line in input.lines():
    if line.isEmptyOrWhitespace(): continue
    var card: ScratchCard
    card.parse(line)
    cards.add(card)

  let res01 = part01(cards)
  let res02 = part02(cards)
  echo res01
  echo res02

when isMainModule: main()
