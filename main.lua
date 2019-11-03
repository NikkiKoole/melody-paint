require 'palette'
inspect = require "inspect"

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.load()
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

   pictureInBottomScale = 1
   
   image1 = love.graphics.newImage( 'resources/picture4.png' )
   image2 = love.graphics.newImage( 'resources/picture3.png' )

   color = colors.indigo

   page = initPage()
   drawingValue = 0
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

function handlePressInGrid(x,y, value)
    if (x > leftmargin and x < screenWidth - rightmargin) then
      if (y > topmargin and y < screenHeight - bottommargin) then
	 local cx =  1 + math.floor((x - leftmargin) / cellWidth)
	 local cy =  1 + math.floor((y - topmargin) / cellHeight)
	 page[cx][cy].value = value
      end
   end
end

function love.mousepressed(x,y)
   if (x > leftmargin and x < screenWidth - rightmargin) then
      if (y > topmargin and y < screenHeight - bottommargin) then
	 local cx =  1 + math.floor((x - leftmargin) / cellWidth)
	 local cy =  1 + math.floor((y - topmargin) / cellHeight)
	 if (page[cx][cy].value == 0) then
	     drawingValue = 1
	 else
	    drawingValue = 0
	 end
      end
   end
    
  handlePressInGrid(x,y, drawingValue)
end

function love.mousemoved(x,y)
   local down = love.mouse.isDown( 1)
   if (down) then handlePressInGrid(x,y, drawingValue) end
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
      love.graphics.setColor(0,0,0)
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
	 if (page[x][y].value > 0) then
	    
	     love.graphics.draw(image1,
				leftmargin+pictureLeftMargin+(cellWidth*(x-1)),
				topmargin+pictureTopMargin+(cellHeight*(y-1)),
				0,
				pictureInCellScale,pictureInCellScale)
	 end
	 
      end
    end
    
  
   love.graphics.draw(image1,
		      leftmargin, screenHeight - bottommargin, 0,
		      pictureInBottomScale,pictureInBottomScale)
   love.graphics.draw(image2,
		      leftmargin + 100, screenHeight - bottommargin, 0,
		      pictureInBottomScale,pictureInBottomScale)
end

