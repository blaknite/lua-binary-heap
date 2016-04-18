# lua-binary-heap
Binary heap data structure implemented in lua.

Built as a class with kikito's middleclass: https://github.com/kikito/middleclass

## Usage

```lua
heap = Heap:new() -- creates a min heap
=> Heap

heap:insert(3, 'first payload')
=> nil
heap:insert(1, 'second payload')
=> nil

weight, payload = heap:pop()
=> 1, 'second payload'
```

For all methods and their usage see comments within `heap.lua`.
