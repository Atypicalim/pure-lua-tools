### Pure Lua Tools

0. About

> there are some useful tools like class, events for lua ...

```lua
require('scripts/tools/initialize')
-- do something with tools
```

1. class

```lua
local Animal = class("Animal")
function Animal:__init__()
    print('animal init ...')
end
function Animal:eat(something)
    print(string.format('eating a poor %s ...', something))
end

local Dog, Parent = class("Dog", Animal)
function Dog:__init__()
    Parent:__init__(self)
    print('dog init ...')
end
function Dog:eat(something)
    Parent.eat(self, something)
end

local dog = Dog()
print(dog)
dog:eat('cat')

-- animal init ...
-- dog init ...
-- <object Dog>: 01085670
-- eating a poor cat ...
```

2. events

```lua
events = Events()
events:addListener('testEvent', function(argument)
    print('callback1 receive: ' .. argument)
end, 1) -- once
events:addListener('testEvent', function(argument)
    print('callback2 receive: ' .. argument)
end, 3) -- limeted
events:addListener('testEvent', function(argument)
    print('callback3 receive: ' .. argument)
end, 0) -- forever
events:triggerEvent('testEvent', 1)
events:triggerEvent('testEvent', 2)
events:triggerEvent('testEvent', 3)
events:triggerEvent('testEvent', 4)
events:triggerEvent('testEvent', 5

-- callback1 receive: 1
-- callback2 receive: 1
-- callback3 receive: 1
-- callback2 receive: 2
-- callback3 receive: 2
-- callback2 receive: 3
-- callback3 receive: 3
-- callback3 receive: 4
-- callback3 receive: 5
```

3. files

```lua
files.write('test.txt', 'content...')
local content = files.read('test.txt')
local fileNames = files.list('some/folder/name/')
```

4. json

```lua
local test = {
    [1] = 'numberKey',
    boolenValue = true,
    nullValue = json.null,
    objectValue = {
        stringValue = "json is ready!",
    },
    arrayValue = {"enjoy", "it", "!"},
}
local s = json.encode(test)
print(s)
local t = json.decode(s)
print(t)
-- {"1":"numberKey","objectValue":{"stringValue":"json is ready!"},"nullValue":null,"arrayValue":["enjoy","it","!"],"boolenValue":true}
-- table: 010A3D40
```

5. table

```lua
-- test table value with some feature
local value = table.new({
    key = "value",
})
-- table to string, string to table
local s = value:encode() -- lua script string of the table value
local t = s:decode() -- table value of the script string
-- write to file, read from file
value:write_to_file('test.txt')
local t = table.read_from_file('test.txt')
-- keys, values
local keys = value:keys()
local values = value:values()
-- merge
local t = value:merge({newKey= "newValue"})
```

6. timer

```lua
timer.async(function()
    timer.sleep(1)
    print('one')
    timer.sleep(1)
    print('two')
    timer.sleep(1)
    print('three')
end)
timer.delay(2, function()
    print('delay')
end)
timer.start()
-- one
-- delay
-- two
-- three
```

7. string

```lua
-- test string value with some feature
local s = string.new('abcd')
-- fill
local r = s:center(6, ' ') -- ' abcd '
local r = s:left(6, ' ') -- 'abcd  '
local r = s:right(6, ' ') -- '  abcd'
-- trim
local s = s:trim() -- 'abcd'
-- execute
s:execute()
```

---

> for more feture plz read the source code ...
