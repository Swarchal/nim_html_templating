import std/[strutils, json]

import jester
import mustache


# by default looks for mustache templates in cwd, or we can specify
# in newContext(searchDirs=@[...])
const TEMPLATE_DIRS = @["../templates"]


type Person = object
  id: Natural
  first_name: string
  second_name: string
  age: Natural


# custom objects should have a castValue proc for them
proc castValue(value: Person): Value =
  let newValue = new(Table[string, Value])
  result = Value(kind: vkTable, vTable: newValue)
  newValue["id"] = value.id.castValue
  newValue["first_name"] = value.first_name.castValue
  newValue["second_name"] = value.second_name.castValue
  newValue["age"] = value.age.castValue


let people = @[
  Person(id:1, first_name:"Alice", second_name:"Archer", age:40),
  Person(id:2, first_name:"Bob", second_name:"Burgandy", age:33),
  Person(id:3, first_name:"Charlie", second_name:"Cooper", age:99),
]


routes:

  get "/hello/@name":
    let context = newContext(searchDirs=TEMPLATE_DIRS)
    context["name"] = @"name"
    resp "{{ >hello }}".render(context)


  get "/person":
    let context = newContext(searchDirs=TEMPLATE_DIRS)
    context["my_people"] = %people  # can use JSON rather than castValue
    resp "{{ >people }}".render(context)


  get "/person/@id":
    let
      id = @"id".parseInt
      person = people[id-1]
      context = newContext(searchDirs=TEMPLATE_DIRS)
    context["my_person"] = person
    resp "{{ >person }}".render(context)
