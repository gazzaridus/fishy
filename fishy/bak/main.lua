require "socket"
love.graphics.newAnimation = require("../common/animation")
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

