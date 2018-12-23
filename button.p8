pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 init_variables()
 setup_high_score_table()
end

function _update()
 check_button()
 check_instruction_toggle()
 increment_timer()
 set_high_score_obj()
 increment_drop()
 move_particles()
end

function _draw()
	cls()
	draw_background()
	draw_particles()
	draw_score()
	draw_highscore()
	draw_max()
	toggle_intructions_text()
	flash()
	debug()
end
-->8
//draw
function draw_background()
 rectfill(0,0,128,128,background_color)
 write_text('congratulations', 36, 80, 0)
end

function draw_particles()
 for particle_group in all(particles) do
  for particle in all(particle_group) do
   print('.', particle.x, particle.y, particle.color_num)
  end
 end
end

function draw_score()
 local color_num = score_color
 local x = score_x
 local y = score_y
 write_text(score, x, y, color_num) 
 if instructions then
  write_text("press 'x' to get a new number", x-56, y+8, 7)
 end
end

function draw_highscore()
 local color_num = 10
 local x = high_x
 local y = high_y
 write_text('high:', x, y, color_num)
 for i=1, 5 do
  if tonum(high_score_table[i][1]) >-1 then
   write_text(high_score_table[i][1], high_score_table[i][2], high_score_table[i][3], high_score_table[i][4])
  end
 end
 if instructions then
  write_text('high so far', x, y+8, 7)
 end
end

function draw_max()
	local color_num = 14
	local x = max_x
	local y = max_y
	write_text('ceil:',x,y,color_num)
	write_text(max_score, x+24, y, color_num)
	if instructions then
 	write_text('max num can be', x, y+8, 7)
	 write_text('(=1.3*high)', x, y+16, 7)
 end
end

function toggle_intructions_text()
 if instructions then
  write_text("'c' to toggle instructions", 0, 116, 7)
 end
end

function flash()
 if should_flash then
  rectfill(0,0,128,128,15)
  should_flash =false
 end
end

function write_text(text, x, y, color_num)
 print(text, x, y, color_num)
end
-->8
//main functionality

function check_button()
 if btnp(5) then
  button()
 end
end

function check_instruction_toggle()
 if btnp(4) then
  instructions = not(instructions)
 end
end

function increment_timer()
	song.timer += 1
	timer += 1
	if song.timer == 16*8 then
	 if not (song.new_track == song.track) then
	  music(-1, 0)
	  song.new = true
	  song.track = song.new_track
	 end
	end
	if song.timer == 16*8 then
	 if (song.new == true) then
	  music(song.track, 0, 7)
	  song.new = false
	 end
	 song.timer = 0
	end
end

function increment_drop()
 score_x = 56
 score_y = outbounce(timer, 0, 56, 70)
 high_x = 0
 high_y = outbounce(timer, -20, 20, 50)
 max_x = 72
 max_y = outbounce(timer, -80, 80, 100)
end

function set_high_score()
 if score > high_score then
  high_score = score
  max_score = ceil(high_score*1.2)
  if (max_score <0) then
   max_score = 32000
  end
  set_song() 
 end
end

function button()
 score = get_random_score()
 score_color = choose_score_color()
 set_high_score()
 create_particles()
end

function create_particles()
 particle_num = random(1, pow(sqrt(sqrt(sqrt(sqrt(score)))), 5))
 particle_col0r = score_color
 new_particle_group = {}
 for i= 0, particle_num do
  new_particle = create_particle(particle_col0r)
  add(new_particle_group, new_particle)
 end
 add(particles, new_particle_group)
end


-->8
// game_specific helpers

function get_random_score()
	local score = random(1, max_score)
	if score > 30000 then
	 score = random(high_score, max_score)
	end
	if high_score == 32000 then
	 score =  32000
	end
	if score == 32000 then
	 winner = true
	 set_winner()
	end
	return score
end

function choose_score_color()
 local c = 7
 local sound = 0
 if score <= .2*high_score then
  c = 8
  col_debug = 'low'
  sound = 2
 end
 if score >= .8*high_score then
  c = 11
  col_debug = 'high'
  sound = 1
 end
 if score > high_score then
  c = 9
  col_debug = 'record!'
  sound = 3
 end
 if high_score == 0 then
  c = 12
  col_debug = 'new'
 end
 sfx(sound)
 return c
end

function set_song()
 s = #tostr(high_score)
 if s > 5 then
  s = 5
 end
 song.new_track = s-1
end

function set_high_score_obj()
 high = tostr(high_score)
 for i=1, #high do
  high_score_table[i][1] = sub(high, #high-i+1, #high-i+1)
  high_score_table[i][2] = high_x+24+(#high-i)*4
  high_score_table[i][3] = which_dance(i)
  high_score_table[i][4] = 10+i
 end
end

function create_particle(color_num)
 local x = score_x + random (-2, 10) --try to offset the fact that the score extends right from the score_x
 local y = score_y + random (-2, 2)
 local vel_x = random(-4, 4)
 local vel_y = random(-6, 2)
 local return_obj = {}
 return_obj.x = x
 return_obj.y = y
 return_obj.vel_x = vel_x
 return_obj.vel_y = vel_y
 return_obj.color_num = color_num
 return return_obj
end

function move_particles()
 for particle_group in all(particles) do
  for particle in all(particle_group) do
   particle.x += particle.vel_x
   particle.y += particle.vel_y
   particle.vel_x *= .8
   particle.vel_y += 1
   if particle.y > 128 then
    del(particle_group, particle)
   end
  end
 end
end

function which_dance(x)
 if x == 1 then
  return dance_1()
 elseif x == 2 then 
  return dance_2()
 elseif x == 3 then
  return dance_3()
 elseif x == 4 then 
  return dance_4()
 elseif x == 5 then 
  return dance_5()
 end
 return 0
end

function dance_1()
 if song.track < 0 then
  return 0
 end
 local t = song.timer
 print(t, 90, 90)
 if (t >=1 and t <= 20) or (t>=65 and t<=84) then
  return 8
 end
 return 0
end

function dance_2()
 if song.track < 1 then
  return 0
 end
 local t = song.timer
 if (t >=36 and t <= 48) or (t>=101 and t<=120) then
  return 8
 end
 return 0
end

function dance_3()
 if song.track < 2 then
  return 0
 end
 local t = song.timer
 if (t >=1 and t <= 4) or (t >= 65 and t <= 68) then
  return 2
 elseif (t>=37 and t<= 40) or (t>=44 and t <= 48) then
 	return 4
 elseif (t>=101 and t<=104) or (t>=109 and t < 112) then
  return 8
 end
 return 0
end

function dance_4()
 if song.track < 3 then
  return 0
 end
 local t = song.timer
 if (t>= 1 and t<= 4) or (t>= 9 and t <=12) then
  return 5
 elseif (t>=29 and t<=32) then
  return 7
 elseif (t>=49 and t<=52) then
  return 4
 elseif  (t>=57 and t<=60) then
  return 2
 elseif (t>=65 and t<=68) or (t>=73 and t<=76) then
  return 6
 elseif (t>=93 and t<=96) then
  return 8
 elseif (t>=113 and t<=116) then
  return 2
 elseif (t>=121 and t<=124) then
  return 4
 end
end

function dance_5()
 if song.track < 4 then
  return 0
 end
 local t = song.timer
 if (t>= 21 and t<= 24) then
  return 5
 elseif (t>= 37 and t<=40) or (t>= 45 and t<=48) then
  return 4
 elseif (t>=85 and t<= 88) then
  return 6
 elseif (t>= 101 and t<= 104) or (t>= 109 and t<=112) then
  return 8
 end
end

function set_winner()
 winner = true
 background_color = 5
 should_flash = true
end

-->8
//game-agnostic helpers

function random(bot, top)
 top += 1 //to make it inclusive
	return flr(rnd(top-bot)+bot)
end

function outbounce(t, b, c, d)
  t = min(t / d, 1)
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

function pow(x, exp)
 result = 1
 sign = exp/abs(exp)
 for i=sign, exp, sign do
  if exp>0 then
   result = result*x
  elseif exp<0 then
   result = result * (1/x)
  end
 end
 return result
end
-->8
//debug

function debug()
 --print(particle_num, 0, 60, 7)
 --print(pow(score, (1/3)), 0, 116, 7)
 --print(score, 108, 56, 7)
 --print((1/3), 100, 116, 7)
end
-->8
//setup

function init_variables()
 score = 1
 score_x = 0
 score_y = 0
 high_x = 0
 high_y = 0
 max_x = 0
 max_y = 0
 high_score = 0
 total_max = 32000
 score_color = 7
 max_score = 1
 col_debug = ''
 song = {}
 song.track = 0
 song.new_track = 0
 song.handle = ''
 song.new = false
 song.timer = 0
 song.handle = music(0)
 instructions = true
 timer = 0
 high = 0
 particles = {}
 winner = false
 background_color = 0
 should_flash = false
end

function setup_high_score_table() 
 high_score_table = {{-1},{-1},{-1},{-1},{-1}}
end
__sfx__
00010000130001f510295102a5102a51028510245101d510155101451013510155101d510205101350015500185001c5002350023400000000000000000000000000000000000000000000000000000000000000
00010000195101e51022510235102451024510225101f51018510125100f5100d5100f51011510195102151000000000002851029510000000000029510295102951028510285100000000000000000000000000
00010000225102351022510215101e5101d5101a51017510115100f5100e5100f5100f5100f5100f5100e5100a510085100000000000000000000000000000000000000000000000000000000000000000000000
000100001d5102251025510265102511025110235101f5101c5101951027110271102811017510195101b5102a1102a11022510247103011030110301102751029510331103311034110295102c5102b7002d500
0010000018750187501875018750000000000000000000001b7001b7001b7001b700000000000000000000001a7501a7501a7501a750000000000000000000001d7001d7001d7001d7000c7000c7000c7000c700
0010000018750187501875018750000000000000000000001b7501b7501b7501b750000000000000000000001a7501a7501a7501a750000000000000000000001d7501d7501d7501d75000000000000000000000
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000001a7501a7501a7501a750000000000000000000001d7501d7501d7501d75000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d7501d7501d7501d75000000000000000000000
0010000018550000000000000000007000070000700007001b550000001b55000700007000000000000000001a550000000000000000007000070000700007001d550007001d5500000000000000000000000000
00100000000000000000000000000000000000000000000000000000001b7001b7001b700000000000000000000000000000000000000000000000000000000000000000001d7001d7001d700000000000000000
001000200b420014000b4200d4000d400000000d430074000000000000000000a400057600570004760047000b4200b4000b4200b40000000000000e4300c4000000000000000000000003760037000776007700
001000000b420011000b4200110002760011000d4300560005770053000177001400057700570004770000000b4200b4000b4200b40002760027000e4300c4001b7201d4001b7201d40003770037000777007700
001000000000001110000000461001200011100000004610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000001a7501a7501a7501a750000000000000000000000000000000000000000000000000000000000000
__music__
03 04504344
03 05454647
03 05084847
03 05080a47
03 05080b4b
03 080a0b4b

