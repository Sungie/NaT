p1  = {}
p2  = {}

p1.cells = {0}
p2.cells = {15}
p1.name = "Joueur1"
p2.name = "Joueur2"
currPlayer = p1

function love.load()
  love.window.setFullscreen(true)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()


  dotSize = 5
  nodes = {}
  for i = 0, 15,1 do
    node = {}
    node.num = i
    node.x = i%4*100 + dotSize*2
    node.y = math.floor(i/4)*100+ dotSize*2
    node.pos = {x=i%4 , y=math.floor(i/4) }
    node.free = true
    nodes[i] = node
  end

  dotHandled = nil

end

function getColor(node)
  for i, val in pairs(p1.cells) do
    if val == node.num then
      return {0,0,1,1}
    end
  end
  for i, val in pairs(p2.cells) do
    if val == node.num then
      return {0,1,0,1}
    end
  end

  return {1, 1, 1, 1}
end

function getPlayerColor(player)
  if player == p1 then return {0,0,1,1} end
  if player == p2 then return {0,1,0,1} end
  return {1,1,1,1}
end

function love.draw()
  love.graphics.setColor(getPlayerColor(currPlayer))
  love.graphics.print( currPlayer.name, width/3, 0, 0, 4, 4)

  --Add points
  for i, node in pairs(nodes) do
    if dotHandled == node then
      love.graphics.setColor(1, 0, 0, 1)
    else
      love.graphics.setColor(getColor(node))
    end
    love.graphics.print( (node.pos.x)..","..math.floor(node.pos.y), node.x ,node.y, 0, 1, 1)
    --love.graphics.circle("fill", node.x ,node.y, dotSize)
  end

  --draw players1's lines
  local prv = nil
  for i, val in pairs(p1.cells) do
    if prv then
      drawLineFromAtoB(prv, val)
      prv = val
    else
      prv = val
    end
  end
  --draw players2's lines
  local prv = nil
  for i, val in pairs(p2.cells) do
    if prv then
      drawLineFromAtoB(prv, val)
      prv = val
    else
      prv = val
    end
  end
end

time = 0
function love.update(dt)
  time = time+dt

  -- print list of each player's node
  -- if time > 2 then
  --   print("----------------")
  --   print("p1")
  --   for i,val in pairs(p1) do
  --     print(val)
  --   end
  --   print("p2")
  --   for i,val in pairs(p2) do
  --     print(val)
  --   end
  --   print("----------------")
  --

  --Reset timer
  time = 0

end

function drawLineFromAtoB(a,b)
  love.graphics.setColor(1, 1, 1, 1)
  if nodes[a] then
    if nodes[b] then
      love.graphics.line(nodes[a].x, nodes[a].y, nodes[b].x, nodes[b].y)
    else
      print("Cell "..b.cells.." doesnt exists!")
    end
  else
    print("Cell "..a.cells.." doesnt exists!")
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function addUniqueAndValidNode(nodeTargeted)
  local add = true
  for i, elem in pairs(p1.cells) do
    if elem == nodeTargeted.num then
      add = false
    end
  end
  for i, elem in pairs(p2.cells) do
    if elem == nodeTargeted.num then
      add = false
    end
  end
  ------------------------------------------------------------------------------
  ---------------------------A modifier-----------------------------------------
  ------------------------------------------------------------------------------
  --Principe: le clic est valide QUE si cela trace sur une ligne, une colonne ou
  -- une diagonale
  print("----------------------")
  --print("Handled : "..getLastNodeOfCurrPlayer().num.."=> x: "..getLastNodeOfCurrPlayer().x.." ,y: "..getLastNodeOfCurrPlayer().y)
  --print("Clicked : "..a.num.."=> x: "..a.x.." ,y: "..a.y)
  local currNode = getLastNodeOfCurrPlayer()
  if currNode ~= nodeTargeted and (
    --Check ligne ou diagonale
     currNode.pos.x == nodeTargeted.pos.x
      or currNode.pos.y == nodeTargeted.pos.y
      or math.abs(currNode.pos.x - nodeTargeted.pos.x) == math.abs(currNode.pos.y - nodeTargeted.pos.y)) then

      print("Handled : "..currNode.num.."=> x: "..currNode.pos.x.." ,y: "..currNode.pos.y)
      print("Clicked : "..nodeTargeted.num.."=> x: "..(nodeTargeted.pos.x).." ,y: "..(nodeTargeted.pos.y))


    --  check si diag bas droit et haut droit MAIS fail si deux extremités...
    ------------------------------------------------------------------------------
    ------------------------------------------------------------------------------
    ----------
      if add then
        table.insert(currPlayer.cells,nodeTargeted.num)
        if currPlayer == p1 then currPlayer = p2 else currPlayer = p1 end
      end
    else
      print("Not a valid click")
    end

end

function getLastNodeOfCurrPlayer()
  return nodes[currPlayer.cells[table.getn(currPlayer.cells)]]
end

function elemUnderCursor(x, y)
  for i, node in pairs(nodes) do
    if node.num == currPlayer.cells[table.getn(currPlayer.cells)] then
      local dist = math.sqrt((math.pow((x- node.x), 2))
                  +(math.pow((y-node.y), 2)))
      if math.floor(dist) < 30 then
        return node
      end
    end
  end
end

function love.mousepressed(x, y, button, isTouch)
    if dotHandled then
      for i, node in pairs(nodes) do
        local dist = math.sqrt((math.pow((x- node.x), 2)) + (math.pow((y-node.y), 2)))
        if math.floor(dist) < 30 then
          dotHandled = node
        end
      end
      addUniqueAndValidNode(dotHandled)
      dotHandled = nil
    else
      dotHandled = elemUnderCursor(x, y)
    end
end
