import std/[algorithm, cmdline, math, sequtils, streams, strutils]

type HandType = enum
  None = 0
  OnePair = 1
  TwoPair = 2
  ThreeOfAKind = 3
  FullHouse = 4
  FourOfAKind = 5
  FiveOfAKind = 6

type Hand = object
  bid: uint
  cards: array[5, uint]
  handType: HandType

proc cmp(lhs: Hand, rhs: Hand): int =
  result = lhs.handType.cmp(rhs.handType)
  if result == 0:
    for (l, r) in lhs.cards.zip(rhs.cards):
      result = l.cmp(r)
      if result != 0:
        break

proc getCardValue(card: char): uint =
  case card:
    of '2': 0
    of '3': 1
    of '4': 2
    of '5': 3
    of '6': 4
    of '7': 5
    of '8': 6
    of '9': 7
    of 'T': 8
    of 'J': 9
    of 'Q': 10
    of 'K': 11
    of 'A': 12
    else: raise newException(ValueError, "unknown card")

proc getCardValueWithJoker(card: char): uint =
  case card:
    of 'J': 0
    of '2': 1
    of '3': 2
    of '4': 3
    of '5': 4
    of '6': 5
    of '7': 6
    of '8': 7
    of '9': 8
    of 'T': 9
    of 'Q': 10
    of 'K': 11
    of 'A': 12
    else: raise newException(ValueError, "unknown card")

proc getHandType(handType: HandType, frequency: uint): HandType =
  case frequency:
    of 1:
      handType
    of 2:
      case handType:
        of HandType.OnePair:
          HandType.TwoPair
        of HandType.ThreeOfAKind:
          HandType.FullHouse
        else:
          HandType.OnePair
    of 3:
      case handType:
        of HandType.TwoPair:
          HandType.FullHouse
        else:
          HandType.ThreeOfAKind
    of 4:
      HandType.FourOfAKind
    of 5:
      HandType.FiveOfAKind
    else:
      raise newException(ValueError, "invalid frequency")

proc getHandTypeWithJokers(handType: HandType, jokers: uint): HandType =
  case jokers:
    of 0:
      handType
    of 1:
      case handType:
        of HandType.None:
          HandType.OnePair
        of HandType.OnePair:
          HandType.ThreeOfAKind
        of HandType.TwoPair:
          HandType.FullHouse
        of HandType.ThreeOfAKind:
          HandType.FourOfAKind
        of HandType.FourOfAKind:
          HandType.FiveOfAKind
        else:
          raise newException(ValueError, "invalid hand type")
    of 2:
      case handType:
        of HandType.OnePair:
          HandType.ThreeOfAKind
        of HandType.TwoPair:
          HandType.FourOfAKind
        of HandType.FullHouse:
          HandType.FiveOfAKind
        else:
          raise newException(ValueError, "invalid hand type")
    of 3:
      case handType:
        of HandType.ThreeOfAKind:
          HandType.FourOfAKind
        of HandType.FullHouse:
          HandType.FiveOfAKind
        else:
          raise newException(ValueError, "invalid hand type")
    of 4: HandType.FiveOfAKind
    of 5: HandType.FiveOfAKind
    else:
      raise newException(ValueError, "invalid frequency")

proc parseHandPart01(handAndBid: openarray[string]): Hand =
  var histogram: array[13, uint]
  var cards: array[5, uint]
  var handType = HandType.None
  for idx, card in handAndBid[0]:
    let cardValue = getCardValue(card)
    histogram[cardValue] += 1
    cards[idx] = uint(cardValue)
    handType = getHandType(handType, histogram[cardValue])

  let bid = handAndBid[1].parseUInt()
  Hand(bid: bid, cards: cards, handType: handType)

proc parseHandPart02(handAndBid: openarray[string]): Hand =
  var histogram: array[13, uint]
  var cards: array[5, uint]
  var handType = HandType.None
  for idx, card in handAndBid[0]:
    let cardValue = getCardValueWithJoker(card)
    histogram[cardValue] += 1
    cards[idx] = uint(cardValue)
    handType = getHandType(handType, histogram[cardValue])

  handType = getHandTypeWithJokers(handType, histogram[0])
  let bid = handAndBid[1].parseUInt()
  Hand(bid: bid, cards: cards, handType: handType)

proc sumWinnings(hands: openarray[Hand]): uint =
  result = 0
  for idx, hand in hands:
    result += hand.bid * uint(idx + 1)

proc main() =
  let params = commandLineParams()
  let input = openFileStream(params[0], fmRead)
  defer: input.close()

  var hands01: seq[Hand]
  var hands02: seq[Hand]
  var line: string
  while input.readLine(line):
    let handAndBid = line.splitWhiteSpace()
    hands01.add(parseHandPart01(handAndBid))
    hands02.add(parseHandPart02(handAndBid))

  sort(hands01, cmp)
  sort(hands02, cmp)
  echo sumWinnings(hands01)
  echo sumWinnings(hands02)

when isMainModule: main()
