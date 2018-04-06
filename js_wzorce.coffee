# javascript wzorce
# author source: https://github.com/stoyan

log = console.log.bind(console)
# console.dir is the way to see all the properties of specified javascipt object in console
#  by which developer can easily get the properties of object
dir = console.dir.bind(console)
fs = require 'fs'
numFile = './numbers.txt'
strFile = './string.txt'
EventEmmiter = require 'events'
server = require('http').createServer()
pry = require 'pry'

after = (ms, fn) -> setTimeout(fn, ms)


# ******************************   PROTOTYPE   *****************************************************************
# filtrowanie właściwości pochodzących z łańcucha prototypowego

# obiekt
man =
  hands: 2
  legs: 2
  heads: 1

Object::myFunction = ->
  log('myFunction is my element') if (typeof Object::myFunction is 'undefined' or Object::myFunction isnt 'function')

for i of man
  log i, ":", man[i]
# RETURNS::
# hands : 2
# legs : 2
# heads : 1
# myFunction : function () ...
hasOwn = Object::hasOwnProperty
for i of man
  if hasOwn.call(man, i)
    log i, ":", man[i]
# RETURNS::
# hands : 2
# legs : 2
# heads : 1

for own key, value of man
  log "coffee's for own: #{key} - #{value}"

# ******************************   CONSTRUCTORS   *********************************************************

# !!! Własne funkcje konstruujące :: strona 52 - wytłumaczenie procesu: var sth = new Something
# !!! Wartość zwracana przez konstruktor :: strona 53
# !!! Wzorce wymuszania użycia new :: strona 54
#Samowywołujący się konstruktor
if !(@ instanceof arguments.callee)
  return new arguments.callee()

# JSON

# Przeciwieństwem metody przetwarzającej format JSON - JSON.parse() - jest metoda
# JSON.stringify(), która przyjmuje obiekt lub tablicę (a nawet typ prosty) i zamienia je na
# ciąg znaków w formacie JSON.

# ******************************   ERRORS   ****************************************************************

# Obiekty błędów Error(), SyntaxError(), TypeError() ... mają właściwości/keys: name oraz message
# throw działa prawidłowo nie tylko dla obiektów utworzonych za pomocą konstruktorów błędów,
# ale pozwala na zgłoszenie dowolnego obiektu, który może zawierać właściwości name, message
# lub dowolne inne, które powinny trafić do instrukcji catch

try
# stało się coś złego, zgłoś błąd
  throw
    name: 'MyError'
    message: 'wtf'
    extra: 'shit happens'
    remedy: () -> log 'genericErrorHandler' # genericErrorHandler = kto powinien obsłużyć błąd
catch e
  log e.message
  log e.name
  e.remedy()

# ******************************   FUNCTIONS   *************************************************************

# Deklaracje funkcji mogą pojawiać się jedynie w „kodzie programu”, czyli wewnątrz innych
# funkcji lub w przestrzeni globalnej. Definicji nie można przypisać do zmiennych lub właściwości
# albo wykorzystać w wywołaniach funkcji jako parametru.

# deklaracja: (nie ma w coffee)
`function foo() {}`
# wyrażenie: (nie ma nazwanego wyrażenie fn w coffee)
`var sth = function sth() {};`
() ->
sth = () ->

# ******************************   HOISTING   **************************************************************

# deklaracja - przeniesiona wraz z wartością wywołania
# wyrażenie - przeniesiona zmienna (fn nie wywołana), która do momentu osiągnięcia przez kod definicji ma wartość 'undefined'

# CALLBACK
findNodes = (callback) ->
  nodes = []
  found = 'znaleziony cb'
  callback = false if typeof callback isnt 'function'
  while i
    # some logics here
    callback(found) if callback
    nodes.push(found)
    i = false
    log nodes

hide = (node) ->
  #log 'hide the DOM node'
  log "hide the node number #{node}"
  #node.style.display = 'none'

findNodes(hide)

# if callback is a method of an object :: strona 70
myapp = {}
myapp.color = "green"
myapp.paint = (node) ->
  #node.style.color = @color
  log "the node is #{node}"

# przekazanie funkcji zwrotnej wraz z referencją do obiektu, do którego należy funkcja zwrotna

findNodes = (callback, cb_obj) ->
  found = 'foundeded'
  callback.call(cb_obj, found) if typeof callback is 'function'
  callback = cb_obj[callback] if typeof callback is 'string'

findNodes(myapp.paint, myapp)
log findNodes('color', myapp)


# ******************************   CLOSURE counter is not available to the outside world   *******************

setup = () ->
  counter = 0
  ret = () ->
    counter += 1
  ret

next = setup()
# wywołanie setup zwraca funkcję ret
log next()
log next()

# ******************************   SELF DEFINED / REDEFINED functions :: lazy function :: more on strona 75

# Wzorzec ten przydaje się, gdy funkcja ma do wykonania pewne podstawowe zadania inicjacyjne,
# ale są one przeprowadzane tylko jednokrotnie. Ponieważ nie ma potrzeby ich powtarzać,
# odpowiedzialną za nie część kodu można usunąć. W takich sytuacjach samodefiniująca
# się funkcja może uaktualnić własną implementację.

aFunction = () ->
  log 'first definition of aFunction'
  aFunction = () ->
    log 'second definition of aFunction'

aFunction()
aFunction()


# IIFE (Immediately Invoked Function Expression)
# dostęp do obiektu globalnego uzyskiwany za pomocą global, and other arguments
((global, who, today) ->
  log 'Immediately Invoked Function Expression'
  days = ['niedz.', 'pon.', 'wt.', 'śr.', 'czw.', 'pt.', 'sob.']
  dzisiaj = today
  msg = "#{who}, dziś jest #{days[dzisiaj.getDay()]} #{dzisiaj.getDate()}"
  log msg
)(@, 'Tomek', new Date())

result = do -> 2+2
log result

defineObjKeysWithIIFE =
  msg: do ->
    who = 'Tomka'
    what = 'zadzwoń do'
    return "#{what} #{who}"
  getMsg: -> log @msg

defineObjKeysWithIIFE.getMsg()


# Natychmiastowa inicjalizacja obiektu :: strona 80

# Literał trzeba otoczyć nawiasami okrągłymi, by poinformować interpreter języka, że
# nawiasy klamrowe są literałem obiektu, a nie blokiem kodu do wykonania (na przykład kodem
# pętli for). Po nawiasie zamykającym następuje natychmiastowe wykonanie metody init()

({
  maxWidth: 500
  maxHeight: 1000
  getSquare: () ->
    @maxWidth * @maxHeight
  init: () ->
    log @getSquare()
}).init()


# ****************************** Funkcje — wzorzec zapamiętywania :: CACHE   *******************************

# Jeśli istnieje więcej parametrów lub są one bardziej złożone,
# uniwersalnym rozwiązaniem będzie ich serializacja. Parametry funkcji można zserializować
# do formatu JSON, a następnie wykorzystać jako klucze w obiekcie cache.
# Serializacja obiektów powoduje tracenie przez nie „tożsamości”. Jeśli dwa różne obiekty
# mają takie same właściwości, oba będą współdzieliły ten sam wpis w obiekcie zapamiętanych wyników.

# with arguments.callee :: strona 83

myFunc1 = (param) ->
  if not myFunc1.cache[param]
    result = {}
    # some operations
    myFunc1.cache[param] = result
  myFunc1.cache[param]

# obiekt służący do zapamiętywania wyników
myFunc1.cache = {}
myFunc1('name')
myFunc1.cache.name = 'tomek is fucking cached'
log myFunc1.cache.name

myFunc2 = () ->
  cachekey = JSON.stringify(Array::slice.call(arguments))
  result = {}
  if not myFunc2.cache[cachekey]
    result = {}
    # some operations
    myFunc2.cache[cachekey] = result
  myFunc2.cache[cachekey]

myFunc2.cache = {}


# ******************************   Obiekty konfiguracyjne   **************************************************

# zalety:
# • nie trzeba pamiętać parametrów i ich kolejności
# • można bezpiecznie pominąć parametry opcjonalne
# • są bardziej klarowne
# • łatwiej jest dodać lub usunąć parametry
# wady:
# • trzeba pamiętać nazwy parametrów
# • nazw właściwości nie da się zminimalizować

conf =
  username: "batman"
  first: "Bruce"
  last: "Wayne"

addPerson = (conf) ->
  log conf

addPerson(conf)

# Metoda apply() przyjmuje dwa parametry: pierwszym jest obiekt, który wewnątrz funkcji
# będzie dostępny pod zmienną this, a drugim lista argumentów, która wewnątrz funkcji
# będzie dostępna pod zmienną arguments. Jeśli pierwszy parametr będzie miał wartość null,
# this w funkcji będzie wskazywało na obiekt globalny, czyli uzyska się sytuację taką jak
# w przypadku wywołania funkcji nieprzypisanej do obiektu.

addPerson.apply(null, [conf])

# Jeśli funkcja jest metodą obiektu pierwszym argumentem metody apply() jest obiekt.
# addPerson.apply(obj, [conf]) :: this wskazuje na obiekt: obj


# ******************************   CURRYING (with closure)   ************************************************

add = (a,b) ->
  if not b?
  # if typeof b is 'undefined'
  # if arguments.length < add.length
    return (c) ->
      c + a
  a + b

dsa = add(5)
log dsa(4)

# funkcja dodająca do dowolnej funkcji aplikację częściową:
# schonfinkelize zwraca funckje, która ma dostęp do slice i stored_args - dostępne dzięki closure
schonfinkelize = (fn) ->
  slice = Array.prototype.slice
  stored_args = slice.call(arguments, 1) # store all args but the first, in array, since the first arg is a partial application function
  () ->
    new_args = slice.call(arguments)
    args = stored_args.concat(new_args)
    fn.apply(null, args)

added = (x, y, z) ->
  x + y + z

log added(4,3,0)

newAdd = schonfinkelize(added,15, 5)
log newAdd(1)


# ******************************   Przestrzeń Nazw   ************************************************


# Przed dodaniem właściwości lub utworzeniem przestrzeni nazw lepiej jest sprawdzić, czy ta już istnieje
MYAPP = MYAPP or {}
# funkcja pomocnicza zajmująca się szczegółami dotyczącymi przestrzeni nazw
MYAPP.namespace = (ns_string) ->
  parts = ns_string.split('.')
  parent = MYAPP
  parts = parts.slice(1) if parts[0] is 'MYAPP'
  for i in parts
    # if typeof parent[parts[i]] == 'undefined'
    if not parent[i]?
      parent[i] = {}
    parent = parent[i]
  parent

module2 = MYAPP.namespace('MYAPP.modules.module2')
module3 = MYAPP.namespace('MYAPP.modules.module3')
log module2 is MYAPP.modules.module2
log MYAPP
log MYAPP.namespace


# ******************************   METODY I WŁAŚCIWOŚCI PRYWATNE   *********************************************

# Wystarczy otoczyć dane, które mają pozostać prywatne, funkcją, by mieć pewność,
# że są dla tej funkcji zmiennymi lokalnymi i nie wyciekają na zewnątrz.

class Gadget
  @lastName = (lN) -> log lN
  name = 'iPod' # zmienna prywatna
  getName: => "getName returns #{name}" # funkcja publiczna

toy = new Gadget
  # name jest niezdefiniowane, bo jest zmienną prywatną
log toy.name # undefined
  # metoda publiczna ma dostęp do name
log toy.getName() # "iPod"
  # getName() jest metodą uprzywilejowaną, ponieważ ma szczególną własność — ma dostęp do zmiennej prywatnej name.
# static properties
Gadget.lastName('tomac')

class Foo
  # this will be our private method. it is invisible outside of the current scope
  foo = -> log "foo"
  # this will be our public method. Note that it is defined with ':' and not '='
  # '=' creates a *local* variable # : adds a property to the class prototype
  bar: -> foo()

Foo::foo1 = () -> log "foo1"
faz = new Foo
faz.foo2 = -> log "foo2"

for i of faz
  log i, ":", faz[i]

faz.bar()
faz.foo2()

# Problemy z prywatnością:
# 1. Niektóre wcześniejsze wersje przeglądarki Firefox dopuszczały przekazanie do metody
# eval() drugiego parametru, który określał obiekt kontekstu. Dawało to możliwość prześlizgnięcia
# się do zakresu prywatnego funkcji.
# 2. Jeśli zawartość zmiennej prywatnej zostanie zwrócona przez metodę uprzywilejowaną
# bezpośrednio i zmienna ta jest tablicą lub obiektem, zewnętrzny kod będzie mógł ją
# zmodyfikować jako przekazaną przez referencję.

# 2.
class Gadget_2
  specs =
    screenWidth: 333
    screenHight: 777
    color: 'black'
  getSpecs: -> specs

sp = new Gadget_2
s = sp.getSpecs()
log s
s.price = 500
s.color = 'red'
log sp.getSpecs()
log sp.specs

# Problemem jest fakt zwracania przez getSpec() referencji do obiektu specs. Dzięki temu
# użytkownik obiektu Gadget może zmodyfikować ten ukryty i teoretycznie prywatny obiekt.

# nieprzekazywanie prywatnych obiektów oraz tablic w sposób bezpośredni, zmodyfikowanie metody getSpecs()
# w taki sposób, by zwracała nowy obiekt tylko z tymi danymi, które są niezbędne dla wywołującego

# Literały obiektów a prywatność: literał obiektu należy otoczyć funkcją anonimową wywoływaną natychmiast po zadeklarowaniu

myLitObj = do () ->
  name = 'ojej'
  { getName: -> log name }

myLitObj.getName()

# połączenie 2 wzorców: zmiennych prywatnych w konstruktorze i właściwości prywatnych w literałach obiektów
Gadget::twoPatterns = do () ->
  browser = 'Mobile kit'
  { getBrowser: -> log browser }

for i of toy
  log i, ":", toy[i]

`Gadget.prototype = (function () {
    // zmienna prywatna
  var br = "Mobile WebKit";
    // prototyp składowych publicznych
  return {
    getBrowser: function () {
      return br;
    }
  };
}());`

toy.twoPatterns.getBrowser()
# log toy.getBrowser()


# Udostępnianie funkcji prywatnych jako metod publicznych API ? ********************************* ?

myarr = {}
do ->
  astr = "[object Array]"
  toString = Object.prototype.toString
  isArray = (a) -> toString.call(a) is astr
  indexOf = (haystack, needle) ->
    for v,i in haystack
      return i if v is needle
    1
  myarr =
    isArray: isArray
    indexOf: indexOf
    inArray: indexOf

# log myarr.isArray([1,2])
# log myarr.isArray({0: 1})
# log myarr.indexOf(["a", "b", "z"], "z")
# log myarr.inArray(["a", "b", "z"], "z")


# ******************************   WZORZEC MODUŁU   ***********************************************


MYAPP.namespace('MYAPP.utilities.array')
log MYAPP

# MYAPP.utilities.array = do () ->
#   # zależności - inne np moduły
#   uobj = MYAPP.utilities.object
#   ulang = MYAPP.utilities.lang
#   array_string = "[object Array]"
#   ops = Object.prototype.toString
#   return
#     isArr: (a) -> ops.call(a) is array_string
#     inArr: (haystack, needle) ->
#       for v,i in haystack
#         return true if v is needle
# log MYAPP.utilities.array
# log MYAPP.utilities.array.inArr(["a", "b", "z"], "z")

# better version of the above:

MYAPP.utilities.array = do ->
  array_string = "[object Array]"
  ops = Object.prototype.toString
  isArr = (a) -> ops.call(a) is array_string
  inArr = (haystack, needle) ->
    for v,i in haystack
      return true if v is needle
  return
    sArr: isArr
    nArr: inArr

log MYAPP.utilities.array.ops
log MYAPP.utilities.array
log MYAPP.utilities.array.nArr(["a", "b", "z"], "z")

# import zmiennych globalnych do modułu
MYAPP.utilities.module = ((app, global) -> )(MYAPP, @)
log MYAPP.utilities


# ******************************   WZORZEC PIASKOWNICY   **********************************************

# Obiekt box stanowi odpowiednik obiektu MYAPP ze wzorca przestrzeni nazw — będzie zawierał
# całą funkcjonalność biblioteczną niezbędną do zapewnienia prawidłowego działania aplikacji.

# utworzenie obiektu, który wykorzystuje dwa fikcyjne moduły: ajax i event.
Sandbox = () ->
  args = Array.prototype.slice.call(arguments) # zamiana argumentów na tablicę
  callback = args.pop() # ostatni argument to funkcja wywołania zwrotnego
  modules = if (args[0] and typeof args[0] is "string") then args else args[0]
  log "args are #{args}"
  log "callback is #{callback}"
  return new Sandbox if not (@ instanceof Sandbox)
  @a = 1 # dodanie w razie potrzeby właściwości do this
  @b = 2
  if not (modules or modules is '*') # dodaj moduły do głównego obiektu this
    modules = []
    for i of Sandbox.modules
      if Sandbox.modules.hasOwnProperty(i)
        modules.push i
  log modules
  for i in modules
    log i
    Sandbox.modules[i](@)
  callback @

Sandbox.prototype =
  name: "Moja aplikacja"
  version: "1.0"
  getName: () ->
    return name


Sandbox.modules = {}
Sandbox.modules.dom = (box) ->
  log "this is box: #{box}"
  box.getElement = -> log 'get element'
  box.getStyle = -> log 'get style'
  box.foo = "foo::bar"
Sandbox.modules.event = (box) ->
  log "this is box: #{box}"
  box.attachEvent = -> log 'attach event'
  box.detachEvent = -> log 'detach event'

# Możemy pominąć new i utworzyć obiekt, który wykorzystuje dwa fikcyjne moduły: ajaxi event.
# Sandbox(['otherDom', 'OtherEvent'], (box) ->
#   # wykorzystanie modułów dom i event
#   Sandbox('ajax', (box) ->
#     # kolejna piaskownica z nowym obiektem box ten box nie jest taki sam jak box poza tą funkcją
#   )
#   # nie ma śladu po module ajax
# )

log Sandbox
log Sandbox.prototype.name
for i of Sandbox.prototype
  log i


# ******************************   Prywatne składowe statyczne   **********************************************


# funkcja otaczająca wykona się od razu i zwróci inną funkcję. Ta zwrócona funkcja zostanie przypisana do
# zmiennej Gadget, stając się konstruktorem.

Gadget_3 = do () ->
  counter = 0
  NewGadget = () -> log "Gadget_3 counter #{counter += 1}"
  NewGadget::getLastId = () -> log "getLastId is #{counter}"
  NewGadget

g1 = new Gadget_3
g2 = new Gadget_3
log g1
log g1 instanceof Gadget_3
g1.getLastId()
for i of g1
  log "this is a property of g1: #{i}"

iphone = new Gadget_3
iphone.getLastId()
ipod = new Gadget_3
ipod.getLastId()

Gadget_3::setPrice = (price) ->
  constructor: (@price) ->
  log price

Gadget_3.isShiny = ->
  log "of'course !"

iphone.setPrice(500)
Gadget_3.isShiny()
# iphone.isShiny() - not gonna work

Gadget_3::isShiny = ->
  log "oczywiście że of'course!"

# pisząc metodę statyczną, trzeba bardzo uważać na użycie this. Wywołanie Gadget.isShiny() oznacza, że this
# wewnątrz isShiny() będzie wskazywało na konstruktor Gadget. W wywołaniu iphone.isShiny() będzie natomiast wskazywało na iphone.

iphone.isShiny()

# Ponieważ przy każdym nowym obiekcie licznik jest zwiększany o 1, statyczna właściwość jest niejako
# unikatowym identyfikatorem każdego obiektu tworzonego za pomocą konstruktora Gadget_3


# ******************************   Wzorzec łańcucha wywołań   **********************************************

# Gdy tworzy się metody, które nie zwracają żadnej sensownej wartości, można zwrócić aktualną
# wartość this, czyli instancję obiektu, na którym metody aktualnie operują. Dzięki tej operacji
# użytkownicy obiektu będą mogli łączyć wywołania metod w jeden łańcuch.

objChain =
  value: 1
  increment: () ->
    @value += 1
    @
  add: (v) ->
    @value += v
    @
  shout: () -> log @value

objChain.increment().add(7).shout()

# ***************************** constants

constant = do ->
  constants = {}
  ownProp = Object::hasOwnProperty
  allowed =
    string: 1
    number: 1
    boolean: 1
  prefix = (Math.random() + '_').slice(10)

  set: (name, value) ->
    return false if @isDefined(name)
    return false if not ownProp.call(allowed, typeof value)
    constants[prefix + name] = value
    true
  isDefined: (name) ->
    ownProp.call(constants, prefix + name)
  get: (name) ->
    log constants[prefix + name] if @isDefined(name)
  listConstants: ->
    log constants


constant.isDefined('maxW')
constant.set('minD', 300)
constant.isDefined('minD')
constant.get('minD')
constant.listConstants()

# ***************************** Metoda method()

if (typeof Function::method isnt "function")
  Function::method = (name, implementation) ->
    @prototype[name] = implementation
    return @

class Person
  constructor: (@name) ->
# Person = (name) ->
#   @name = name

# log typeof Person
# b = new Function
# for i of b
#   log i, ":", b[i]
# log Person.method

Person.method 'getName', () ->
  @name

Person.method 'setName', (name) ->
  @name = name
  @

a = new Person('adam')
for i of a
  log i, ":", a[i]

log "a name: #{a.getName()}"


# ******************************   Dziedziczenie classyczne   **********************************************


# Ogólna zasada dotycząca konstruktorów jest następująca: składowe używane wielokrotnie
# przez różne obiekty należy dodawać do prototypu.

class Parent
  constructor: (name) ->
    @name = name or 'Adam'

Parent::say = -> log @name

class Child extends Parent
  constructor: () ->
    super('super Adam')

kid = new Child()

kid.say()

# W poniższy sposób możne jednak dziedziczyć jedynie właściwości dodane do this wewnątrz konstruktora
# przodka. Składowe dodane do prototypu nie zostaną odziedziczone.
# Obiekty potomne otrzymują kopie odziedziczonych składowych, a nie jedynie ich referencje
# skopiowane właściwości przodka do właściwości rodzica — nie brały w tym udziału żadne referencje __proto__.
# Porzyczanie konstruktora

Child_1 = (c, e) ->
  Parent.apply(@, arguments)

# Dziedziczenie wielobazowe

Cat = ->
  @legs = 4
  @say = -> 'miiaał'

Bird = ->
  @wings = 2
  @fly = true

CatWings = ->
  Cat.apply @
  Bird.apply @

jane = new CatWings
dir jane

# Zalety i wady wzorca pożyczania konstruktora str 122

# pożyczanie i ustawianie prototypu

Child_2 = (a, b, c) ->
  Parent.apply(@, arguments)

Child_2.prototype = new Parent()
# obiekt potomny dziedziczy wszystko po przodku, a jednocześnie ma własne kopie właściwości

# współdzielenie prototypu

inherit = (C, P) ->
  C.prototype = P.prototype
# wada: jeśli dowolny potomek z łańcucha prototypów zmieni prototyp, zauważą to wszystkie obiekty

# konstruktor tymczasowy (pośredniczący) + Zapamiętywanie klasy nadrzędnej + Czyszczenie referencji na konstruktor

inherit_2 = (C, P) ->
  F = ->
  do (C, P) ->
    F.prototype = P.prototype
    C.prototype = new F()
    C.uber = P.prototype
    C.prototype.constructor = C


# PODEJŚCIE KLASOWE

klass = (Parent, props) ->

  Child = ->
    if Child.uber and Child.uber.hasOwnProperty("__construct")
      Child.uber.__construct.apply(@, arguments)
    if Child.prototype.hasOwnProperty("__construct")
      Child.prototype.__construct.apply(@, arguments)

  Parent = Parent or Object
  F = ->
  F.prototype = Parent.prototype
  Child.prototype = new F()
  Child.uber = Parent.prototype
  Child.prototype.constructor = Child

  for i of props
    if props.hasOwnProperty i
      Child.prototype[i] = props[i]

  Child


newClassImplementation =
  __construct: (what) ->
    log "Konstruktor klasy Man"
    @name = what
  getName: () ->
    @name

Man = klass(null, newClassImplementation)


# ******************************   Dziedziczenie prototypowe   **********************************************


# Dziedziczenie prototypowe

object = (o) ->
  F = ->
  F.prototype = o
  new F

parent_3 =
  name: 'dude'

child_3 = object(parent_3)

log child_3.name

child_4 = Object.create(parent_3, {age: {value: 2}})
log child_4.hasOwnProperty "age"

# Dziedziczenie przez kopiowanie właściwości - dotyczy on tylko i wyłącznie obiektów i ich własnych właściwości

extend = (parent, child) ->
  child = child or {}
  for i of parent
    child[i] = parent[i]
  child

dad =
  counts: [1, 22, 333]
  name: 'maestre'

kid = extend dad
log kid.name

extendDeep = (parent, child) ->
  child = child or {}
  toStr = Object::toString
  astr = '[object array]'
  for i of parent
    if parent.hasOwnProperty i
      if typeof parent[i] is 'object'
        child[i] = if (toStr.call(parent[i]) is astr) then [] else {}
        extendDeep(parent[i], child[i])
      else
        child[i] = parent[i]
  child

bigKid = extendDeep dad
log bigKid.name
log bigKid.counts[2]

# Wzorzec wmieszania - mix-in

mixin = ->
  child = {}
  for arg in arguments
    for prop of arg
      if arg.hasOwnProperty prop
        child[prop] = arg[prop]
  child

cake = mixin(
  {eggs: "2 jajka", large: true},
  {butter: 1, salted: true},
  {flour: "3 szklanki"},
  {sugar: "tak!"}
)

log "properties of cake are: "
for i of cake
  if hasOwn.call(cake, i)
    log i, ":", cake[i]

# Pożyczanie metod
myobj = {'tomek': 'sawicki'}
p1 = 'do myobj'
notmyobj =
  doStuff: () -> log "borrowing doStuff #{p1}"
notmyobj.doStuff.apply(myobj, [p1])

for i of myobj
  if hasOwn.call(myobj, i)
    log i, "::", myobj[i]


#notmyobj zawiera metodę doStuff którą pożyczymy/dziedziczymy tymczasowo dla obiektu myobj

f = ->
  # args = [].slice.call(arguments, 1, 3)
  args = Array.prototype.slice.call(arguments, 1, 3)
  log args

# pusta tablica powstaje tylko po to, by można było wywołać jej metodę.
# Array.prototype... nie wymaga niepotrzebnego tworzenia tablicy - bezpośrednie pożyczenie metody od prototypu

f(1,2,3,4,5,6)

# Pożyczenie i przypisanie

one =
  name: 'objekcie'
  say: (greet) ->
    log "#{greet} #{@name}"

one.say('witaj')

two =
  name: 'inny objekcie'

one.say.apply(two, ['hello'])

# global
say = one.say
say('Hi')

# Aby rozwiązać problem, czyli powiązać obiekt z metodą, wystarczy bardzo prosta funkcja:
bind = (object, method) ->
  () -> method.apply(object, [].slice.call(arguments))

# other version

# if typeof Function::bindMe is 'undefined'
#   Function::bindMe = (thisArgs) ->
#     fn = @
#     agrs = slice.call(arguments, 1)
#     return () ->
#       fn.apply(thisArgs, args.concat(slice.call(arguments)))

# Funkcja bind() przyjmuje obiekt o i metodę m, a następnie łączy je ze sobą i zwraca nową
# metodę. Zwrócona funkcja ma dostęp do o i m dzięki domknięciu = nawet po wykonaniu bind() będzie
# ona pamiętała o i m, więc będzie mogła wywołać oryginalny obiekt i oryginalną metodę.
saytwo = bind(two, one.say)
saytwo('hey')

# twosay2 = one.say.bindMe(two)
# twosay2('Bonjour')
# twosay3 = one.say.bind(two, 'Enchanté')
# twosay3()































