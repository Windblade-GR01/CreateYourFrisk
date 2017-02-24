timer = 0
timer2 = 0
Encounter.SetVar("wavetimer",math.huge)
Arena.Resize(200,200)
Player.MoveTo(0,0,false)
difficulty = Encounter["difficulty"]
Encounter.Call("Animate",Encounter['Anim_To_Side'])

fadintime = 60
fadinstate = 0
willshoot = false
source_x = Arena.width/2 + 10
source_y = 0

side = 1

spawntimer = 30 - difficulty * 4
speed = 1.8 + difficulty * 0.1

disp = 50
shake = 1.0

bullets = {}

function Update()
	timer = timer + Time.mult
	while timer >= 1 do
		timer = timer - 1
		timer2 = timer2 + 1
		FadeHands()
		l_hand.MoveTo(-(Arena.currentwidth/2 + 25),-20)
		r_hand.MoveTo((Arena.currentwidth/2 + 25),-20)
		if willshoot == true then
			ShootBullets()
		end
		MoveBullets()
		if timer2 >= 8*60 then
			Encounter.Call("Animate",Encounter['Anim_To_Side_Inv'])
			EndWave()
		end
	end
end

l_hand = CreateProjectile("lhand",-(Arena.width/2 + 25),-20)
r_hand = CreateProjectile("rhand",(Arena.width/2 + 25),-20)
l_hand.sprite.alpha = 0
r_hand.sprite.alpha = 0

function FadeHands()
	if fadinstate < fadintime then
		fadinstate = fadinstate + 1
		l_hand.sprite.alpha = fadinstate/fadintime
		r_hand.sprite.alpha = fadinstate/fadintime
	elseif willshoot ~= true then
		willshoot = true
	end
end

G = - 0.62

function MoveBullets()
	for i = 1,#bullets do
		local bullet = bullets[i]
		if bullet.isactive then
			local velx = bullet.GetVar('velx')
			local vely = bullet.GetVar('vely')
			local posx = bullet.GetVar('posx')
			local posy = bullet.GetVar('posy')
			if (math.abs(posx + velx) > Arena.width/2 or
			math.abs(posy + vely) > Arena.height/2) and
			math.abs(bullet.x) < Arena.width/2 and
			math.abs(bullet.y) < Arena.height/2 then
				bullet.Remove()
			else
				local posx = posx + velx
				local posy = posy + vely
				bullet.MoveTo(posx + ( math.random()-0.5 ) * shake,posy + ( math.random()-0.5 ) * shake)
				bullet.SetVar('posx',posx)
				bullet.SetVar('posy',posy)
				local dx = Player.x - posx
				local dy = Player.y - posy
				local d2 = dx^2 + dy^2
				local dv = G / (d2^1.0)
				bullet.SetVar('velx',velx + dx * dv)
				bullet.SetVar('vely',vely + dy * dv)
			end
		end
	end
end

function ShootBullets()
	if timer2%spawntimer == 0 then
		Audio.PlaySound("fball")
		side = -side
		local bullet = CreateProjectile("fball",side * source_x,source_y)
		local dispx = math.random(disp)-disp/2
		local dispy = math.random(disp)-disp/2
		local dir = Direction({Player.x + dispx,Player.y + dispy},{bullet.x,bullet.y})
		bullet.SetVar('velx',speed * dir[1])
		bullet.SetVar('vely',speed * dir[2])
		bullet.SetVar('posx',bullet.x)
		bullet.SetVar('posy',bullet.y)
		table.insert(bullets,bullet)
	end
end

function Direction(postarget,posshooter)
	local dx = postarget[1] - posshooter[1]
	local dy = postarget[2] - posshooter[2]
	local d = math.sqrt(dx^2+dy^2)
	local alpha = math.acos(dx/d)
	if dy > 0 then
		alpha = alpha
	else
		alpha = - alpha
	end
	local x = math.cos(alpha)
	local y = math.sin(alpha)
	local dir = {x,y}
	return dir
end

function OnHit(bullet)
	Player.Hurt(5)
end