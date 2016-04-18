local class = require 'vendor.middleclass'

local Heap = class('Heap')

-- Initializes the heap.
-- Type can be one of 'min' or 'max'. Defaults to 'min'.
-- Returns an instance of Heap.
function Heap:initialize(type)
  self._nodes = {}
  type = type or 'min'
  self:setType(type)
end

-- Sets the type of heap and resets the order.
-- Can be one of min or max.
-- Returns nothing [nil]
function Heap:setType(type)
  assert(type == 'min' or type == 'max', "type must be one of 'min' or 'max'")

  self._type = type
  self:reset()
end

-- Clears the heap
-- Returns nothing [nil]
function Heap:clear()
  self._nodes = {}
end

-- Pops the first node off the heap.
-- Returns the node unpacked: weight first then payload.
function Heap:pop()
  local node = self._nodes[1]

  if node then
    table.remove(self._nodes, 1)

    if not self:isEmpty() then
      self:_percolateDown(1)
    end

    return node.weight, node.payload
  else
    return nil, nil
  end
end

-- Fetch a node at the given index.
-- Returns the node unpacked: weight first then payload.
function Heap:fetch(index)
  if self._nodes[index] then
    return self._nodes[index].weight, self._nodes[index].payload
  else
    return nil, nil
  end
end

-- Fetch the first node on the heap.
-- Returns the node unpacked: weight first then payload.
function Heap:first()
  return self:fetch(1)
end

-- Inserts a node in the heap as a table { weight = weight, payload = payload }
-- Returns nothing [nil]
function Heap:insert(weight, payload)
  self._nodes[#self._nodes + 1] = { weight = weight, payload = payload }
  self:_percolateUp(#self._nodes)
end

-- Resets the order of the heap.
-- Returns nothing [nil]
function Heap:reset()
  self:_percolateDown(1)
end

-- Gets the size of the heap (the number of nodes stored).
-- Returns the heap size [number]
function Heap:getSize()
  return #self._nodes
end

-- Checks if the heap is empty.
-- Return true or false [boolean]
function Heap:isEmpty()
  return #self._nodes == 0
end

-- Checks if each node in the heap is ordered correctly.
-- Returns true on success, false on error. [boolean]
function Heap:isValid()
  if self:isEmpty() then return true end

  for index, node in ipairs(self._nodes) do
    local left_child_index = self:_leftChildIndex(index)
    local right_child_index = self:_rightChildIndex(index)

    if self._nodes[left_child_index] then
      if not self.sort(self._nodes[index].weight, self._nodes[left_child_index].weight) then
        return false
      end
    end

    if self._nodes[right_child_index] then
      if not self.sort(self._nodes[index].weight, self._nodes[right_child_index].weight) then
        return false
      end
    end
  end

  return true
end

-- private methods

-- Default sorting function.
-- Used for Min-Heaps creation.
function Heap:_sort(a, b)
  assert(self._type == 'min' or self._type == 'max', "type must be one of 'min' or 'max'")

  if self._type == 'min' then
    return a < b
  elseif self._type == 'max' then
    return a > b
  end
end

-- Find the index of the given payload.
-- Returns the index [number]
function Heap:_indexOf(payload)
	for i, node in ipairs(self._nodes) do
		if node.payload == payload then return i end
	end
end

-- Calculate the the parent index of the given index.
-- Returned index may not be a valid index in the heap.
-- Returns the parent index [number]
function Heap:_parentIndex(index)
  return math.floor(index / 2)
end

-- Calculate the left child index of the given index.
-- Returned index may not be a valid index in the heap.
-- Returns the left child index [number]
function Heap:_leftChildIndex(index)
  return 2 * index
end

-- Calculate the right child index of the given index.
-- Returned index may not be a valid index in the heap.
-- Returns the right child index [number]
function Heap:_rightChildIndex(index)
  return 2 * index + 1
end

-- Percolates up the heap recursively, ordering each node by the chosen sort method.
-- Returns nothing [nil]
function Heap:_percolateUp(index)
  local parent_index = self:_parentIndex(index)

  if self._nodes[parent_index] and not self:_sort(self._nodes[parent_index].weight, self._nodes[index].weight) then
    self._nodes[parent_index], self._nodes[index] = self._nodes[index], self._nodes[parent_index]
    self:_percolateUp(parent_index) -- Recursive call from the parent index
  end
end

-- Percolates down the heap recursively, ordering each node by the chosen sort method.
-- Returns nothing [nil]
function Heap:_percolateDown(index)
  local left_child_index = self:_leftChildIndex(index)
  local right_child_index = self:_rightChildIndex(index)
  local min_index

  if not self._nodes[left_child_index] and not self._nodes[right_child_index] then
    return
  end

  if not self._nodes[right_child_index] then
    min_index = left_child_index
  else
    if self:_sort(self._nodes[left_child_index].weight, self._nodes[right_child_index].weight) then
      min_index = left_child_index
    else
      min_index = right_child_index
    end
  end

  if self:_sort(self._nodes[min_index].weight, self._nodes[index].weight) then
    self._nodes[index], self._nodes[min_index] = self._nodes[min_index], self._nodes[index]
    self:_percolateDown(min_index) -- Recursive call from the newly shifted index
  end
end

-- metamethods

-- Merging heaps with the '+' operator.
-- Returns a new heap based on h1 + h2 [Heap]
function Heap.__add(h1, h2)
  local h = Heap:new()

  while not h1:isEmpty() do
    h:insert(h1:pop())
  end
  while not h2:isEmpty() do
    h:insert(h2:pop())
  end

  return h
end

return Heap
