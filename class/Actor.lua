-- Veins of the Earth
-- Zireael
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "engine.class"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorTemporaryEffects"
--require "engine.interface.ActorLife"
require "mod.class.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require 'engine.interface.ActorInventory'
require "engine.interface.ActorResource"
require "engine.interface.ActorFOV"
require 'engine.interface.ActorQuest'
require "mod.class.interface.Combat"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.Actor,
	engine.interface.ActorTemporaryEffects,
	mod.class.interface.ActorLife,
	engine.interface.ActorProject,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorTalents,
	engine.interface.ActorInventory,
	engine.interface.ActorResource,
	engine.interface.ActorFOV,
	engine.interface.ActorQuest,
	mod.class.interface.Combat))

function _M:init(t, no_default)
	-- Define some basic combat stats
	self.combat_dr = 0
--	self.combat_base_ac = 10
	self.combat_bab = 0
	self.combat_attack = 0
	self.hit_die = 4

	--Define AC types
	self.combat_armor_ac = 0
	self.combat_magic_armor = 0
	self.combat_shield = 0
	self.combat_magic_shield = 0
	self.combat_natural = 0
	
	self.combat_protection = 0
	self.combat_dodge = 0
	self.combat_untyped = 0

	--Some more combat stuff
	self.more_attacks = 0
	self.poison = self.poison or nil

	--Challenge Rating & ECL set to 0 & 1
	self.challenge = 0
	self.ecl = 1

	--Skill ranks
	self.max_skill_ranks = 4
	self.cross_class_ranks = math.floor(self.max_skill_ranks/2)

	-- Default melee barehanded damage
	self.combat = { dam = {1,4} }

	--Can now get classes
	self.classes = self.classes or {}

	--Saves
	self.will_save = self.will_save or 0
	self.reflex_save = self.reflex_save or 0
	self.fortitude_save = self.fortitude_save or 0

	--Skillz!
	self.skill_balance = 0
	self.skill_bluff = 0
	self.skill_climb = 0
	self.skill_concentration = 0
	self.skill_diplomacy = 0
	self.skill_disabledevice = 0
	self.skill_escapeartist = 0
	self.skill_handleanimal = 0
	self.skill_heal = 0
	self.skill_hide = 0
	self.skill_intimidate = 0
	self.skill_intuition = 0
	self.skill_jump = 0
	self.skill_knowledge = 0
	self.skill_listen = 0
	self.skill_movesilently = 0
	self.skill_openlock = 0
	self.skill_search = 0
	self.skill_sensemotive = 0
	self.skill_swim = 0
	self.skill_pickpocket = 0 --what is called sleight of hand in 3.5
	self.skill_spellcraft = 0
	self.skill_survival = 0
	self.skill_tumble = 0
	self.skill_usemagic = 0

	--Skill bonuses (feat, kit etc.) to be applied on top of ranks
	self.skill_bonus_balance = 0
	self.skill_bonus_bluff = 0
	self.skill_bonus_climb = 0
	self.skill_bonus_concentration = 0
	self.skill_bonus_diplomacy = 0
	self.skill_bonus_disabledevice = 0
	self.skill_bonus_escapeartist = 0
	self.skill_bonus_handleanimal = 0
	self.skill_bonus_heal = 0
	self.skill_bonus_hide = 0
	self.skill_bonus_intimidate = 0
	self.skill_bonus_intuition = 0
	self.skill_bonus_jump = 0
	self.skill_bonus_knowledge = 0
	self.skill_bonus_listen = 0
	self.skill_bonus_movesilently = 0
	self.skill_bonus_openlock = 0
	self.skill_bonus_search = 0
	self.skill_bonus_sensemotive = 0
	self.skill_bonus_swim = 0
	self.skill_bonus_pickpocket = 0 --what is called sleight of hand in 3.5
	self.skill_bonus_spellcraft = 0
	self.skill_bonus_survival = 0
	self.skill_bonus_tumble = 0
	self.skill_bonus_usemagic = 0

	--Make resists and projectiles work
	t.resists = t.resists or {}
    t.melee_project = t.melee_project or {}
    t.ranged_project = t.ranged_project or {}
	t.can_pass = t.can_pass or {}

	--Actually initiate some basic engine stuff
	engine.Actor.init(self, t, no_default)
	engine.interface.ActorTemporaryEffects.init(self, t)
	mod.class.interface.ActorLife.init(self, t)
	engine.interface.ActorProject.init(self, t)
	engine.interface.ActorTalents.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorInventory.init(self, t)
	engine.interface.ActorLevel.init(self, t)
	engine.interface.ActorFOV.init(self, t)

	-- Short-ciruit the engine's initial forced level-up mechanism, which
	-- doesn't work quite the way we want.
	self.start_level = self.level
	
		-- Charges for spells
	self.charges = {}
	self.max_charges = {}
	self.allocated_charges = {}

	--Scoring
	self.kills = 0
	self.seen = false

	--Light-related
	self.lite = 0 --Temporary test
	self.infravision = 0

	self.life = t.max_life or self.life

	self.last_attacker = nil

	-- Use weapon damage actually
	if not self:getInven("MAIN_HAND") or not self:getInven("OFF_HAND") then return end
	if weapon then dam = weapon.combat.dam
	end
end

-- Called when our stats change
function _M:onStatChange(stat, v)
	if stat == "str" then self:checkEncumbrance() end
	if stat == self.STAT_CON then self.max_life = self.max_life + v*2 end
end 

function _M:getName(t)
	t = t or {}
	local name = self.name
	if t.indef_art then
		name = (name:match('^[AEIOUaeiou]') and 'an ' or 'a ') .. name
	end
	return name
end

function _M:act()
	if not engine.Actor.act(self) then return end

	self.changed = true

	-- Cooldown talents
	self:cooldownTalents()

	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()

	--Poison timer
	if self.poison_timer then self.poison_timer = self.poison_timer - 1 end


	--Death & dying related stuff
	if self.life > 0 then self:removeEffect(self.EFF_DISABLED) end

	if self.life == 0 then 
		self:setEffect(self.EFF_DISABLED, 1, {})
		self:removeEffect(self.EFF_DYING)
		end


	if self.life < 0 then 
		self:removeEffect(self.EFF_DISABLED)
		self:setEffect(self.EFF_DYING, 1, {})
		--Monsters bleed out quicker than players and have a smaller chance to stabilize
		if self == game.player then
			--Raging characters are considered stable as long as they are raging
			if self:hasEffect(self.EFF_RAGE) then self.life = 0 end
			if rng.percent(10) then self.life = 0
			else self.life = self.life - 1 end	
		else
			if rng.percent(2) then self.life = 0
			else self.life = self.life - 3 end
		end		
	end	

	--Ensure they can actually die due to bleeding out
	if not self == game.player and self.life <= -10 and not self.dead then self:die(game.player) end
	if self.life <= -10 and not self.dead then self:die() end

	-- check passive stuff. This should be in actbase I think but I cant get it to work
	if self:knowTalent(self.T_BLOOD_VENGANCE) then
		--Bloodied!
		if self.life / self.max_life < 0.5 then
			self:setEffect(self.EFF_BLOOD_VENGANCE, 1, {})
		end
	end

	if self:attr("sleep") then self.energy.value = 0 end

	-- Check terrain special effects
	game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "on_stand", self)

	--From Startide
	-- Shrug off effects
for eff_id, params in pairs(self.tmp) do
		local DC = params.DC_ongoing or 10
		local eff = self.tempeffect_def[eff_id]
		if eff.decrease == 0 then 
			if self:saveRoll(DC, eff.type) then
				params.dur = 0 
			end
		end
end


	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

	return true
end

--Are we able to move at all? Currently checks if we are able to move anywhere, aka not if we cant move certain directions
function _M:canMove()
	if self:attr("never_move") then return false end
	return true
end

function _M:move(x, y, force)
	local moved = false
	if not self:canMove() then return moved end

	local ox, oy = self.x, self.y

	if force or self:enoughEnergy() then
		-- Check for confusion or random movement flag.
		local rand_prob = self.ai_state and self.ai_state.random_move or 0
		local rand_move = self:hasEffect(self.EFF_CONFUSED) or rng.range(1,100) <= rand_prob
		if rand_move and self.x and self.y then
			x, y = self.x + rng.range(-1,1), self.y + rng.range(-1,1)
		end

		moved = engine.Actor.move(self, x, y, force)

		if not force and moved and (self.x ~= ox or self.y ~= oy) and not self.did_energy then
			local speed = 1.0 - (1.0 * (self.movement_speed_bonus or 0))
			self:useEnergy(game.energy_to_act * speed)
		end
	end
	self.did_energy = nil

	-- TODO This is where we do auto-search for traps.
	return moved
end

--Tooltip stuffs
function _M:className()
	if self == game.player then end
	if self.classes and self.classes["Fighter"] then return "#LIGHT_BLUE#%fighter#LAST#"
	elseif self.classes and self.classes["Cleric"] then return "#LIGHT_BLUE#%cleric#LAST#" 
	elseif self.classes and self.classes["Barbarian"] then return "#LIGHT_BLUE#%barbarian#LAST#"
	elseif self.classes and self.classes["Rogue"] then return "#LIGHT_BLUE#%rogue#LAST#"
	elseif self.classes and self.classes["Ranger"] then return "#LIGHT_BLUE#%ranger#LAST#"
	elseif self.classes and self.classes["Wizard"] then return "#LIGHT_BLUE#%wizard#LAST#"
	elseif self.classes and self.classes["Sorcerer"] then return "#LIGHT_BLUE#%sorcerer#LAST#"
	elseif self.classes and self.classes["Druid"] then return "#LIGHT_BLUE#%druid#LAST#"
	elseif self.classes and self.classes["Warlock"] then return "#LIGHT_BLUE#%warlock#LAST#"
	else return "#LAST#" end
end

function _M:colorStats(stat)
	local player = game.player
	

	if (self:getStat(stat)-10)/2 > (player:getStat(stat)-10)/2 then return "#RED#"..self:getStat(stat).."#LAST#"
	elseif (self:getStat(stat)-10)/2 < (player:getStat(stat)-10)/2 then return "#GREEN#"..self:getStat(stat).."#LAST#"
	else return "#WHITE#"..self:getStat(stat).."#LAST#" end
end

function _M:colorCR()
	local player = game.player

    if not self:attr("challenge") then
        return "#WHITE#-#LAST#"
    end

	if self.challenge > player.level then return "#FIREBRICK#"..self:attr('challenge').."#LAST#"
	elseif self.challenge < (player.level - 4) then return "#LIGHT_GREEN#"..self:attr('challenge').."#LAST#"
	elseif self.challenge < player.level then return "#DARK_GREEN#"..self:attr('challenge').."#LAST#"
	else return "#GOLD#"..self:attr('challenge').."#LAST#" end
end	

function _M:tooltip()
	if self.life >= 0 then
	return ([[%s%s %s
		#RED#HP: %d (%d%%)#LAST#
		STR %s DEX %s CON %s 
		INT %s WIS %s CHA %s
		#GOLD#CR %s#LAST#
		#WHITE#%s]]):format(
		self:getDisplayString(),
		self.name, self:className(),
		self.life, self.life / self.max_life *100,
		self:colorStats('str'),
		self:colorStats('dex'),
		self:colorStats('con'),
		self:colorStats('int'),
		self:colorStats('wis'),
		self:colorStats('cha'),
		self:colorCR(),
		self.desc or ""
	)
		--To stop % getting out of whack when HP are negative, we remove them from the tooltips altogether
	else
	return ([[%s%s %s
		#CRIMSON#HP: %d#LAST#
		STR %s DEX %s CON %s 
		INT %s WIS %s CHA %s
		#GOLD#CR %s#LAST#
		#WHITE#%s]]):format(
		self:getDisplayString(),
		self.name, self:className(),
		self.life,
		self:colorStats('str'),
		self:colorStats('dex'),
		self:colorStats('con'),
		self:colorStats('int'),
		self:colorStats('wis'),
		self:colorStats('cha'),
		self:colorCR(),
		self.desc or ""
	)	
	end	
end

function _M:onTakeHit(value, src)

	--if a sleeping target is hit, it will wake up
	if self:hasEffect(self.EFF_SLEEP) then
		self:removeEffect(self.EFF_SLEEP)
		game.logSeen(self, "%s wakes up from being hit!", self.name)
	end
	
	return value
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)

	-- Gives the killer some exp for the kill
	local killer
	killer = src or self.last_attacker

	if killer and killer.gainExp then
		killer:gainExp(self:worthExp(killer))
	end

	-- Drop stuff
	local dropx, dropy = self.x, self.y
	if game.level.map:checkAllEntities(dropx, dropy, 'block_move') then
		-- If our grid isn't suitable, find one nearby.
		local cands = {}
		for cx = self.x - 3, self.x + 3 do
			for cy = self.y - 3, self.y + 3 do
				local d = core.fov.distance(self.x, self.y, cx, cy)
				if game.level.map:isBound(cx, cy) and d <= 3 and not game.level.map:checkAllEntities(cx, cy, 'block_move') then
				cands[#cands+1] = {cx, cy, d}
				end
			end
		end
		if #cands > 0 then
			-- Pick nearby spots with higher probability.
			-- [Does this even work, though?]
			table.sort(cands, function(a, b) return a[3] < b[3] end)
			local cand = rng.table(cands)
			dropx, dropy = cand[1], cand[2]
		end
	end

	local invens = {}
	for id, inven in pairs(self.inven) do
		invens[#invens+1] = inven
	end
	-- [Not sure why we're sorting these; I'm following T4's Actor:die()]
	local f = function(a, b) return a.id ~= 1 and (b.id == 1 or a.id < b.id) end
	table.sort(invens, f)
	for id, inven in pairs(invens) do
		for i = #inven, 1, -1 do
			local o = inven[i]
			o.dropped_by = o.dropped_by or self.name
			self:removeObject(inven, i, true)
			game.level.map:addObject(dropx, dropy, o)
		end
	end
	self.inven = {}

	if self ~= game.player and dropx == game.player.x and dropy == game.player.y then
		game.log('You feel something roll beneath your feet.')
	end

	-- Register kills for hiscores
	if killer and killer == game.player then
		if self.challenge < (game.player.level - 4) then 
			killer.kills = killer.kills
		else 
		killer.kills = killer.kills + 1 end
	else end

	self.dead = true -- mark as dead, for scores?

	-- Record kills for kill count
	local player = game.player
	
	if killer and killer == player then 
		player.all_kills = player.all_kills or {}
		player.all_kills[self.name] = player.all_kills[self.name] or 0
		player.all_kills[self.name] = player.all_kills[self.name] + 1
	end	


	return true
end

function _M:resetToFull()
	if self.dead then return end
	self.life = self.max_life
end

function _M:levelupMsg()
  -- Subclasses handle the actual mechanics of leveling up; here we just
  -- print the message and add the flyer.
	local stale = false
	if self.level_hiwater then
		stale = self.level_hiwater >= self.level
		self.level_hiwater = math.max(self.level_hiwater, self.level)
	end

	game.logSeen(self, "#00FFFF#%s %s level %d.#LAST#", self.name, stale and 'regains' or 'gains', self.level)
	if self.x and self.y and game.level.map.seens(self.x, self.y) then
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 80, 0.5, -2, 'LEVEL UP!', stale and {255, 0, 255} or {0, 255, 255})
	end

	-- Return true if this is the first time we've hit this level.
	return not stale
end

function _M:attack(target)
	self:bumpInto(target)
end

function _M:incMoney(v)
	if self.summoner then self = self.summoner end
	self.money = self.money + v
	if self.money < 0 then self.money = 0 end
	self.changed = true
end

function _M:getArmor()
	local ac = self.ac
	local dex_bonus = (self.getDex()-10)/2

	if self:hasEffect(self.EFF_BLIND) then 
		ac = ac - 2
		dex_bonus = math.min(dex_bonus, 0) --negate dex bonus, if any
	end

	ac = self.ac + dex_bonus 

	return ac
end

	

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	local tt_def = self:getTalentTypeFrom(ab.type[1])
	if tt_def.all_limited then --all_limited talenttypes all have talents that are daily limited 
		--No casting spells if your key stat is <= 9

		if self.classes and self.classes["Wizard"] and self:getInt() <= 9 then
			if not silent then game.logPlayer(self, "Your Intelligence is too low!") end
		return false
		end
		if self.classes and self.classes["Ranger"] and self:getWis() <= 9 then 
			if not silent then game.logPlayer(self, "Your Wisdom is too low!") end
		return false
		end
		if self.classes and self.classes["Cleric"] and self:getWis() <= 9 then 
			if not silent then game.logPlayer(self, "Your Wisdom is too low!") end
		return false
		end
		
		if self.classes and self.classes["Bard"] and self:getCha() <= 9 then 
			if not silent then game.logPlayer(self, "Your Charisma is too low!") end
		return false
		end	

		if  self:getCharges(ab) <= 0 then
			if not silent then game.logPlayer(self, "You have to prepare this spell") end
			return false 
		end
	end

	-- Check for special prequisites
	if ab.on_pre_use and not ab.on_pre_use(self, ab, silent) then 
		return nil
	end
	

	if not self:enoughEnergy() then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_power and self.max_power < ab.sustain_power and not self:isTalentActive(ab.id) then
			game.logPlayer(self, "You do not have enough power to activate %s.", ab.name)
			return false
		end
	else
		if ab.power and self:getPower() < ab.power then
			game.logPlayer(self, "You do not have enough power to cast %s.", ab.name)
			return false
		end
	end

	if not silent then
	-- Allow for silent talents
		if ab.message ~= nil then
			if ab.message then
				game.logSeen(self, "%s", self:useTalentMessage(ab))
			end
			elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
				game.logSeen(self, "%s activates %s.", self.name:capitalize(), ab.name)
			elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
				game.logSeen(self, "%s deactivates %s.", self.name:capitalize(), ab.name)
			else
				game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
		end
	end
	return true
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if not ret then return end

	local tt_def = self:getTalentTypeFrom(ab.type[1])

	--remove charge
	if tt_def.all_limited then self:incCharges(ab, -1) end

	--Spell failure!
	if self.classes and self.classes["Wizard"] and (self.spell_fail or 0) > 0 and rng.percent(self.spell_fail) then game.logPlayer(self, "You armor hinders your spellcasting! Your spell fails!") return false end
	if self.classes and self.classes["Sorcerer"] and (self.spell_fail or 0) > 0 and rng.percent(self.spell_fail) then game.logPlayer(self, "You armor hinders your spellcasting! Your spell fails!") return false end
	if self.classes and self.classes["Bard"] and (self.spell_fail or 0) > 0 and rng.percent(self.spell_fail) then game.logPlayer(self, "You armor hinders your spellcasting! Your spell fails!") return false end

	self:useEnergy()

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_power then
				self.max_power = self.max_power - ab.sustain_power
			end
		else
			if ab.sustain_power then
				self.max_power = self.max_power + ab.sustain_power
			end
		end
	else
		if ab.power then
			self:incPower(-ab.power)
		end
	end

	return true
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t)
	local d = {}

	if t.mode == "passive" then d[#d+1] = "#6fff83#Use mode: #00FF00#Passive"
	elseif t.mode == "sustained" then d[#d+1] = "#6fff83#Use mode: #00FF00#Sustained"
	else d[#d+1] = "#6fff83#Use mode: #00FF00#Activated"
	end

	if t.power or t.sustain_power then d[#d+1] = "#6fff83#Power cost: #7fffd4#"..(t.power or t.sustain_power) end
	if self:getTalentRange(t) > 1 then d[#d+1] = "#6fff83#Range: #FFFFFF#"..self:getTalentRange(t)
	else d[#d+1] = "#6fff83#Range: #FFFFFF#melee/personal"
	end
	if t.cooldown then d[#d+1] = "#6fff83#Cooldown: #FFFFFF#"..t.cooldown end

	return table.concat(d, "\n").."\n#6fff83#Description: #FFFFFF#"..t.info(self, t)
end

--- How much experience is this actor worth
-- @param target to whom is the exp rewarded
-- @return the experience rewarded
function _M:worthExp(target)
	-- TODO Don't get experience from killing friendlies.
	if self.challenge < (game.player.level - 4) then return 0
	else return (self.exp_worth) end
end




--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end

	-- Newsflash: blind people can't see!
	if self:hasEffect(self.EFF_BLIND) then return false,100 end --Like this, the actor actually knows where its target is. Its just bad at hitting


	if actor:attr("stealth") and actor ~= self then
		local check = self:opposedCheck("spot", actor, "hide")
		if not check then 
			local check2 = self:opposedCheck("listen", actor, "movesilently")
			if check2 then return false, 100 end --we know where target is thanks to hearing
			return false, 0 
		end
	end

	return true, 100
end

--Taken from ToME
function _M:canSee(actor, def, def_pct)
	if not actor then return false, 0 end

	self.can_see_cache = self.can_see_cache or {}
	local s = tostring(def).."/"..tostring(def_pct)

	if self.can_see_cache[actor] and self.can_see_cache[actor][s] then return self.can_see_cache[actor][s][1], self.can_see_cache[actor][s][2] end
	self.can_see_cache[actor] = self.can_see_cache[actor] or {}
	self.can_see_cache[actor][s] = self.can_see_cache[actor][s] or {}

	local res, chance = self:canSeeNoCache(actor, def, def_pct)
	self.can_see_cache[actor][s] = {res,chance}

	-- Make sure the display updates
	if self.player and type(def) == "nil" and actor._mo then actor._mo:onSeen(res) end

	return res, chance
end

--- Reset the cache of everything else that had see us on the level
function _M:resetCanSeeCacheOf()
	if not game.level then return end
	for uid, e in pairs(game.level.entities) do
		if e.can_see_cache and e.can_see_cache[self] then e.can_see_cache[self] = nil end
	end
	game.level.map:updateMap(self.x, self.y)
end

--Taken from Qi Daozei
--- Checks if the actor can see the target actor, *including* checking for
--- LOS, lighting, etc.
function _M:canReallySee(actor)
    -- Non-players currently have no light limitations, so just use FOV.
    if not self.fov then self:doFOV() end
    return self:canSee(actor) and self.fov.actors[actor]
end

--- Is the target concealed for us?
-- Returns false if it isn't, or a number (50%/20% concealment) if it is
function _M:isConcealed(actor)
	if self:hasEffect(self.EFF_BLIND) then return 50 end
	return false
end

--- Can the target be applied some effects
-- @param what a string describing what is being tried
function _M:canBe(what)
	if what == "poison" and rng.percent(100 * (self:attr("poison_immune") or 0)) then return false end
	if what == "cut" and rng.percent(100 * (self:attr("cut_immune") or 0)) then return false end
	if what == "confusion" and rng.percent(100 * (self:attr("confusion_immune") or 0)) then return false end
	if what == "blind" and rng.percent(100 * (self:attr("blind_immune") or 0)) then return false end
	if what == "stun" and rng.percent(100 * (self:attr("stun_immune") or 0)) then return false end
	if what == "fear" and rng.percent(100 * (self:attr("fear_immune") or 0)) then return false end
	if what == "knockback" and rng.percent(100 * (self:attr("knockback_immune") or 0)) then return false end
	if what == "instakill" and rng.percent(100 * (self:attr("instakill_immune") or 0)) then return false end
	return true
end

--Skill checks, Zireael
function _M:getSkill(skill)
	local stat_for_skill = { balance = "dex", bluff = "cha", climb = "str", concentration = "int", diplomacy = "cha", disabledevice = "int", escapeartist = "dex", handleanimal = "wis", heal = "wis", hide = "dex", intimidate = "cha", intuition = "int", jump = "str", knowledge = "wis", listen = "wis", movesilently = "dex", openlock = "dex", pickpocket = "dex", search = "int", sensemotive = "wis", swim = "str", spellcraft = "int", spot = "wis", survival = "wis", tumble = "dex", usemagic = "int" }
	if (not skill) then return 0 end
	local penalty_for_skill = { balance = "yes", bluff = "no", climb = "yes", concentration = "no", diplomacy = "no", disabledevice = "no", escapeartist = "yes", handleanimal = "no", heal = "no", hide = "yes", intimidate = "no", intuition = "no", jump = "yes", knowledge = "no", listen = "no", movesilently = "yes", openlock = "no", pickpocket = "yes", search = "no", sensemotive = "no", spot = "no", swim = "yes", spellcraft = "no", survival = "no", tumble = "yes", usemagic = "no" }

	local check = (self:attr("skill_"..skill) or 0) + (self:attr("skill_bonus_"..skill) or 0) + math.floor((self:getStat(stat_for_skill[skill])-10)/2) 

	if penalty_for_skill[skill] == "yes" then return check - (self:attr("armor_penalty") or 0) - (self:attr("load_penalty") or 0) end
	return check end 

function _M:skillCheck(skill, dc, silent)
	local success = false

	local d = rng.dice(1,20)
	if d == 20 then return true
	elseif d == 1 then return false
	end

	local result = d + (self:getSkill(skill) or 0)

	if result > dc then success = true end

	--Limit logging to the player
	if not silent and self == game.player then
		local who = self:getName()
		local s = ("%s check for %s: dice roll %d + bonus %d = %d vs DC %d -> %s"):format(
			skill:capitalize(), who, d, self:getSkill(skill) or 0, result, dc, success and "success" or "failure")
		game.log(s)
	end

	return success
end

function _M:opposedCheck(skill1, target, skill2)
	local success = false

	local my_skill = self:getSkill(skill1)
	local enemy_skill = target:getSkill(skill2)
	local d = rng.dice(1,20)
	local d2 = rng.dice(1,20)
	local enemy_total = d2 + (enemy_skill or 0)
	local my_total = d + (my_skill or 0)

	if d + (my_skill or 0) > enemy_total then success = true end

	if self == game.player then
		local s = ("Opposed check: dice roll %d + bonus %d versus DC %d -> %s"):format(
			d, my_skill or 0, enemy_total, success and "success" or "failure")
		game.log(s)
	end 
	if target == game.player then
		local player_success = true
		if success then player_success = false end
		local s = ("Opposed check: %d versus DC %d -> %s"):format(
			my_total, enemy_total, player_success and "success" or "failure")
		game.log(s)
	end 

	return success
end

--Cross-class skills, Zireael
function _M:crossClass(skill)
	--List class skills for every class 
	local c_barbarian = { balance = "no", bluff = "no", climb = "yes", concentration = "no", diplomacy = "no", disabledevice = "no", escapeartist = "no", handleanimal = "yes", heal = "no", hide = "no", intimidate = "yes", intuition = "no", jump = "yes", knowledge = "no", listen = "yes", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "no", spot = "no", swim = "yes", spellcraft = "no", survival = "yes", tumble = "no", usemagic = "no" }
	local c_bard = { balance = "yes", bluff = "yes", climb = "yes", concentration = "yes", diplomacy = "yes", disabledevice = "no", escapeartist = "yes", handleanimal = "no", heal = "no", hide = "yes", intimidate = "no", intuition = "yes", jump = "yes", knowledge = "yes", listen = "yes", movesilently = "yes", openlock = "no", pickpocket = "yes", search = "no", sensemotive = "yes", spot = "no", swim = "yes", spellcraft = "yes", survival = "yes", tumble = "yes", usemagic = "yes" }
	local c_cleric = { balance = "no", bluff = "no", climb = "no", concentration = "yes", diplomacy = "yes", disabledevice = "no", escapeartist = "no", handleanimal = "no", heal = "yes", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "no", spot = "no", swim = "no", spellcraft = "yes", survival = "no", tumble = "no", usemagic = "no" }
	local c_druid = { balance = "no", bluff = "no", climb = "no", concentration = "yes", diplomacy = "yes", disabledevice = "no", escapeartist = "no", handleanimal = "yes", heal = "yes", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "yes", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "no", spot = "yes", swim = "yes", spellcraft = "yes", survival = "yes", tumble = "no", usemagic = "no" }
	local c_fighter = { balance = "no", bluff = "no", climb = "yes", concentration = "no", diplomacy = "no", disabledevice = "no", escapeartist = "no", handleanimal = "yes", heal = "no", hide = "no", intimidate = "yes", intuition = "no", jump = "yes", knowledge = "no", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "no", spot = "no", swim = "yes", spellcraft = "no", survival = "no", tumble = "no", usemagic = "no" }
	local c_monk = { balance = "yes", bluff = "no", climb = "yes", concentration = "no", diplomacy = "yes", disabledevice = "no", escapeartist = "yes", handleanimal = "no", heal = "no", hide = "yes", intimidate = "no", intuition = "yes", jump = "yes", knowledge = "yes", listen = "yes", movesilently = "yes", openlock = "no", pickpocket = "no", search = "no", sensemotive = "yes", spot = "yes", swim = "yes", spellcraft = "no", survival = "no", tumble = "yes", usemagic = "no" }
	local c_paladin = { balance = "no", bluff = "no", climb = "no", concentration = "yes", diplomacy = "yes", disabledevice = "no", escapeartist = "no", handleanimal = "yes", heal = "yes", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "yes", spot = "no", swim = "no", spellcraft = "no", survival = "no", tumble = "no", usemagic = "no" }
	local c_ranger = { balance = "no", bluff = "no", climb = "yes", concentration = "yes", diplomacy = "no", disabledevice = "no", escapeartist = "no", handleanimal = "yes", heal = "yes", hide = "yes", intimidate = "no", intuition = "yes", jump = "yes", knowledge = "yes", listen = "yes", movesilently = "yes", openlock = "no", pickpocket = "no", search = "yes", sensemotive = "no", spot = "yes", swim = "yes", spellcraft = "no", survival = "yes", tumble = "no", usemagic = "no" }
	local c_rogue = { balance = "yes", bluff = "yes", climb = "yes", concentration = "no", diplomacy = "yes", disabledevice = "yes", escapeartist = "yes", handleanimal = "no", heal = "no", hide = "yes", intimidate = "no", intuition = "yes", jump = "yes", knowledge = "yes", listen = "yes", movesilently = "yes", openlock = "yes", pickpocket = "yes", search = "yes", sensemotive = "yes", spot = "yes", swim = "no", spellcraft = "no", survival = "no", tumble = "yes", usemagic = "yes" }
	local c_sorcerer = { balance = "no", bluff = "yes", climb = "no", concentration = "yes", diplomacy = "yes", disabledevice = "no", escapeartist = "no", handleanimal = "no", heal = "no", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "yes", spot = "no", swim = "no", spellcraft = "yes", survival = "no", tumble = "no", usemagic = "no" }
	local c_wizard = { balance = "no", bluff = "no", climb = "no", concentration = "yes", diplomacy = "no", disabledevice = "no", escapeartist = "no", handleanimal = "no", heal = "no", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "yes", spot = "no", swim = "no", spellcraft = "yes", survival = "no", tumble = "no", usemagic = "no" }
	local c_warlock = { balance = "no", bluff = "no", climb = "no", concentration = "yes", diplomacy = "no", disabledevice = "no", escapeartist = "no", handleanimal = "no", heal = "no", hide = "no", intimidate = "no", intuition = "yes", jump = "no", knowledge = "yes", listen = "no", movesilently = "no", openlock = "no", pickpocket = "no", search = "no", sensemotive = "yes", spot = "no", swim = "no", spellcraft = "yes", survival = "no", tumble = "no", usemagic = "no" }
	
	if (not skill) then return false end

	if self.last_class and self.last_class == "Barbarian" and c_barbarian[skill] == "no" then return true end
	if self.last_class and self.last_class == "Bard" and c_bard[skill] == "no" then return true end
	if self.last_class and self.last_class == "Cleric" and c_cleric[skill] == "no" then return true end
	if self.last_class and self.last_class == "Druid" and c_druid[skill] == "no" then return true end
	if self.last_class and self.last_class == "Fighter" and c_fighter[skill] == "no" then return true end
	if self.last_class and self.last_class == "Monk" and c_monk[skill] == "no" then return true end
	if self.last_class and self.last_class == "Paladin" and c_paladin[skill] == "no" then return true end
	if self.last_class and self.last_class == "Rogue" and c_rogue[skill] == "no" then return true end
	if self.last_class and self.last_class == "Sorcerer" and c_sorcerer[skill] == "no" then return true end
	if self.last_class and self.last_class == "Wizard" and c_wizard[skill] == "no" then return true end
	if self.last_class and self.last_class == "Shadowdancer" and c_rogue[skill] == "no" then return true end
	if self.last_class and self.last_class == "Assasin" and c_rogue[skill] == "no" then return true end

	return false
end

function _M:classFeat(tid)
	local Talents = require "engine.interface.ActorTalents"

	--A hardcoded list of class feats per class
	local f_barbarian = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes", T_MARTIAL_WEAPON_PROFICIENCY = "yes" }
	local f_bard = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes" }
	local f_cleric = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_HEAVY_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes"  }
	local f_druid = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes" }
	local f_fighter = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_HEAVY_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes", T_MARTIAL_WEAPON_PROFICIENCY = "yes" }
	local f_monk = { T_SIMPLE_WEAPON_PROFICIENCY = "yes" }
	local f_paladin = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes", T_MARTIAL_WEAPON_PROFICIENCY = "yes" }
	local f_ranger = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes", T_MARTIAL_WEAPON_PROFICIENCY = "yes" }
	local f_rogue = { T_LIGHT_ARMOR_PROFICIENCY = "yes", T_MEDIUM_ARMOR_PROFICIENCY = "yes", T_SIMPLE_WEAPON_PROFICIENCY = "yes" }


	if self.classes and self.classes["Barbarian"] and f_barbarian[tid] == "yes" then return true end
	if self.classes and self.classes["Bard"] and f_bard[tid] == "yes" then return true end
	if self.classes and self.classes["Cleric"] and f_cleric[tid] == "yes" then return true end
	if self.classes and self.classes["Druid"] and f_druid[tid] == "yes" then return true end
	if self.classes and self.classes["Fighter"] and f_fighter[tid] == "yes" then return true end
	if self.classes and self.classes["Monk"] and f_monk[tid] == "yes" then return true end
	if self.classes and self.classes["Paladin"] and f_paladin[tid] == "yes" then return true end
	if self.classes and self.classes["Ranger"] and f_ranger[tid] == "yes" then return true end
	if self.classes and self.classes["Rogue"] and f_rogue[tid] == "yes" then return true end

	return false
end

--AC, Sebsebeleb & Zireael
function _M:getAC()
	local dex_bonus = (self:getDex()-10)/2
	--Splitting it up to avoid stuff like stacking rings of protection or bracers of armor + armor
--	local base = self.combat_base_ac or 10
	local armor = self.combat_armor_ac or 0
	local shield = self.combat_shield or 0
	local natural = self.combat_natural or 0
	local magic_armor = self.combat_magic_armor or 0
	local magic_shield = self.combat_magic_shield or 0
	local dodge = self.combat_dodge or 0
	local protection = self.combat_protection or 0
	local untyped = self.combat_untyped or 0

	if self.max_dex_bonus then dex_bonus = math.min(dex_bonus, self.max_dex_bonus) end 

	if self.combat_protection then protection = math.min(protection, 5) end
	
	return math.floor((10 + armor + magic_armor + shield + magic_shield + natural + protection + dodge) + (dex_bonus or 0))
end

--Saving throws, Sebsebeleb & Zireael
function _M:reflexSave(dc)
	local roll = rng.dice(1,20)
	local save = math.floor(self.level / 4) + (self:attr("reflex_save") or 0) + math.max((self:getStat("dex")-10)/2, (self:getStat("int")-10)/2)
	if not roll == 1 and roll == 20 or roll + save > dc then
		return true
	else
		return false
	end

	if self == game.player then
	local s = ("Reflex save: %d roll + bonus = %d versus DC %d"):format(
			roll, save, dc)--, success and "success" or "failure")
		game.log(s)
	end
end

function _M:fortitudeSave(dc)
	local roll = rng.dice(1,20)
	local save = math.floor(self.level / 4) + (self:attr("fortitude_save") or 0) + math.max((self:getStat("con")-10)/2, (self:getStat("str")-10)/2)
	if not roll == 1 and roll == 20 or roll + save > dc then
		return true
	else
		return false
	end

	if self == game.player then
	local s = ("Fortitude save: %d roll + bonus = %d versus DC %d"):format(
			roll, save, dc)--, success and "success" or "failure")
		game.log(s)
	end
end

function _M:willSave(dc)
	local roll = rng.dice(1,20)
	local save = math.floor(self.level / 4) + (self:attr("will_save") or 0) + math.max((self:getStat("wis")-10)/2, (self:getStat("cha")-10)/2)
	if not roll == 1 and roll == 20 or roll + save > dc then
		return true
	else
		return false
	end

	if self == game.player then
	local s = ("Will save: %d roll + bonus = %d versus DC %d"):format(
			roll, save, dc)--, success and "success" or "failure")
		game.log(s)
	end

end

function _M:saveRoll(DC, type)
	if type == "physical" then self:fortitudeSave(DC) end
	if type == "mental" then self:willSave(DC) end
end


--Metamagic & spellbook stuff, Sebsebeleb
function useMetamagic(self, t)
	local metaMod = {}
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		local tt = self:getTalentTypeFrom(t)
		if tt == "arcane/metamagic" and self:isTalentActive(t.id) then
			for i,v in ipairs(t.getMod(self, t)) do
				metaMod[i] = (metaMod[i] and metaMod[i] + v) or v
			end
		end
	end
	return metaMod
end 


--- The max charge worth you can have in a given spell level
function _M:getMaxMaxCharges(spell_list)
	local t = {}
	local l = self.level + 5
	while l > 5 do
		t[#t+1] = math.min(8, l)
		l = l - 3
	end
	return t
end

function _M:getMaxCharges(tid)
	if type(tid) == "table" then tid = tid.id end
	return self.max_charges[tid] or 0
end

function _M:getCharges(tid)
	if type(tid) == "table" then tid = tid.id end
	return self.charges[tid] or 0
end

function _M:incMaxCharges(tid, v, spell_list)
	local tt
	local t
	if type(tid) == "table" then
		t = tid
		tt = tid.type[1]
		tid = tid.id 
	else
		t = self:getTalentFromId(tid)
		tt = self:getTalentFromId(tid).type[1]
	end

	--Can the player have this many max charges for this type?
	local a = self:getAllocatedCharges(spell_list, t.level)
	if a + v > self:getMaxMaxCharges()[t.level] then return end
	self.max_charges[tid] = (self.max_charges[tid] or 0) + v
	self:incAllocatedCharges(spell_list, t.level, v)
end


--- Set the number of prepared instances of a certain spell
function _M:setMaxCharges(tid, spell_list, v)

	local t
	if type(tid) == "table" then
		t = tid
		tid = tid.id 
	else
		t = self:getTalentFromId(tid)
	end

	--Can the player have this many max charges for this type?
	local a = self:getAllocatedCharges(spell_list, tid.level)
	if a + v > self:getMaxMaxCharges()[tid.level] then return end
	self.max_charges[tid] = v
	self:setAllocatedCharges(spell_list, t.level, v)
end

--- Set the number of available instances of a certain spell
function _M:setCharges(tid, v)
	local t
	local id
	if type(tid) == "table" then 
		t = tid
		id = t.id
	else
		t = self:getTalentFromId(tid)
		id = tid
	end
	if t then t.charges = v end
	self.charges[id] = v
end

--- Increase the number of available instances of a certain spell
function _M:incCharges(tid, v)
	if type(tid) == "table" then tid = tid.id end
	local new = (self:getCharges(tid) or 0) + v
	self:setCharges(tid, new)
end

function _M:getAllocatedCharges(spell_list, level)
	local c = self.allocated_charges[spell_list]
	c = c and c[level]
	return c or 0
end

function _M:setAllocatedCharges(spell_list, level, value)
	if not self.allocated_charges[spell_list] then self.allocated_charges[spell_list] = {} end
	if not self.allocated_charges[spell_list][level] then self.allocated_charges[spell_list][level] = {} end
	self.allocated_charges[spell_list][level] = value
end

function _M:incAllocatedCharges(spell_list, level, value)
	local c = self:getAllocatedCharges(spell_list, level)
	local val = c and (c + value) or value
	self:setAllocatedCharges(spell_list, level, val)
end

function _M:allocatedChargesReset()
	for k, v in pairs(self.max_charges) do
		self.max_charges[k] = 0
	end
	for k, v in pairs(self.charges) do
		self.charges[k] = 0
	end
	for k,v in pairs(self.allocated_charges) do
		for level, value in pairs(self.allocated_charges[k]) do
			self.allocated_charges[k][level] = 0
		end
	end
end

function _M:levelPassives()
	for tid, _ in pairs(self.talents_def) do
		local t = self:getTalentFromId(tid)
		local tt = self:getTalentTypeFrom(t.type[1])
		if self:knowTalentType(t.type[1]) then
			if tt.passive then
				if self:canLearnTalent(t) then
					self:learnTalent(tid)
					game.log("You learned "..t.name)
				end
			end
		end
	end
end

--Random perks
function _M:randomFeat()
	local chance = rng.dice(1,26)
	
	if chance == 1 then self:learnTalent(self.T_DODGE, true)
	elseif chance == 2 then self:learnTalent(self.T_FINESSE, true)
	elseif chance == 3 then self:learnTalent(self.T_TOUGHNESS, true)
	elseif chance == 4 then self:learnTalent(self.T_ACROBATIC, true)
	elseif chance == 5 then self:learnTalent(self.T_AGILE, true)
	elseif chance == 6 then self:learnTalent(self.T_ALERTNESS, true)
	elseif chance == 7 then self:learnTalent(self.T_ANIMAL_AFFINITY, true)
	elseif chance == 8 then self:learnTalent(self.T_ARTIST, true)
	elseif chance == 9 then self:learnTalent(self.T_ATHLETIC, true)
	elseif chance == 10 then self:learnTalent(self.T_COMBAT_CASTING, true)
	elseif chance == 11 then self:learnTalent(self.T_DEFT_HANDS, true)
	elseif chance == 12 then self:learnTalent(self.T_INVESTIGATOR, true)
	elseif chance == 13 then self:learnTalent(self.T_MAGICAL_APTITUDE, true)
	elseif chance == 14 then self:learnTalent(self.T_MAGICAL_TALENT, true)
	elseif chance == 15 then self:learnTalent(self.T_NEGOTIATOR, true)
	elseif chance == 16 then self:learnTalent(self.T_NIMBLE_FINGERS, true)
	elseif chance == 17 then self:learnTalent(self.T_PERSUASIVE, true)
	elseif chance == 18 then self:learnTalent(self.T_SILVER_PALM, true)
	elseif chance == 19 then self:learnTalent(self.T_STEALTHY, true)
	elseif chance == 20 then self:learnTalent(self.T_THUG, true)
	elseif chance == 21 then self:learnTalent(self.T_TWO_WEAPON_FIGHTING, true)
	elseif chance == 22 then self:randomFocus()
	elseif chance == 23 then self:randomFocus()
	elseif chance == 24 then self:randomFavEnemy()
	elseif chance == 25 then self:randomFavEnemy()
		--[[Commented out due to the problems with on_pre_use
		if chance == 1 then self:learnTalent(self.T_POWER_ATTACK, true)]]
	
	else self:learnTalent(self.T_IRON_WILL, true) end

end

function _M:randomFocus()
	local chance = rng.dice(1,24)

	if chance == 1 then self:learnTalent(self.T_WEAPON_FOCUS_AXE, true)
	elseif chance == 2 then self:learnTalent(self.T_WEAPON_FOCUS_BATTLEAXE, true)
	elseif chance == 3 then self:learnTalent(self.T_WEAPON_FOCUS_BOW, true)
	elseif chance == 4 then self:learnTalent(self.T_WEAPON_FOCUS_CLUB, true)
	elseif chance == 5 then self:learnTalent(self.T_WEAPON_FOCUS_CROSSBOW, true)
	elseif chance == 6 then self:learnTalent(self.T_WEAPON_FOCUS_DAGGER, true)
	elseif chance == 7 then self:learnTalent(self.T_WEAPON_FOCUS_FALCHION, true)
	elseif chance == 8 then self:learnTalent(self.T_WEAPON_FOCUS_FLAIL, true)
	elseif chance == 9 then self:learnTalent(self.T_WEAPON_FOCUS_HALBERD, true)
	elseif chance == 10 then self:learnTalent(self.T_WEAPON_FOCUS_HAMMER, true)
	elseif chance == 11 then self:learnTalent(self.T_WEAPON_FOCUS_HANDAXE, true)
	elseif chance == 12 then self:learnTalent(self.T_WEAPON_FOCUS_JAVELIN, true)
	elseif chance == 13 then self:learnTalent(self.T_WEAPON_FOCUS_KUKRI, true)
	elseif chance == 14 then self:learnTalent(self.T_WEAPON_FOCUS_MACE, true)
	elseif chance == 15 then self:learnTalent(self.T_WEAPON_FOCUS_MORNINGSTAR, true)
	elseif chance == 16 then self:learnTalent(self.T_WEAPON_FOCUS_RAPIER, true)
	elseif chance == 17 then self:learnTalent(self.T_WEAPON_FOCUS_SCIMITAR, true)
	elseif chance == 18 then self:learnTalent(self.T_WEAPON_FOCUS_SCYTHE, true)
	elseif chance == 19 then self:learnTalent(self.T_WEAPON_FOCUS_SHORTSWORD, true)
	elseif chance == 20 then self:learnTalent(self.T_WEAPON_FOCUS_SPEAR, true)
	elseif chance == 21 then self:learnTalent(self.T_WEAPON_FOCUS_SLING, true)
	elseif chance == 22 then self:learnTalent(self.T_WEAPON_FOCUS_STAFF, true)
	elseif chance == 23 then self:learnTalent(self.T_WEAPON_FOCUS_SWORD, true)

	else self:learnTalent(self.T_WEAPON_FOCUS_TRIDENT, true) end

end

function _M:randomFavEnemy()
	local chance = rng.dice(1,30)

	if chance == 1 then self:learnTalent(self.T_FAVORED_ENEMY_ABERRATION, true)
	elseif chance == 2 then self:learnTalent(self.T_FAVORED_ENEMY_ANIMAL, true)
	elseif chance == 3 then self:learnTalent(self.T_FAVORED_ENEMY_CONSTRUCT, true)
	elseif chance == 4 then self:learnTalent(self.T_FAVORED_ENEMY_DRAGON, true)
	elseif chance == 5 then self:learnTalent(self.T_FAVORED_ENEMY_ELEMENTAL, true)
	elseif chance == 6 then self:learnTalent(self.T_FAVORED_ENEMY_FEY, true)
	elseif chance == 7 then self:learnTalent(self.T_FAVORED_ENEMY_GIANT, true)
	elseif chance == 8 then self:learnTalent(self.T_FAVORED_ENEMY_MAGBEAST, true)
	elseif chance == 9 then self:learnTalent(self.T_FAVORED_ENEMY_MONSTROUS_HUMANOID, true)
	elseif chance == 10 then self:learnTalent(self.T_FAVORED_ENEMY_OOZE, true)
	elseif chance == 11 then self:learnTalent(self.T_FAVORED_ENEMY_PLANT, true)
	elseif chance == 12 then self:learnTalent(self.T_FAVORED_ENEMY_UNDEAD, true)
	elseif chance == 13 then self:learnTalent(self.T_FAVORED_ENEMY_VERMIN, true)
	elseif chance == 14 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_DWARF, true)
	elseif chance == 15 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_GNOME, true)
	elseif chance == 16 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_DROW, true)
	elseif chance == 17 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_ELF, true)
	elseif chance == 18 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_HUMAN, true)
	elseif chance == 19 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_HALFLING, true)
	elseif chance == 20 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_PLANETOUCHED, true)
	elseif chance == 21 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_AQUATIC, true)
	elseif chance == 22 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_GOBLINOID, true)
	elseif chance == 23 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_REPTILIAN, true)
	elseif chance == 24 then self:learnTalent(self.T_FAVORED_ENEMY_HUMANOID_ORC, true)
	elseif chance == 25 then self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_AIR, true)
	elseif chance == 26 then self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_EARTH, true)
	elseif chance == 27 then self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_EVIL, true)
	elseif chance == 28 then self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_FIRE, true)
	elseif chance == 29 then self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_GOOD, true)

	else self:learnTalent(self.T_FAVORED_ENEMY_OUTSIDER_WATER, true) end

end

function _M:randomSpell()
	local chance = rng.dice(1,4)
	if chance == 1 then self:learnTalent(self.T_ACID_SPLASH_INNATE, true)
	elseif chance == 2 then self:learnTalent(self.T_GREASE_INNATE, true)
	elseif chance == 3 then self:learnTalent(self.T_HLW_INNATE, true)
	else self:learnTalent(self.T_CLW_INNATE, true) end
end	

function _M:randomItem()
	--Add a random ego-ed item
			
			local o = game.zone:makeEntity(game.level, "object", {name="iron battleaxe", ego_chance=1000}, nil, true)
			local inven = game.player:getInven("MAINHAND")
			if o then
				game.zone:addEntity(game.level, o, "object")
				self.player:addObject(inven, o)
			end

--[[			actor:wearObject(inven, o)
			if actor:wearObject(o, true, false) == false then
				actor:addObject(e.INVEN_INVEN, o)
			end]]
end


--Leveling up
function _M:levelup()
	engine.interface.ActorLevel.levelup(self)
	engine.interface.ActorTalents.resolveLevelTalents(self)

	--Gain max skill ranks (generic)
	self.max_skill_ranks = self.max_skill_ranks + 1
	
	--May level up class (player only)
	if self == game.player then self.class_points = self.class_points + 1 end

	if self.level % 3 == 0 then --feat points given every 3 levels. Classes may give additional feat points.
		self.feat_point = self.feat_point + 1
	end

	-- Auto levelup ?
	if self.autolevel then
		engine.Autolevel:autoLevel(self)
	end

	if game then game:registerDialog(require("mod.dialogs.LevelupDialog").new(self.player)) end

end

function _M:levelClass(name)
	local birther = require "engine.Birther"
	local d = birther:getBirthDescriptor("class", name)

	if not name then end

	local level = (self.classes[name] or 0) + 1
	self.classes[name] = level
	if self.class_points then
		self.class_points = self.class_points - 1
	end

	if level == 1 then --Apply the descriptor... or not?

	end

	self.last_class = name

	d.on_level(self, level)
end

function _M:giveLevels(name, n)
	if not name or not n then end
	
	while n > 0 do
	self:levelClass(name)
	n = n-1
	end
end

--Encumbrance & auto-ID stuff, Zireael
function _M:on_pickup_object(o)
--	self:checkEncumbrance()
	
end

--[[function _M:onAddObject(o)
	
end]]

function _M:onRemoveObject(o)
	self:checkEncumbrance()
end	

function _M:getMaxEncumbrance()
	local add = 0
	--Streamlined d20's encumbrance
	if self:getStr() <= 10 then return math.floor(10*self:getStr())
	else return math.ceil((10*self:getStr()) + (5*(self:getStr()-10))) end
end

function _M:getEncumbrance()
	local enc = 0

	local fct = function(so) enc = enc + so.encumber end

	-- Compute encumbrance
	for inven_id, inven in pairs(self.inven) do
		for item, o in ipairs(inven) do
				o:forAllStack(fct)
		end
	end
	
	--Limit logging to the player
	--[[if self == game.player then game.log(("#00FF00#Total encumbrance: %d"):format(enc)) end]]
	return math.floor(enc)
end

function _M:checkEncumbrance()
	-- Compute encumbrance
	local enc, max = self:getEncumbrance(), self:getMaxEncumbrance()	

	--Light load
	if enc < max * 0.33 and self:hasEffect(self.EFF_MEDIUM_LOAD) then 
		self:removeEffect(self.EFF_MEDIUM_LOAD, true)
	end

	--Heavy load
	if enc > max * 0.66 and self:knowTalent(self.T_LOADBEARER) and not self:hasEffect(self.EFF_MEDIUM_LOAD) then
	self:setEffect(self.EFF_MEDIUM_LOAD, 2, {}, true) 
	end
	
	if enc > max * 0.66 and not self:knowTalent(self.T_LOADBEARER) and not self:hasEffect(self.EFF_HEAVY_LOAD) then
		self:removeEffect(self.EFF_MEDIUM_LOAD, true)
		self:setEffect(self.EFF_HEAVY_LOAD, 2, {}, true)
	end
	
	--Medium load
	if enc > max * 0.33 and not self:knowTalent(self.T_LOADBEARER) and not self:hasEffect(self.EFF_MEDIUM_LOAD) then
		self:setEffect(self.EFF_MEDIUM_LOAD, 2, {}, true)
		if self:hasEffect(self.EFF_HEAVY_LOAD) then self:removeEffect(self.EFF_HEAVY_LOAD, true) end
	end
	
	-- We are pinned to the ground if we carry too much
	if not self.encumbered and enc > max then
		game.logPlayer(self, "#FF0000#You carry too much--you are encumbered!")
		game.logPlayer(self, "#FF0000#Drop some of your items.")
		self.encumbered = self:addTemporaryValue("never_move", 1)

	if self.x and self.y then
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "+ENCUMBERED!", {255,0,0}, true)
	end
	elseif self.encumbered and enc <= max then
		self:removeTemporaryValue("never_move", self.encumbered)
		self.encumbered = nil
		game.logPlayer(self, "#00FF00#You are no longer encumbered.")

		if self.x and self.y then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "-ENCUMBERED!", {255,0,0}, true)
		end
	end
end


function _M:computeGlobalSpeed()
	if self.speed < 0 then
		self.global_speed = 1/(1 - self.speed/10)
	elseif self.speed <= 26 then
		self.global_speed = 1 + self.speed/10
	elseif self.speed <= 34 then
	-- Everything from here down is an asymptotic approach to 500% speed,
	-- roughly mimicking ToME2's tables.c:extract_energy[] table.  Split
	-- out into cases, as there was no obvious function that suitably
	-- reproduced the table; this only gets called by the resolver, though
	-- (and when actor speed actually changes), so this shouldn't be too
	-- expensive.
		self.global_speed = 3.6 + (self.speed - 26)/20
	elseif self.speed <= 46 then
		self.global_speed = 4 + (self.speed - 34)/30
	elseif self.speed <= 50 then
		self.global_speed = 4.4 + (self.speed - 46)/40
	elseif self.speed <= 70 then
		self.global_speed = 4.5 + (self.speed - 50)/50
	else
		self.global_speed = 5 - 1/(self.speed - 60)
	end
end

local super_added = _M.added
function _M:added()
	super_added(self)
	if self.on_add then self:on_add() end
end

function _M:has(flag)
	return self.flags and self.flags[flag] or self:hasEffect(self['EFF_'..flag])
end
