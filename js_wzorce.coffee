# javascript wzorce
# author source: https://github.com/stoyan

log = console.log.bind(console)
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
schonfinkelize = (fn) ->
  slice = Array.prototype.slice
  stored_args = slice.call(arguments, 1) # store all args but first since it's a partial application function
  () ->
    new_args = slice.call(arguments)
    args = stored_args.concat(new_args)
    fn.apply(null, args)

added = (x, y) ->
  x + y

log added(4,3)

newAdd = schonfinkelize(add,5)
log newAdd(1)


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

# module2 = MYAPP.namespace('MYAPP.modules.module2')
# log module2 is MYAPP.modules.module2


# ******************************   METODY I WŁAŚCIWOŚCI PRYWATNE   *********************************************

# Wystarczy otoczyć dane, które mają pozostać prywatne, funkcją, by mieć pewność,
# że są dla tej funkcji zmiennymi lokalnymi i nie wyciekają na zewnątrz.

class Gadget
  name = 'iPod' # zmienna prywatna
  getName: -> "getName returns #{name}" # funkcja publiczna

toy = new Gadget
  # name jest niezdefiniowane, bo jest zmienną prywatną
log toy.name # undefined
  # metoda publiczna ma dostęp do name
log toy.getName() # "iPod"
  # getName() jest metodą uprzywilejowaną, ponieważ ma szczególną własność — ma dostęp do zmiennej prywatnej name.

class Foo
  # this will be our private method. it is invisible outside of the current scope
  foo = -> log "foo"
  # this will be our public method. Note that it is defined with ':' and not '='
  # '=' creates a *local* variable # : adds a property to the class prototype
  bar: -> foo()

faz = new Foo
log faz.bar()

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
s.price = 500
s.color = 'red'
log sp.getSpecs()
log sp.specs

# nieprzekazywanie prywatnych obiektów oraz tablic w sposób bezpośredni, zmodyfikowanie metody getSpecs()
# w taki sposób, by zwracała nowy obiekt tylko z tymi danymi, które są niezbędne dla wywołującego

# Literały obiektów a prywatność: literał obiektu należy otoczyć funkcją anonimową wywoływaną natychmiast po zadeklarowaniu

myLitObj = do () ->
  name = 'ojej'
  { getName: -> log name }

myLitObj.getName()

# połączenie 2 wzorców: zmiennych prywatnych w konstruktorze i właściwości prywatnych w literałach obiektów
Gadget::twoPatterns = do () ->
# twoPatterns = ( ->
  browser = 'Mobile kit'
  { getBrowser: -> log browser }

# Gadget::twoPatterns

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
do () ->
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

MYAPP.utilities.array = do () ->
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


# ******************************   WZORZEC PIASKOWNICY   **********************************************

# Obiekt box stanowi odpowiednik obiektu MYAPP ze wzorca przestrzeni nazw — będzie zawierał
# całą funkcjonalność biblioteczną niezbędną do zapewnienia prawidłowego działania aplikacji.

# utworzenie obiektu, który wykorzystuje dwa fikcyjne moduły: ajax i event.

`
//  new Sandbox(function (box) {
//  // tu znajduje się kod aplikacji
//  });

//  Sandbox(['dom', 'event'], function (box) {
//    // wykorzystanie modułów dom i event
//    Sandbox('ajax', function (box) {
//      // kolejna piaskownica z nowym obiektem box
//      // ten box nie jest taki sam
//      // jak box poza tą funkcją
//      // ...
//      // koniec operacji dotyczących modułu ajax
//    });
//    // nie ma śladu po module ajax
//  });


function Sandbox() {
  // zamiana argumentów na tablicę
  var args = Array.prototype.slice.call(arguments),
  // ostatni argument to funkcja wywołania zwrotnego
  callback = args.pop(),
  // moduły mogą zostać przekazane jako tablica lub osobne parametry
  modules = (args[0] && typeof args[0] === "string") ? args : args[0],
  i;
  // sprawdzenie, czy funkcja została
  // wywołana jako konstruktor
  if (!(this instanceof Sandbox)) {
    return new Sandbox(modules, callback);
  }
  // dodanie w razie potrzeby właściwości do this
  this.a = 1;
  this.b = 2;
  // dodaj moduły do głównego obiektu this
  // brak modułów lub * oznacza zastosowanie wszystkich modułów
  if (!modules || modules === '*') {
    modules = [];
    for (i in Sandbox.modules) {
      if (Sandbox.modules.hasOwnProperty(i)) {
        modules.push(i);
      }
    }
  }
  // inicjalizacja wymaganych modułów
  for (i = 0; i < modules.length; i += 1) {
    Sandbox.modules[modules[i]](this);
  }
  // wywołanie funkcji zwrotnej
  callback(this);
}

// dodanie w razie potrzeby ogólnych właściwości do prototypu
Sandbox.prototype = {
  name: "Moja aplikacja",
  version: "1.0",
  getName: function () {
    return this.name;
  }
};
`

# ******************************   Prywatne składowe statyczne   **********************************************


# funkcja otaczająca wykona się od razu i zwróci inną funkcję. Ta zwrócona funkcja zostanie przypisana do
# zmiennej Gadget, stając się konstruktorem.

Gadget_3 = do () ->
  counter = 0
  NewGadget = () -> log counter += 1
  NewGadget::getLastId = () -> counter
  NewGadget

g1 = new Gadget_3
g2 = new Gadget_3
iphone = new Gadget_3
iphone.getLastId()
ipod = new Gadget_3
ipod.getLastId()

# statyczna właściwość jest niejako unikatowym identyfikatorem każdego obiektu tworzonego za pomocą konstruktora Gadget_3


# ******************************   Wzorzec łańcucha wywołań   **********************************************


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

# ***************************** Metoda method()

method = () ->
  if (typeof Person::method isnt "function")
    Person::method = (name, implementation) ->
      @prototype[name] = implementation
      return @

class Person
  constructor: (@name) ->

method 'getName', () ->
  @.name
method 'setName', (name) ->
  @name = name
  @

a = new Person('adam')
for i of a
  log i, ":", a[i]





