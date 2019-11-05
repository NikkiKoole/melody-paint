require 'palette'
inspect = require "inspect"

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.update(dt)
   local bpm = 30
   local multiplier = (60/(bpm*4))
   if playing then
      timeInBeat = timeInBeat + dt
      time = time + dt
      --print(timeInBeat/multiplier )
      if timeInBeat > multiplier then
	 timeInBeat = 0
	 playHead = playHead + 1
	 if playHead > horizontal-1 then
	    playHead = 0
	 end
      end
   end

end


function love.load()
   playing = true
   time = 0
   playHead = 0
   timeInBeat = 0

   screenWidth = 1024
   screenHeight = 768
   love.window.setMode(screenWidth, screenHeight)
   vertical = 12
   horizontal = 16

   leftmargin = 30
   rightmargin = 30

   cellHeight = 48
   cellWidth = (screenWidth - leftmargin - rightmargin) / horizontal

   bitmapSize = 100

   pictureInnerMargin = 4

   pictureTopMargin = pictureInnerMargin/2
   pictureInCellScale = (cellHeight-pictureInnerMargin)/bitmapSize
   pictureLeftMargin =  6

   topmargin = 48
   bottommargin = screenHeight - (cellHeight * vertical) - topmargin
   inbetweenmargin = 10
   pictureInBottomScale = 1

   head = love.graphics.newImage( 'resources/herman.png' )
   image1 = love.graphics.newImage( 'resources/picture4.png' )
   image2 = love.graphics.newImage( 'resources/picture3.png' )

   color = colors.indigo
   drawingValue = 1
   page = initPage()

   sounds = {image1, image2}

end

function initPage()
   local result = {}
   for x = 1, horizontal do
      local row = {}
      for y = 1, vertical do
	 table.insert(row, {x=x, y=y, value=0})
      end
      table.insert(result, row)
   end
   return result
end


function love.mousepressed(x,y)
   if (x > leftmargin and x < screenWidth - rightmargin) then
      if (y > topmargin and y < screenHeight - bottommargin) then
	 local cx =  1 + math.floor((x - leftmargin) / cellWidth)
	 local cy =  1 + math.floor((y - topmargin) / cellHeight)
	 page[cx][cy].value = (page[cx][cy].value > 0) and 0 or drawingValue
      end
   end
   if (y > screenHeight - bottommargin + inbetweenmargin) then
      if (x > leftmargin and x < screenWidth - rightmargin) then
	 local index = 1 + math.floor((x-leftmargin) / 100)
	 index = math.min(#sounds, index)
	 drawingValue = index
      end
   end

end



function love.draw()
   love.graphics.clear(palette[color])
   love.graphics.setColor(palette[color][1] - .1,
			  palette[color][2] - .1,
			  palette[color][3] - .1)
   love.graphics.rectangle('fill',
			   leftmargin, topmargin,
			   cellWidth*4,cellHeight * vertical)
   love.graphics.rectangle('fill',
			   leftmargin+ cellWidth*8,
			   topmargin, cellWidth*4,cellHeight * vertical)

   if (true) then
      love.graphics.setColor(palette[color][1] + .05,
			  palette[color][2] + .05,
			  palette[color][3] + .05)
      for y=0, vertical do
	 love.graphics.line(leftmargin,topmargin + y*cellHeight,
			    screenWidth - rightmargin, topmargin + y*cellHeight)
      end

      for x=0, horizontal do
	 love.graphics.line(leftmargin + x * cellWidth, topmargin ,
			    leftmargin + x * cellWidth, screenHeight-bottommargin)
      end
   end

   love.graphics.setColor(1,1,1)

   for x = 1, horizontal do
      for y = 1, vertical do
	 local index = page[x][y].value
	 if (index > 0) then
	    love.graphics.draw(sounds[index],
			       leftmargin+pictureLeftMargin+(cellWidth*(x-1)),
			       topmargin+pictureTopMargin+(cellHeight*(y-1)),
			       0,
			       pictureInCellScale,pictureInCellScale)
	 end

      end
   end

   for i = 1, #sounds do
      local img = sounds[i]

      if (i == drawingValue) then
	 love.graphics.setColor(palette[color][1] - .1,
				palette[color][2] - .1,
				palette[color][3] - .1)
	 love.graphics.rectangle('fill',
				 leftmargin + 100*(i-1), screenHeight - bottommargin + inbetweenmargin,
				 100,100 )
      end
      love.graphics.setColor(1,1,1)
      love.graphics.draw(img,
			 leftmargin + 100*(i-1), screenHeight - bottommargin + inbetweenmargin, 0,
			 pictureInBottomScale,pictureInBottomScale)
   end

   if playing then
      love.graphics.draw(head, leftmargin + (playHead * cellWidth) , 0, 0, .5, .5)
   end

end
