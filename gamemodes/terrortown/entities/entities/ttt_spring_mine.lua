if SERVER then
	AddCSLuaFile()

	resource.AddFile("sound/springmine/boing.wav")
	resource.AddFile("materials/vgui/ttt/icon_springmine.png")
end

ENT.Icon = "vgui/ttt/icon_springmine.png"
ENT.Type = "anim"
ENT.Projectile = true
ENT.CanHavePrints = true

ENT.WarningSound = Sound("weapons/boing.wav")

ENT.Height = 1000

ENT.Model = Model("models/props_phx/smallwheel.mdl")
ENT.Color = Color(50, 50, 50, 255)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMaterial("models/debug/debugwhite")
	self:SetColor(self.Color)

	self:PhysicsInit(SOLID_VPHYSICS)

	timer.Simple(1, function()
		if not IsValid(self) then return end

		self:SetSolidFlags(FSOLID_TRIGGER)
	end)

	self:SetHealth(50)

	return self.BaseClass.Initialize(self)
end

function ENT:StartTouch(ent)
	if ent:IsValid() and ent:IsPlayer() then
		self:Boing(ent)
	end
end

if SERVER then
	local soundZap = Sound("npc/assassin/ball_zap1.wav")
	local soundBoing = Sound("springmine/boing.wav")

	function ENT:OnTakeDamage(dmginfo)
	   if dmginfo:GetAttacker() == self:GetOwner() then return end

	   self:TakePhysicsDamage(dmginfo)
	   self:SetHealth(self:Health() - dmginfo:GetDamage())

	   if self:Health() <= 0 then
		  self:Remove()

		  local effect = EffectData()
		  effect:SetOrigin(self:GetPos())

		  util.Effect("cball_explode", effect)
		  sound.Play(soundZap, self:GetPos())

		  if IsValid(self:GetOwner()) then
			 TraitorMsg(self:GetOwner(), "YOUR SPRINGMINE HAS BEEN DESTROYED!")
		  end
	   end
	end

	function ENT:Boing(ply)
		self:EmitSound(soundBoing, 100)

		if not self:IsValid() then return end

		local velPly = ply:GetVelocity()

		ply:SetVelocity(Vector(velPly.x * 2, velPly.y * 2, self.Height))
		ply.was_pushed = {
			att = self:GetOwner(),
			t = CurTime(),
			infl = self
		}

		self:Remove()
	end
end
