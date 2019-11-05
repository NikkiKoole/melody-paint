require 'palette'
inspect = require "inspect"

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end


function love.load()
   thread = love.thread.newThread( 'audio.lua' )
   thread:start()
   channel		= {};
   channel.audio2main	= love.thread.getChannel ( "audio2main" )
   channel.main2audio	= love.thread.getChannel ( "main2audio" )

   playing = true
   playhead = 0

   screenWidth = 1024
   screenHeight = 768
   --love.window.setMode(screenWidth, screenHeight)
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
   pictureInBottomScale = .7

   head = love.graphics.newImage( 'resources/herman.png' )

   image1 = love.graphics.newImage( 'resources/clam.png' )
   image2 = love.graphics.newImage( 'resources/owl.png' )
   image3 = love.graphics.newImage( 'resources/panda-bear.png' )
   image4 = love.graphics.newImage( 'resources/antelope.png' )
   image5 = love.graphics.newImage( 'resources/flamingo.png' )
   image6 = love.graphics.newImage( 'resources/fox.png' )
   image7 = love.graphics.newImage( 'resources/bee.png' )
   image8 = love.graphics.newImage( 'resources/crab.png' )
   image9 = love.graphics.newImage( 'resources/elephant.png' )
   image10 = love.graphics.newImage( 'resources/crocodile.png' )
   image11 = love.graphics.newImage( 'resources/kangaroo.png' )
   image12 = love.graphics.newImage( 'resources/pig.png' )
   image13 = love.graphics.newImage( 'resources/starfish.png' )

   color = colors.indigo
   drawingValue = 1
   page = initPage()

   sounds = {image1, image2, image3, image4, image5, image6, image7, image8, image9, image10, image11, image12, image13}

   local samples_names = {'marimba', "bd", "cb", "hihat-metal", "analog3c", "brass5c",
		 "epiano2-1c", "prophet1c", "guiro", "727-lo-bongo", "727-ho-conga", "727-whistl", "musicnote14"}
   samples = {}
   for i=1, #samples_names do
      local data = love.sound.newSoundData( 'instruments/'..samples_names[i]..'.wav' )
      table.insert(samples, love.audio.newSource(data, 'static'))
   end
   channel.main2audio:push({type="samples", data=samples});

end

function love.update(dt)
   local v = channel.audio2main:pop();
   if v then
      if (v.type == 'playhead') then
	 playhead = v.data % horizontal
      end
   end
   local error = thread:getError()
   assert( not error, error )
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

	 channel.main2audio:push({type="pattern", data=page});

      end
   end
   if (y > screenHeight - bottommargin + inbetweenmargin) then
      if (x > leftmargin and x < screenWidth - rightmargin) then
	 local index = 1 + math.floor((x-leftmargin) / (bitmapSize * pictureInBottomScale))
	 index = math.min(#sounds, index)
	 local s = samples[index]:clone()
	  love.audio.play(s)
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
      local size = pictureInBottomScale * bitmapSize
      if (i == drawingValue) then
	 love.graphics.setColor(palette[color][1] - .1,
				palette[color][2] - .1,
				palette[color][3] - .1)
	 love.graphics.rectangle('fill',
				 leftmargin + size*(i-1), screenHeight - bottommargin + inbetweenmargin,
				 size,size )
      end
      love.graphics.setColor(1,1,1)
      love.graphics.draw(img,
			 leftmargin + size*(i-1), screenHeight - bottommargin + inbetweenmargin, 0,
			 pictureInBottomScale,pictureInBottomScale)
   end

   if playing then
      love.graphics.draw(head, leftmargin + (playhead * cellWidth) , 0, 0, .5, .5)
   end

end
