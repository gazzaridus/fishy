require "socket"
Timer = require("../common/timer")

--[[
BUGS
13 April 2018
Objects do not animate for some reason

]]
love.graphics.newAnimation = require("../common/animation")

IMGDIR="images/"
DOSOUND=true

local pause = false

local fishies = {}
local objects = {}
local start = false

local fishCnt = 0
local COLLISIONPIXELS=5
local BOATBOUNDARYY=115   -- pixels from top of screen to where boat should be placed

local imageMapFishes = {}
local fishHook = {}
local boat= {}
local background = {}

local hookBox = {} -- Box for collision detect on hook
local debug = NIL


--defaults
local x,y = 0,100
local delay = 0
local cnt= 0
local rows = 1
local cols = 6
local frames = 6
local delay = 0.2
local elapsed = 0.1
local batch = 1
local degreeDir = 90 -- degree direction


function createBox(o)
  -- Creates box for object, needs x, y
  -- returns a box which has x, y, h, w
  local box={}
  box.x = o.x
  box.y = o.y
  quad = o.animation:getQuad()
  print (o)
  print (type(o.animation))
  print ("quad type = "..type(quad))
  
  box.h = o.animation:getQuadHeight()
  box.w = o.animation:getQuadWidth()
  print ("Drawing box at x= "..box.x..", y = "..box.y.." w = "..box.w.." height = "..box.h)
  return box
end

function testEntry (b) 
  fName[b[1]] = true 
  fSpeed[b[2]] = true
  fX[b[3]] = true
  fY[b[4]] = true
  fZ[b[5]] = true
  --print ("",fSpeed[1]);
  print 'read'
end

function Entry (b) 
   fishCnt = fishCnt + 1


   local fishRead = {} 
  fishRead["name"] = b[1]
  fishRead["speed"] = b[2]
  fishRead["x"] = b[3]
  fishRead["y"] = b[4]
  fishRead["z"] = b[5]

  fishRead["delay"] = b[6]
  fishRead["rows"] = b[7]
  fishRead["cols"] = b[8]
  fishRead["frames"] = b[9]
  fishRead["delay"] = b[10]
  fishRead["elapsed"] = b[11]
  fishRead["batch"] = b[12]
  fishRead["direction"] = b[13]
  fishRead["caught"]=false
  fishRead["inboat"]=false
  --print ("",fSpeed[1]);
  table.insert(fishies, fishRead)
  print ('read fish '..fishCnt)

end

function Object (b) 
  print 'got object'
  local obj = {}
   obj["name"] = b[1]
  obj["speed"] = b[2]
  

  obj["x"] = b[3]

  obj["y"] = b[4]
  obj["z"] = b[5]

  obj["delay"] = b[6]
  obj["rows"] = b[7]
  obj["cols"] = b[8]
  obj["frames"] = b[9]
  obj["delay"] = b[10]
  obj["elapsed"] = b[11]
  obj["batch"] = b[12]
  obj["direction"] = b[13]
  obj["startdelay"] = b[14]
  obj["qty"]=b[15]
  obj["collectiondelay"]=b[16]
  obj["draw"]=false
  
  table.insert(objects, obj)
end


function setupBoat() 
   boat["x"]=love.graphics.getWidth()
  boat["y"]=background.boatBoundaryY
   boat["img"]=love.graphics.newImage(IMGDIR.."small_boat_grace.png")
end

function setupHook() 
  local offsetY=30
  local offsetX=-34
  fishHook["x"]=boat["x"]+offsetX
  fishHook["y"]=boat["y"]+offsetY
  fishHook["destX"]=0
  fishHook["destY"]=0
  fishHook["speed"]=100
  fishHook["travelling"]=false
  fishHook["recall"]=false
  fishHook["delay"]=0.5
  fishHook["timerInc"]=0
  fishHook["lineStartX"]=boat["x"]+15
  fishHook["lineStartY"]=boat["y"]+20
  fishHook["batch"]="hook_spritesheet.png"
  fishHook["img"]=love.graphics.newImage(IMGDIR..fishHook["batch"])
  --return love.graphics.newAnimation(love.graphics.newImage(IMGDIR..obj.batch),obj.rows,obj.cols,obj.frames,obj.delay,obj.elapsed)
  fishHook["rows"]=3
  fishHook["cols"]=4
  fishHook["frames"]=3
  fishHook["delay"]=0.2
  fishHook["elapsed"]=0.1

  fishHook["animation"] = getAnim(fishHook)
  print "Creating box fishhook"
  fishHook["box"]= createBox(fishHook)
end

function playMusic()
  if DOSOUND==true  then
    music = love.audio.newSource( 'music/fishmusic.mp3', 'static' )
    music:setLooping( true ) --so it doesnt stop
    music:play() 
  end
end

function love.load()

      debug = "Started"
      -- load background
      background.background1 = love.graphics.newImage("images/background1.png")
      background.boatBoundaryY=BOATBOUNDARYY
    
      --play music
      playMusic()

      -- load fishy maps
      data = dofile("fishy/data/fishes.lua")
      for fish in pairs(fishies) do
        print (fishies[fish]["name"])

      
            --fishies[fish].animation = love.graphics.newAnimation(love.graphics.newImage(IMGDIR..fishies[fish].batch),fishies[fish].rows,fishies[fish].cols,fishies[fish].frames,fishies[fish].delay,fishies[fish].elapsed)
            fishies[fish].animation = getAnim(fishies[fish])
            if (fishies[fish].x==-1) then
                fishies[fish].x = love.graphics.getWidth()
            end
            if (fishies[fish].y==-1) then
                fishies[fish].y = love.graphics.getHeight()
            end

            fishies[fish].box= createBox(fishies[fish])
        
      end
      for fish, v in pairs(fishies) do
          print 'found fishy'
      end

      -- Setup boat
      setupBoat()
      -- Setup hooks etc
      setupHook()

      -- load object maps
      data = dofile("fishy/data/objects.lua")
      -- add in those that are reference multiple objects
      objMulti = {}
      for obj in pairs(objects) do
          if objects[obj].qty ~= NIL then
            -- add to qty
          for i = 1,objects[obj].qty,1 
            do
               --print "adding multiple"
               local objDupe = shallowcopy(objects[obj])
               -- do some magic effect with it
               objDupe = setEffect(objDupe)
               
                table.insert(objMulti, objDupe)

            end
            --remove parent
           -- table.remove(objects,obj)

          end
      end

      -- assign multiple objects to main objects table
      for a in pairs(objMulti) do
        table.insert(objects,objMulti[a])
      end

      -- set timers and positions
      for obj in pairs(objects) do
          objects[obj].animation = getAnim(objects[obj])
          setPosition(objects[obj])
          setTimer(objects[obj])        
      end

end

function setEffect(o) 
  -- Do some magic feature with the object
   --o.speed = math.random(1,4) 
   o.direction = math.random(0,360) 

   return o
end
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function setTimer(obj)
   Timer.after(obj.startdelay, function()
      obj.draw = true
        
    end)
end

function setPosition(obj)
  if (obj.x==-1) then
      obj.x = love.graphics.getWidth()
  end
  if (obj.y==-1) then
      obj.y = love.graphics.getHeight()
  end
  return obj
end

function getAnim(obj) 
  print (obj.batch)
  print (obj.rows)
  return love.graphics.newAnimation(love.graphics.newImage(IMGDIR..obj.batch),obj.rows,obj.cols,obj.frames,obj.delay,obj.elapsed)
end

function love.update(dt)

 if pause==true then 
    return
  end
  -- STEP 1: Check for collision first before setting the TIMER
  for obj in pairs(objects) do
     local x = objects[obj].x
     local y = objects[obj].y

     --[[ if CheckCollision(objects[obj].box, fishHook.box) then
          print "I caught something"
          love.event.quit()
      end--]]
  end
  for fish in pairs(fishies) do


    if fishies[fish].inboat==false then
       local x = fishies[fish].x
       local y = fishies[fish].y

       print ("fishoook box "..fishHook.box.x)
       
       if fishHook.travelling ==true and CheckCollision(fishies[fish].box, fishHook.box)==true then
            print "I caught a fish"
            debug = "I caught a fish"
            fishies[fish].caught = true
            --real it in
            fishHook.recall=true
            fishHook.destX = fishHook.lineStartX
            fishHook.destY= fishHook.lineStartY


            --fishies[fish].direction=180
            --love.event.quit()
        end
    end
    
  end
  -- Check for collision end


-- STEP 2 : SET THE TIMER
  Timer.update(dt)


-- STEP 3 : UPDATE FISH POSITIONING
  --animation.update(dt)
  for fish in pairs(fishies) do
    
    if fishies[fish].inboat==false then
      if fishies[fish].caught==false then
          -- move from degrees to points
        local x = fishies[fish].x
        local y = fishies[fish].y
        
        local direction = fishies[fish].direction

        x = x + math.sin(direction*math.pi/180)*fishies[fish].speed;
        y = y + math.cos(direction*math.pi/180)*fishies[fish].speed;
        fishies[fish].x = x
        fishies[fish].y = y


        fishies[fish].animation.update(dt)
      else
        --make the position follow the hook
        fishies[fish].x = fishHook.x
        fishies[fish].y = fishHook.y
        fishies[fish].animation.update(dt)

        --if hook is back then make it disappear
        if fishHook.travelling==false then
          fishies[fish].inboat=true
        end

        
      end
    end

    

    
  end 


-- STEP 4 : UPDATE OBJECT POSITIONING

  -- objects
  for obj in pairs(objects) do
     local x = objects[obj].x
     local y = objects[obj].y
     local direction = objects[obj].direction
     local speed = objects[obj].speed
      x = x + math.sin(direction*math.pi/180)*speed;
      y = y + math.cos(direction*math.pi/180)*speed;
      objects[obj].x = x
      objects[obj].y = y
  end
  
  -- STEP XXX: UPDATE FISH HOOK PUT AT END
  -- hook
 --[[ if fishHook["timerInc"] > fishHook["delay"] then
      fishHook["timerInc"]=0--]]
      if fishHook["travelling"]==true then
        -- print ("do hook "..dt)
        doHook(dt)
        
      end
   --[[ else
    
       fishHook["timerInc"]= fishHook["timerInc"] + dt
    end--]]
    fishHook.animation.update(dt)
    

    -- DEBUG STUFF


end

function doHook(dt)
    --animate hook etc
    local x =  fishHook["x"]
    local y =  fishHook["y"]
    local destX =  fishHook["destX"]
    local destY =  fishHook["destY"]
    local speed = fishHook["speed"]
    print ("Fish speed "..speed)
    local lineStartX = fishHook["lineStartX"]
    local lineStartY = fishHook["lineStartY"]
    local recall = fishHook["recall"]
    local travelling = fishHook["travelling"]

    if  x ~=  destX then                                                                        --- The math for the movement
         x =  x + (dt* speed)*(( destX-x)/math.abs(destX-x))
      end

      if y ~= destY then
        y = y + (dt*speed)*((destY-y)/math.abs(destY-y))
      end

      if math.abs(x-destX) <=5 and math.abs(y-destY) <=5 and recall==false then
        --print "no longer travelling"
         
        recall = true
        
        destX = lineStartX
        destY= lineStartY
        
      else
        --recall is on
        if math.abs(x-destX) <=5 and math.abs(y-destY) <=5 then
          --we've rewound
          recall = false
          travelling = false
        end
      end

      -- persist back to fishHook
      fishHook["x"]=x
      fishHook["y"]=y
      fishHook["destX"]=destX
      fishHook["destY"]=destY
      fishHook["recall"]=recall
      fishHook["travelling"]=travelling
      
         
end

function love.draw() 
   success = love.window.setFullscreen( true )
  local sx = love.graphics.getWidth() /  background.background1:getWidth()
  local sy = love.graphics.getHeight() /  background.background1:getHeight()
  love.graphics.draw( background.background1, 0, 0, 0, sx, sy) -- x: 0, y: 0, rot: 0, scale x and scale y


 if pause==true then 
    love.graphics.print("GAME PAUSED", 10, 250, 0, 2, 2)
  
  end


  for fish in pairs(fishies) do

    if fishies[fish].inboat==false then
        local fx = fishies[fish].x
        local fy = fishies[fish].y
        
        --print ('drawing fish '..fishies[fish].name..' at '..fx..', '..fy..', speed = '..fishies[fish].speed)
        
        --print ('drawing fish '..fishies[fish].name ..'at '..fx)
        --print ('drawing fish '..fishies[fish].name ..'at '..fy)
        fishies[fish].animation.draw(fx,fy)
        

        --draw rectangle, but first of all re-establish the box details of x and y
        fishies[fish].box.x = fx
        fishies[fish].box.y = fy
        
        --love.graphics.rectangle("line",fishies[fish].box.x, fishies[fish].box.y, fishies[fish].box.w, fishies[fish].box.h)
    end

  

  end

  --Draw boat
  love.graphics.draw(boat["img"], boat["x"], boat["y"]) 



  -- Draw all objects
  for obj in pairs(objects) do
    local fx = objects[obj].x
    local fy = objects[obj].y
    --objects[obj].animation.draw(fx,fy)

    -- DRAW AN OBJECT BUT RESPECT THE Y BOUNDARY
    if (objects[obj].draw==true and objects[obj].y > background.boatBoundaryY+80) then
      objects[obj].animation.draw(fx,fy)
    end
      
  end

  
--Draw fish hook
  fishHook.animation.draw(fishHook["x"], fishHook["y"])
  -- draw fishhookbox
  local fx = fishHook.x
  local fy = fishHook.y

  fishHook.box.x = fx
  fishHook.box.y = fy
  debug = fishHook.animation.getFrame()


  --love.graphics.rectangle("line",fx, fy, fishHook.box.w, fishHook.box.h)

  --love.graphics.draw(fishHook["img"], fishHook["x"], fishHook["y"])                                                          --- The variable defined for the .png start location 
  
-- need to take the anim hook location into consideration
  --print ("playing fishhook frame .."..fishHook.animation.getFrame().." from frames "..fishHook.animation.getFrames())
  
  love.graphics.line( fishHook["lineStartX"],fishHook["lineStartY"],fishHook["x"],fishHook["y"])

-- debug stuff

love.graphics.print(debug, 400,400)
 
end


function CheckCollision(box1, box2)
  local x1 = box1.x
  local y1 = box1.y
  local w1 = box1.w
  local h1 = box1.h

  local x2 = box2.x
  local y2 = box2.y
  local w2 = box2.w
  local h2 = box2.h

  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end


function love.keypressed(k)
  -- remove full screen back to menu but for moment
   if k == 'escape' then
      love.event.quit()
      --@TODO GO BACK TO MAIN MENU
   end
    if k == 'p' then 
      
        pause = not pause 
    end
     if k == ' ' then 
        pause = not pause 
    end
end


function love.mousepressed(x,y,button)                                                --- This is the code to for the mouse buttons 

  if button == 1 and fishHook["travelling"] ==false then  
    print "setting dest"  
    print ("dest x,y = "..x..','..y)                                                                  --- This is for the left mouse button 
      fishHook["destX"], fishHook["destY"] = x,y
      fishHook["travelling"]=true
     
   end
   
   
end


function love.mousereleased( x, y, button, istouch )
  -- when released we can capture up the fish
 --[[ if button == 1 then  

      fishHook["recall"] = true 
      fishHook["destX"] = fishHook["lineStartX"]
      fishHook["destY"] = fishHook["lineStartY"]

   
  end--]]
end


  


--[[

local x = 0
local y = 0
local delay = 0
local cnt= 0
local rows = 1
local cols = 6
local frames = 6
local delay = 0.2
local elapsed = 0.1



image = love.graphics.newImage("images/fish1lefttoright.png")
--(sheet, rows, cols, frames, delay, elapsed)


animation = love.graphics.newAnimation(image,rows,cols,frames,delay,elapsed)


local fish = {}

local MAXFISH = 6
local DOSOUND = true
local DEBUG = true

local start = love.timer.getTime()
local stop = love.timer.getTime()


local cast1 = {
  startX = 10,
  startY = 10,
  x = 10,
  y = 10,
  delay = 500,
  endX = 0,
  endY = 0,
  lastMs = 0,

}

local f1s = {
   x  = 0,
   y  = 0,
   vx = 100,
   vy = 10,
   speed = 1

}

local f2s = {
   x  = 0,
   y  = 30,
   vx = 100,
   vy = 10,
    speed = 1
}

local f3s = {
   x  = 0,
   y  = 80,
   vx = 100,
   vy = 10,
   start = 0,
   move = 'right',
    speed = 1
}

local f4s = {
   x  = 0,
   y  = 180,
   vx = 100,
   vy = 10,
    speed = 1
}

local f5s = {
   x  = 0,
   y  = 280,
   vx = 100,
   vy = 10,
    speed = 1
}

local f6s = {
   x  = 0,
   y  = 580,
   vx = 100,
   vy = 10,
    start = 0,
   move = 'right',
    speed = 1
}

local f7s = {
   x  = 0,
   y  = 480,
   vx = 100,
   vy = 10,
    speed = 1
}

local f8s = {
   x  = 0,
   y  = 580,
   vx = 100,
   vy = 10,
    speed = 1
}

local f9s = {
   x  = 0,
   y  = 680,
   vx = 100,
   vy = 10,
    speed = 1
}

local f10s = {
   x  = 0,
   y  = 780,
   vx = 100,
   vy = 10,
    speed = 1
}

local fishSprites = {

}

function love.load()
  print 'hello'
  fishSprites[#fishSprites+1] = f1s
  fishSprites[#fishSprites+1] = f2s
  fishSprites[#fishSprites+1] = f3s
  fishSprites[#fishSprites+1] = f4s
  fishSprites[#fishSprites+1] = f5s
  fishSprites[#fishSprites+1] = f6s
  fishSprites[#fishSprites+1] = f7s
  fishSprites[#fishSprites+1] = f8s
  fishSprites[#fishSprites+1] = f9s
  fishSprites[#fishSprites+1] = f10s
--love.event.quit()

    fish_atlas = love.graphics.newImage("images/fishatlas1.png")
 
    background1 = love.graphics.newImage("images/background1.png")

     for index=1,MAXFISH do
        --fish[index] = love.graphics.newImage("images/fish" .. index .. ".png")
        fish[index] = love.graphics.newImage("images/fish"..index..".png")
        if fishSprites[index].start then
            fishSprites[index].x = fishSprites[index].start
        else
            fishSprites[index].x = love.graphics.getWidth()
        end

        
     
      
      
     end

  if DOSOUND==true  then
    music = love.audio.newSource( 'music/fishmusic.mp3', 'static' )
    music:setLooping( true ) --so it doesnt stop
    music:play() 
  end

  

end

function love.update(dt)
   -- Take the current position, and add the velocities onto them.
   --sphere.x = sphere.x + (sphere.vx * dt) -- We multiply by 'dt' so they move equally fast regardless of framerate.
   --sphere.y = sphere.y + (sphere.vy * dt)

    for index=1,MAXFISH do

      if fishSprites[index].move=='right' then
        --local inc = love.math.random(0, 3)
          local inc =  fishSprites[index].speed
          fishSprites[index].x =  fishSprites[index].x+ inc
      else
        local inc =  fishSprites[index].speed
        fishSprites[index].x =  fishSprites[index].x- inc

      end
   

    end

    -- for line cast

    local now = love.timer.getTime()
    if (now - cast1.lastMs) >= cast1.delay then
        print 'casting...'

        cast1.lastMs = now
        cast1.x = cast1.x + 1
        cast1.y = cast1.y + 1
        print (string.format('now %f',now))
  
  

    end
    x = x +1
    animation.update(dt) 

    
end

function love.draw() 
  success = love.window.setFullscreen( true )
  local sx = love.graphics.getWidth() / background1:getWidth()
  local sy = love.graphics.getHeight() / background1:getHeight()
  love.graphics.draw(background1, 0, 0, 0, sx, sy) -- x: 0, y: 0, rot: 0, scale x and scale y


  for index=1,MAXFISH do
    love.graphics.draw(fish[index], fishSprites[index].x, fishSprites[index].y) -- Draw our sphere

  end

  love.graphics.line( cast1.startX, cast1.startY, cast1.x, cast1.y)
   animation.draw(x,y)
end

function love.keypressed(k)
   if k == 'escape' then
      love.event.quit()
   end
end

function love.mousepressed(x, y, button)
  if button == 1 then
   local x = love.mouse.getX()
    start = love.timer.getTime()
  end
end

function love.mousereleased(x, y, button, istouch)
  if button == 1 then
      stop = love.timer.getTime()
  end
end
--]]
