# Learning javascript data structures and algorithms
# book source code: https://github.com/loiane/javascript-datastructures-algorithms

log = console.log.bind(console)
fs = require 'fs'
numFile = './numbers.txt'
strFile = './string.txt'
EventEmmiter = require 'events'
server = require('http').createServer()
pry = require 'pry'

after = (ms, fn) -> setTimeout(fn, ms)

# readFileAsArray = (file, cb) ->
#   fs.readFile file, (err, data) ->
#     cb err if err
#     log data.toString()
#     lines = data.toString().split(', ')
#     cb null, lines

readFileAsArray = (file, cb) ->
  return new Promise (res, rej) ->
    fs.readFile file, (err, data) ->
      if err then rej(err) and cb(err)
      lines = data.toString().split(', ')
      res(lines)
      cb(null, lines)

printer = (err, arr) ->
  # log arr
  throw err if err
  numbers = arr.map(Number)
  # log numbers
  # log numbers.length
  oddNumbers = numbers.filter (n) => n % 2 == 1
  # log('Odd numbers count: ', oddNumbers.length)

# readFileAsArray(numFile).then (lines) =>
#   numbers = lines.map(Number)
#   oddNumbers = numbers.filter (n) => n % 2 == 1
#   log 'odds: ', oddNumbers.length
#   .catch log.error

readFileAsArray(numFile, printer)

# `
# async function countOdd () {
#   try {
#     const lines = await readFileAsArray('./numbers');
#     const numbers = lines.map(Number);
#     const oddCount numbers.filter(n => n % 2 === 1).length;
#     console.log('odd numbers count: ', oddCount);
#   }
#   catch(err) {
#     console.error(err);
#   }
# }

# countOdd();
# `

class WithLog extends EventEmmiter
  execute: (taskFunc) ->
    log 'before executing'
    @emit('begin')
    taskFunc()
    @emit('end')
    log 'after executing'


# RUN ABOVE
# withLog = new WithLog()

# withLog.on 'begin', () ->
#   log 'about to execute'
# withLog.on 'end', () ->
#   log 'done'

# taskLog = () ->
#   log '*** exe task ***'


# withLog.execute(taskLog)



server.on 'request', (req, res) ->
  fs.readFile strFile, (err, data) ->
    throw err if err
    res.end(data)

# server.listen(7700)

# number binary conversion

toBinary = (decimalNumber, base) ->
  binaryArray = []
  emptyArr = binaryArray.length
  binaryString = ''
  baseString = ''
  digits = '0123456789ABCDEF'


  while decimalNumber > 0
    binaryNumber = Math.floor decimalNumber % base
    binaryArray.push binaryNumber
    decimalNumber = Math.floor decimalNumber / base
    binaryString += digits[binaryArray.pop()]


  # log binaryArray
  # log binaryString


# toBinary(10, 16)

#  QUEUES 72/218

class PriorityQueue
  constructor: (items) ->
    @items = []

  class QueueElement
    constructor: (@element, @priority) ->

  enqueue: (element, priority) ->
    queueElement = new QueueElement(element, priority)
    if @isEmpty()
      @items.push(queueElement)
    else
      added = false
      for item in @items
        if queueElement.priority < item.priority
          @items.splice(item,0,queueElement)
          added = true
        if not added
          @items.push(queueElement)
  dequeue: ->
    @items.shift()
  front: ->
    @items[0]
  isEmpty: ->
    @items.length == 0
  clear: ->
    @items = []
  size: ->
    @items.length
  print: ->
    log @items


# RUN ABOVE
# prio = new PriorityQueue

# prio.enqueue 'tom', 1
# prio.enqueue 'jon', 2
# prio.enqueue 'jan', 1
# prio.print()


class Queue
  constructor: (items) ->
    @items = []

  enqueue: (element) ->
    @items.push element
  dequeue: ->
    @items.shift()
  front: ->
    @items[0]
  isEmpty: ->
    @items.length == 0
  clear: ->
    @items = []
  size: ->
    @items.length
  print: ->
    log @items #.toString()


hotPotato = (nameList, num) ->
  queue = new Queue
  queue.enqueue y for y,i in nameList
  # log 'y to: ' + y for y,i in nameList
  # log 'i to: ' + i for y,i in nameList
  eliminated = ''
  while queue.size() > 1
    for [0...num] # .. = <= | ... = <
      log queue.front()
      queue.enqueue(queue.dequeue())
      # log queue.front()
    eliminated = queue.dequeue()
    log eliminated + ' was eliminated from the Hot Potato game.'
  queue.dequeue()


# RUN ABOVE
# names = ['John','Jack','Camila','Ingrid','Carl']
# winner = hotPotato(names, 6)
# log 'The winner is: ' + winner


#  LINKED LISTS 82/218

class LinkedList
  constructor: (length, head) ->
    @length = 0
    @head = null

  class Node
    constructor: (@element, @next) ->

  append: (element) ->
    node = new Node(element)
    if not @head?
      @head = node
    else
      current = @head
      while current.next
        current = current.next
      current.next = node
    @length++

  insert: (position, element) ->
    if position >= 0 && position <= @length
      node = new Node(element)
      current = @head
      index = 0
      if position is 0
        node.next = current
        @head = node
      else
        while index++ < position # loop to reach desired position | new element goes between previous and current
          previous = current
          current = current.next # if it's last element then current.next = null
        node.next = current
        previous.next = node
      @length++
      true
    else
      false

  removeAt: (position) ->
    if position > -1 and position < @length
      current = @head
      index = 0
      if position is 0
        @head = current.next
      else
        while index++ < position
          previous = current
          current = current.next
        previous.next = current.next # previous.next = current - to remove current change the val of previous.next to current.next
        # This way, the current element will be lost in the computer memory and will be available to be cleaned by the garbage collector.
        # read https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_Management.
      @length--
      current.element
    else
      null

  remove: (element) ->
    index = @indexOf(element)
    @removeAt(index)

  indexOf: (element) ->
    current = @head
    index = 0
    while current
      if element is current.element
        return index
      index++
      current = current.next
    index

  isEmpty: () ->
    @length is 0

  size: () ->
    @length

  toString: () ->
    current = @head
    #string = ''
    while current
      string = current.element
      #string += current.element
      current = current.next
    string

  getHead: () ->
    @head


# RUN ABOVE
# list = new LinkedList()
# list.append(15)
# list.append(10)
# list.append(8)
# log list.size()
# list.remove 8
# log list.size()
# log list.isEmpty()
# log list[1]


#  DOUBLY LINKED LISTS 95/218
  # improvements - page 99

class DoublyLinkedList
  constructor: (length, head, tail) ->
    @length = 0
    @head = null
    @tail = null

  class Node
    constructor: (@element, @next, @prev) ->

  append: (element) ->
    # do it myself - check other methods than insert and removeAt on https://github.com/loiane/javascript-datastructures-algorithms

  insert: (position, element) ->
    if position >= 0 and position <= @length
      node = new Node element
      current = @head
      index = 0
      if position is 0
        if not @head
          @head = node
          @tail = node
        else # inserting node before first element = in position 0
          node.next = current
          current.prev = node
          @head = node
      else if position is @length # inserting node as a last element
        current = @tail
        current.next = node
        node.prev = current
        @tail = node
      else
        while index++ < position
          previous = current
          current = current.next
        node.next = current
        previous.next = node
        current.prev = node
        node.prev = previous
      lenght++
      true
    else
      false

  removeAt: (position) ->
    if position > -1 and position < @length
      current = @head
      index = 0
      if position is 0
        @head = current.next
        if @length is 1
          @tail is null
        else
          @head.prev = null
      else if position is @length -1
        current = @tail
        @tail = current.prev # | @tail.prev
        @tail.next = null
      else
        while index++ < position
          previous = current
          current = current.next
        previous.next = current.next
        current.next.prev = previous
      @length--
      current.element
    else
      null

  remove: (element) ->
    index = @indexOf(element)
    @removeAt(index)

  indexOf: (element) ->
    current = @head
    index = 0
    while current
      if element is current.element
        return index
      index++
      current = current.next
    index

  isEmpty: () ->
    @length is 0

  size: () ->
    @length

  toString: () ->
    current = @head
    while current
      string = current.element
      current = current.next
    string

  getHead: () ->
    @head

#  CIRCURAL LINKED LISTS 102/218

# The only difference between the circular
# linked list and a linked list is that the last element's next (@tail.next) pointer does
# not make a reference to null, but to the first element (head)

# # # HW - make my own circural doubly linked list

# And a doubly circular linked list has tail.next pointing to the head element and
# head.prev pointing to the tail element


# SETS 104/218

# ECMAScript 6 contains an implementation of the Set
# A set is a collection of items that are unordered and consists of unique elements - distinct objects
# a set stores a [key, key] collection of elements


class Set
  # constructor: (@add, @remove, @has, @clear, @size, @sizeLegacy, @values, @valuesLegacy, @union) ->
  constructor: (items, ownLength) ->
    @items = {}
    @ownLength = 0

  add: (value) ->
    if not @has value
      @items[value] = value
      @ownLength++
      true
    false

  remove: (value) ->
    if @has value
      delete @items[value]
      @ownLength--
      true
    false

  has: (value) ->
    value of @items
    # items.hasOwnProperty(value) # All JavaScript objects have the hasOwnProperty method

  clear: () ->
    @items = {}

  size: () ->
    log "ownLenght is: #{@ownLength}"
    Object.keys(@items).length # method: keys - returns an array of all properties of a given object

  sizeLegacy: () ->
    count = 0
    for prop of @items
      if @items.hasOwnProperty(prop)
        ++count
    count

  values: () ->
    Object.keys(@items)

  valuesLegacy: () ->
    keys = []
    for key of @items
      keys.push key
    keys

  union: (otherSet) ->
    unionSet = new Set()

    values = @values()
    for i of values
      unionSet.add values[i]

    values = otherSet.values()
    for i of values
      unionSet.add values[i]

    unionSet

  intersection: (otherSet) ->
    intersectionSet = new Set()

    values = @values()
    log "values of setA: #{values}"
    for i of values
      if otherSet.has values[i]
        intersectionSet.add values[i]

    intersectionSet

  difference: (otherSet) ->
    differenceSet = new Set() # all the values that exist in A but not B

    values = @values()
    for i of values
      if not otherSet.has values[i]
        differenceSet.add values[i]

    differenceSet

  subset: (otherSet) ->
    if @size() > otherSet.size()
      false
    else
      values = @values()
      for i of values
        if not otherSet.has values[i]
          log "A is not a subset of B"
          return false
      log "A is a subset of B"
      true

# set = new Set()
# set.add(1)
# set.add(2)
# log set.has(1)
# log "size method: #{set.size()}"
# log "#{set.sizeLegacy()} is a Legacy size"
# log set.values()
# log set.valuesLegacy()

# setA = new Set()
# setB = new Set()

# # setA.add 1
# setA.add 2
# setA.add 3

# setB.add 2
# setB.add 3
# setB.add 4
# setB.add 5
# setB.add 6

# log setA.size()
# log setA.values()
# log setB.size()
# log setB.values()

# unionAB = setA.union setB
# log unionAB.values()

# intersectionAB = setA.intersection setB
# log intersectionAB.values()

# diffAB = setA.difference setB
# log diffAB.values()

# subsetAB = setA.subset setB


# DICTIONARIES 118/218 = maps

# ECMAScript 6 contains an implementation of the Map

class Dictionary
  constructor: (items) ->
    @items = {}

  set: (key, value) ->
    @items[key] = value

  remove: (key) ->
    if @has key
      delete @items[key]
      return true
    else
      false

  has: (key) ->
    key of @items

  get: (key) ->
    if @has(key) then @items[key] else undefined

  clear: () ->
    @items = {}

  size: () ->
    Object.keys(@items).length

  keys: () ->
    keys = []
    for key, val of @items
      if @has key then keys.push key
    key

  values: () ->
    values = []
    for key of @items
      if @has(key) then values.push @items[key]
    values

  getItems: () ->
    @items


# dict = new Dictionary()
# dict.set 'Gandalf', 'gandalf@email.com'
# dict.set 'John', 'johnsnow@email.com'
# dict.set 'Tyrion', 'tyrion@email.com'

# log dict.has 'Gandalf'
# log dict.has 'John'

# dict.remove 'John'

# log dict.has 'John'
# log dict.has 'Tyrion'

# log dict.get 'Tyrion'
# log dict.values()
# log dict.keys()
# log dict.size()
# log dict.getItems()


# HASH TABLES 123/218 = hash maps
# Hashing consists of finding a value in a data structure in the shortest time possible.
# "lose lose" hash function - simply sum up the ASCII values of each character of the key length.

class HashTable
  constructor: (table, lastHash) ->
    @table = []
    @lastHash = 0

  loseloseHashCode: (key) ->
    hash = 0
    for i in key
      hash += i.charCodeAt()
    hash # % 37

# better than the "loselose" hash function is djb2:
# http://web.archive.org/web/20071223173210/http://www.concentric.net/~Ttwang/tech/inthash.htm

  djb2HashCode: (key) ->
    hash = 5381 # initializing the hash variable with a prime number
    for i in key
      hash = hash * 33 + i.charCodeAt()
    hash % 1013

  put: (key, value) ->
    position = @loseloseHashCode key
    log position + ' - ' + value
    @table[position] = value

  remove: (key) ->
    @table[@loseloseHashCode(key)] = undefined

  get: (key) ->
    @table[@loseloseHashCode(key)]

# Methods to handle (key) collisions: separate chaining, linear probing, and double hashing.

# SEPARATE CHAINING

# The separate chaining technique consists of creating a linked list for each position of the table and store the elements in it.
# ValuePair class to represents the element we will add to the LinkedList instance.

  class ValuePair
    constructor: (@key, @value) ->

    toString: () ->
      return "[ #{@key} - #{@value} ]"

  putSC: (key, value) ->
    position = @loseloseHashCode key
    log position + ' -SC- ' + value
    if @table[position] is undefined
      @table[position] = new LinkedList() # line 205
    @table[position].append(new ValuePair(key, value))

  getSC: (key) ->
    position = @loseloseHashCode key
    if @table[position] != undefined
      current = @table[position].getHead()
      while current.next
        if current.element.key is key
          return current.element.value
        current = current.next
      if current.element.key is key
        return current.element.value
    undefined

  removeSC: (key) ->
    position = @loseloseHashCode key
    if @table[position] != undefined
      current = @table[position].getHead()
      while current.next
        if current.element.key is key
          @table[position].remove(current.element)
          if @table[position].isEmpty()
            @table[position] = undefined
          return true
        current = current.next
      if currnet.element.key is key
        @table[position].remove current.element
        if @table[position].isEmpty()
          @table[position] = undefined
        return true
    false

# LINEAR PROBING

# When we try to add a new element, if the position index is already occupied, then we try index +1.
# If index +1 is occupied, then we try index + 2, and so on.

  putLP: (key, value) ->
    position = @loseloseHashCode key
    @lastHash = position if position > @lastHash
    if @table[position] == undefined
      @table[position] = new ValuePair key, value
    else
      index = position + 1
      while @table[index] != undefined
        index = index + 1
      log index + " index of #{key}"
      @table[index] = new ValuePair key, value

  getLP: (key) ->
    log key
    position = @loseloseHashCode key
    log position
    if @table[position] isnt undefined
      if @table[position].key is key
        return @table[position].value
      else
        index = position + 1
        while (@table[index] is undefined or @table[index].key isnt key) and index <= @lastHash
          index = index + 1
        if @table[index] isnt undefined
          if @table[index].key is key
            return @table[index].value
          else
            undefined

  removeLP: (key) ->
    position = @loseloseHashCode key
    if @table[position] != undefined
      if @table[position].key is key
        @table[position] = undefined
      else
        index = position + 1
        while @table[index] == undefined or @table[index].key != key
          if @table[index].key is key
            return @table[index] = undefined
          else
            index = index + 1
        if @table[index].key is key
          return @table[index] = undefined
    undefined


# hash = new HashTable()

# hash.putLP 'Gandalf', 'gandalf@email.com'
# hash.putLP 'John', 'johnsnow@email.com'
# hash.putLP 'Tyrion', 'tyrion@email.com'
# hash.putLP 'ohnJ', 'john@email.com'
# hash.putLP 'hnJo', 'snow@email.com'

# log hash.getLP 'ohnJ'
# hash.removeLP 'ohnJ'
# log hash.getLP 'ohnJ'
# log hash.getLP 'John'
# log hash.getLP 'hnJo'

# log hash.djb2HashCode 'Gandalf'


# TREES 140/218

# tree is an abstract model of a hierarchical structure
# connections between the nodes are called edges in tree terminology
# key is how a tree node is known in tree terminology

class BinarySearchTree
  constructor: () ->

  class Node
    constructor: (@key) ->
      @left = null
      @right = null

  root = null # like head in LinkedList

  insert: (key) ->
    newNode = new Node key
    if root is null then root = newNode else @insertNode(root, newNode)

  insertNode: (node, newNode) =>
    if newNode.key < node.key
      if node.left is null then node.left = newNode else @insertNode(node.left, newNode)
    else
      if node.right is null then node.right = newNode else @insertNode(node.right, newNode)

  # An application of in-order traversal would be to sort a tree.
  # The inOrderTraverse method receives a callback function as a parameter, that can be used to perform
  # the action we would like to execute when the node is visited - the visitor pattern:

  inOrderTraverse: (callback) ->
    @inOrderTraverseNode root, callback

  inOrderTraverseNode: (node, callback) =>
    if node isnt null # the base case of the recursion algorithm
      @inOrderTraverseNode node.left, callback
      callback node.key + ' in'
      @inOrderTraverseNode node.right, callback

  # An application of pre-order traversal could be to print a structured document.
  # Pre-order traversal visits the node prior to its descendants.

  preOrderTraverse: (callback) ->
    @preOrderTraverseNode root, callback

  preOrderTraverseNode: (node, callback) =>
    if node isnt null
      callback node.key + ' pre'
      @preOrderTraverseNode node.left, callback
      @preOrderTraverseNode node.right, callback

  # A post-order traversal visits the node after it visits its descendants.
  # An application of post-order could be computing the space used by a file in a directory and its subdirectories.

  postOrderTraverse: (callback) ->
    @postOrderTraverseNode root, callback

  postOrderTraverseNode: (node, callback) =>
    if node isnt null
      @postOrderTraverseNode node.left, callback
      @postOrderTraverseNode node.right, callback
      callback node.key + ' post'

  # minimum value is always on the left side of the tree, and maximum value is on the right side of the tree

  min: ->
    @minNode(root) # root for searching whole tree / can search also subtree

  # traverse left edge of the tree until node at the highest level is found :: same for max
  minNode: (node) =>
    if node
      while node and node.left isnt null
        node = node.left
        log node
      return node.key
    null

  max: ->
    @maxNode(root)

  maxNode: (node) =>
    if node
      while node and node.right isnt null
        node = node.right
      return node.key
    null

  search: (key) ->
    @searchNode(root, key)

  searchNode: (node, key) =>
    if node is null
      return false
    if key < node.key
      @searchNode node.left, key
    else if key > node.key
      @searchNode node.right, key
    else
      true

  remove: (key) ->
    root = @removeNode(root, key)

  findMinNode: (node) =>
    while node and node.left isnt null
      node = node.left
    node

  removeNode: (node, key) =>
    if node is null
      return null
    if key < node.key
      node.left = @removeNode node.left, key
      return node
    else if key > node.key
      node.right = @removeNode node.right, key
      return node
    else
      if node.left is null and node.right is null # leaf
        node = null
        # need to assign null to its parent node - done by returning null
        # parent pointer to the node will always receive the value returned from the function
        return node
      if node.left is null # node with only one child
        node = node.right
        return node
      else if node.right is null
        node = node.left
        return node
      aux = @findMinNode(node.right)
      node.key = aux.key
      node.right = @removeNode node.right, aux.key
      node


printNode = (value) ->
  log value

# BST problem: one branch can have low level and other high level
# AVL tree = self balancing BST tree (Adelson-Velskii-Landin) - both sides max diff = 1 level
# More trees (AVL and RedBlackTree) at:
# https://pl.wikipedia.org/wiki/Kopiec_(informatyka)
# https://pl.wikipedia.org/wiki/Drzewo_czerwono-czarne
# https://github.com/loiane/javascript-datastructures-algorithms/tree/second-edition/chapter08

# tree = new BinarySearchTree

# tree.insert 11
# tree.insert 7
# tree.insert 15
# tree.insert 5
# tree.insert 3
# tree.insert 9
# tree.insert 8
# tree.insert 10
# tree.insert 13
# tree.insert 12
# tree.insert 14
# tree.insert 20
# tree.insert 18
# tree.insert 25
# tree.insert 6

# tree.inOrderTraverse printNode
# tree.preOrderTraverse printNode
# tree.postOrderTraverse printNode

# log if tree.search(5) then 'key found' else 'key not found'
# log if tree.search(1 ) then 'key found' else 'key not found'

# log tree.remove 16

# STACK 62/218

class Stack
  constructor: (items) ->
    @items = []

  push: (element) ->
    @items.push element
  pop: ->
    @items.pop()
  peek: ->
    @items[@items.length - 1]
  isEmpty: ->
    return @items.length == 0
  clear: ->
    @items = []
  size: ->
    @items.length


# GRAPHS 162/218

class Graph
  constructor: (vertices, adjList, time) ->
    @vertices = []
    @adjList = new Dictionary # line 562
    @time = 0

  addVertex: (v) ->
    @vertices.push v
    @adjList.set v, []

  addEdge: (v, w) ->
    @adjList.get(v).push(w) # to implement a directed graph this line is enough
    # @adjList.get(w).push(v)

  toString: () ->
    s = ''
    for i in @vertices
      s += i + ' -> '
      neighbors = @adjList.get i
      for j in neighbors
        s += j + ' '
      s += '\n'
    return s

  # Graph traversals
  # - breadth-first search (BFS)
  # - depth-first search (DFS)
  # Traversing a graph can be used to find a specific vertex or to find a path between two vertices,
  # check whether the graph is connected, check whether it contains cycles, and so on.
  # • White: This represents that the vertex has not been visited
  # • Grey: This represents that the vertex has been visited but not explored
  # • Black: This represents that the vertex has been completely explored

  initColor: ->
    color = []
    for i in @vertices
      color[i] = 'white'
    color

  bfs: (v, callback) ->
    color = @initColor()
    queue = new Queue() # line 161
    distance = []
    predecessor = []
    loopCount = 0
    forLoops = 0

    queue.enqueue v
    for i in @vertices
      distance[i] = 0
      predecessor[i] = null
    while not queue.isEmpty()
      loopCount += 1
      log queue
      u = queue.dequeue()
      log u
      neighbors = @adjList.get u
      log neighbors
      color[u] = 'grey'
      log color[u]
      for w in neighbors
        forLoops += 1
        if color[w] is 'white'
          color[w] = 'grey'
          distance[w] = distance[u] + 1
          predecessor[w] = u
          queue.enqueue w # new queue - level lower
          log queue
          log loopCount
          log forLoops
      color[u] = 'black'
    return {
      distance: distance
      predecessor: predecessor
    }

  dfs: (callback) ->
    color = @initColor()
    discoveryTime = []
    finishTime = []
    predecessor = []
    @time = 1
    for i in @vertices
      discoveryTime[i] = 0
      finishTime[i] = 0
      predecessor[i] = null
    for i in @vertices
      if color[i] is 'white'
        @dfsVisit(i, color, discoveryTime, finishTime, predecessor, callback)
    return {
      discovery: discoveryTime
      finished: finishTime
      predecessor: predecessor
    }

  # rule: 1 <= discoveryTime[u] < finishTime[u] <= 2|V|

  dfsVisit: (u, color, discoveryTime, finishTime, predecessor, callback) ->
    log "discovered #{u} at #{@time}"
    color[u] = 'grey'
    discoveryTime[u] = ++@time
    if callback
      callback u
    neighbors = @adjList.get u
    for w in neighbors
      if color[w] is 'white'
        predecessor[w] = u
        @dfsVisit(w, color, discoveryTime, finishTime, predecessor, callback)
    color[u] = 'black'
    finishTime[u] = ++@time
    log "explored #{u} at #{@time}"

printVertex = (v) ->
  log "visited vertex: #{v}"


# graph = new Graph()
# myVertices = ['A','B','C','D','E','F','G','H','I']

# for i in myVertices
#   graph.addVertex i

# graph.addEdge('A', 'B')
# graph.addEdge('A', 'C')
# graph.addEdge('A', 'D')
# graph.addEdge('C', 'D')
# graph.addEdge('C', 'G')
# graph.addEdge('D', 'G')
# graph.addEdge('D', 'H')
# graph.addEdge('B', 'E')
# graph.addEdge('B', 'F')
# graph.addEdge('E', 'I')

# log graph.toString()
# graph.bfs(myVertices[0], printVertex)
# shortestPathA = graph.bfs(myVertices[0])
# log shortestPathA

# fromVertex = myVertices[0]
# i = 1
# while i < myVertices.length
#   toVertex = myVertices[i]
#   path = new Stack # line 949
#   v = toVertex
#   while v isnt fromVertex
#     path.push v
#     v = shortestPathA.predecessor[v]
#   path.push fromVertex
#   s = path.pop()
#   while not path.isEmpty()
#     s += ' - ' + path.pop()
#   log s
#   i++

  # There is Dijkstra's algorithm, which solves the single-source shortest path problem
  # for example. The Bellman–Ford algorithm solves the single-source problem if edge
  # weights are negative. The A* search algorithm provides the shortest path for a single
  # pair of vertices using heuristics to try to speed up the search. The Floyd–Warshall
  # algorithm provides the shortest path for all pairs of vertices.

# graph.dfs printVertex
# graph.dfs()

# graph = new Graph
# myVertices = ['A','B','C','D','E','F']

# for i in myVertices
#   graph.addVertex i

# graph.addEdge('A', 'C')
# graph.addEdge('A', 'D')
# graph.addEdge('B', 'D')
# graph.addEdge('B', 'E')
# graph.addEdge('C', 'F')
# graph.addEdge('E', 'F')

# result = graph.dfs()


# SORTING AND SEARCHING ALGORITHMS 186/218

class ArrayList
  constructor: (array) ->
    @array = []

  insert: (item) ->
    @array.push item

  toString: ->
    @array.join()

  swap: (index1, index2) ->
    aux = @array[index1]
    @array[index1] = @array[index2]
    @array[index2] = aux

  swapQuickSort: (array, index1, index2) ->
    aux = array[index1]
    array[index1] = array[index2]
    array[index2] = aux

# bubble sort

  bubbleSort: ->
    length = @array.length
    i = 0
    while i < length
      j = 0
      while j < length - 1
        if @array[j] > @array[j + 1]
          @swap j, j + 1
        j++
      i++

  modifiedBubbleSort: ->
    length = @array.length
    i = 0
    while i < length
      j = 0
      while j < length - 1 - i # substruct the number of passes (i) from the inner loop to avoid all unnecessary comparisons done by the innner loop
        if @array[j] > @array[j + 1]
          @swap j, j + 1
        j++
      i++

# selection sort - find min val, place it in 1st pos, then find 2nd minimum value and place it in 2nd pos, and so on.
# The selection sort is also an algorithm of complexity O(n2). Like the bubble sort,
# it contains two nested loops, which are responsible for the quadratic complexity.

  selectionSort: ->
    len = @array.length
    for i in [0...len - 1]
      indexMin = i
      for j in [i...len]
        if @array[indexMin] > @array[j]
          indexMin = @array[j]
      if i isnt indexMin
        @swap i, indexMin

# insertion sort
# considering the first item already sorted

  insertionSort: ->
    len = @array.length
    for i in [1...len]
      j = i
      temp = @array[i]
      while j > 0 and @array[j - 1] > temp
        @array[j] = @array[j - 1]
        j--
      @array[j] = temp

# merge sort - divide and conquer approach
# first from all the above that gives a good performance, with a complexity of O(n log n)
# Array.prototype.sort - ECMA does not define which algo to use, so each browser can implement its own (Mozilla = merge, Chrome = quick)

  mergeSort: ->
    @array = @mergeSortRec @array

  mergeSortRec: (arr) ->
    len = arr.length
    return arr if len is 1
    mid = Math.floor len / 2
    left = arr.slice 0, mid
    right = arr.slice mid, len
    @merge @mergeSortRec(left), @mergeSortRec(right)

  merge: (left, right) ->
    result = []
    il = 0
    ir = 0

    while il < left.length and ir < right.length
      if left[il] < right[ir]
        result.push left[il++]
      else
        result.push right[ir++]
    while il < left.length
      result.push left[il++]
    while ir < right.length
      result.push right[ir++]
    result

# quick sort - complexity O(n log n)
#divide and conquer approach

  quickSort: ->
    log @array
    @quick @array, 0, @array.length - 1

  quick: (array, left, right) ->
    index = @partition(array, left, right) if array.length > 1
    @quick(array, left, index - 1) if left < index - 1
    @quick(array, index, right) if index < right

  partition: (array, left, right) ->
    pivot = array[Math.floor (right + left) / 2]
    i = left
    j = right
    while i <= j
      while array[i] < pivot
        i++
      while array[j] > pivot
        j--
      if i <= j
        @swapQuickSort array, i, j
        i++
        j--
    i

# SEARCHING ALGORITHMS 204/218

# sequential or linear search - consists of comparing each element of the data with the one we are looking for

  sequentialSearch: (item) ->
    for i in @array
      return "item #{i} exists in #{@array} and its index is: #{@array.indexOf(i)}" if i is item
    -1

# binary search requires sorted array

  binarySearch: (item) ->
    arr = @mergeSort()
    low = 0
    high = arr.length - 1
    while low <= high
      midIndex = Math.floor((low + high) / 2)
      element = arr[midIndex]
      if element < item
        low = midIndex + 1
      else if element > item
        high = midIndex - 1
      else if element is item
        return "#{element} is what you're looking for"
    "#{item} not found"


# ---------------------------------------------------

# createNonSortedArray = (size) ->
#   array = new ArrayList
#   i = size
#   while i > 0
#     array.insert i
#     i--
#   array

createNonSortedArray = (size) ->
  array = new ArrayList
  for i in [size..1]
    array.insert i
  # log array
  array

threeElArr = ->
  arr = new ArrayList
  arr.insert 3
  arr.insert 5
  arr.insert 4
  # log arr
  arr

myArray = createNonSortedArray 5
# log myArray.toString()
# # myArray.selectionSort()
# # myArray.mergeSort()
# myArray.quickSort()
# log myArray.toString()

# my3Array = threeElArr()
# log my3Array.toString()
# # my3Array.selectionSort()
# my3Array.insertionSort()
# log my3Array.toString()

log myArray.binarySearch 6

