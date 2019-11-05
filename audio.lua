require('love.timer')
require('love.sound')
require('love.audio')

local min, max = ...
local now = love.timer.getTime()
local time = 0
local lastTick = 0
local lastBeat = -1
local bpm = 124
local pattern = {}
channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main

soundData1 = love.sound.newSoundData( 'instruments/marimba.wav' )
sound1 = love.audio.newSource(soundData1, 'static')
soundData2 = love.sound.newSoundData( 'instruments/CB.wav' )
sound2 = love.audio.newSource(soundData2, 'static')

--local mytick = 0


function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function getPitch(semitone)
   local plusoctave = 0
   local octave = 0
   if semitone > 11 then
      plusoctave = 1
      semitone = semitone % 12
   end

   local freqs = {261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25}
   local n = mapInto(freqs[semitone+1], 261.63, 523.25, 0, 1)
   local o = octave + plusoctave


   if o == -5 then return (0.0625 -(0.03125 -  n/32)) end
   if o == -4 then return (0.125 -(0.0625 -  n/16)) end
   if o == -3 then return (0.25 -(0.125 -  n/8)) end
   if o == -2 then return (0.5 -(0.25 -  n/4)) end
   if o == -1 then return(1 -(0.5 -  n/2)) end
   if o == 0 then return(1 + n) end
   if o == 1 then return(2 + 2*n) end
   if o == 2 then return(4 + 4*n) end
   if o == 3 then return(8 + 8*n) end
   if o == 4 then return(16 + 16*n) end
   if o == 5 then return(32 + 32*n) end

end


while(true) do

   local v = channel.main2audio:pop();
   if v then
      if (v.type == 'pattern') then
	 pattern = v.data
      end
   end

   local n = love.timer.getTime()
   local delta = n - now
   local result = ((delta * 1000))

   now = n
   time = time + delta
   local beat = time * (bpm / 60) * 4
   local tick = ((beat % 1) * (96))
   if math.floor(tick) - math.floor(lastTick) > 1 then
      --print('thread: missed ticks:', math.floor(beat), math.floor(tick), math.floor(lastTick))
   end

   if (math.floor(beat) ~= math.floor(lastBeat)) then
      channel.audio2main:push ({type="playhead", data=math.floor(beat)})
      local index = 1+ math.floor(beat) % 16
      if pattern[index] then
	 for i = 1, 12 do
	    local v = pattern[index][i].value
	    if v > 0 then
	       local s
	       if (v == 1) then
		  s = sound1:clone()
	       end
	       if (v == 2) then
		  s = sound2:clone()
	       end
	       local p = getPitch(12 - i)
	       s:setPitch(p)
	       love.audio.play(s)
	    end
	 end
      end

   end

   lastTick = tick
   lastBeat = beat
   love.timer.sleep(0.01)

end
