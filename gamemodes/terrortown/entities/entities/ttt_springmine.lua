if SERVER then
	AddCSLuaFile()

	resource.AddFile("sound/springmine/boing.wav")
	resource.AddFile("materials/vgui/ttt/icon_springmine.png")
end

ENT.PrintName = "name_springmine"
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

	if SERVER then
		timer.Simple(0, function()
			if not IsValid(self) then return end

			markerVision.RegisterEntity(self, self:GetOwner(), VISIBLE_FOR_TEAM)
		end)
	end
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
		self:TakePhysicsDamage(dmginfo)
		self:SetHealth(self:Health() - dmginfo:GetDamage())

		if self:Health() <= 0 then
			self:Remove()

			local effect = EffectData()
			effect:SetOrigin(self:GetPos())

			util.Effect("cball_explode", effect)
			sound.Play(soundZap, self:GetPos())

			if IsValid(self:GetOwner()) then
				LANG.Msg(self:GetOwner(), "msg_springmine_destroyed", nil, MSG_MSTACK_WARN)
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

		markerVision.RemoveEntity(self)

		self:Remove()
	end
end

if CLIENT then
	local TryT = LANG.TryTranslation
	local ParT = LANG.GetParamTranslation

	local materialSpringmine = Material("vgui/ttt/marker_vision/springmine")

	-- handle looking at C4
	hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDSpringmine", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()

		if not client:IsTerror() or not IsValid(ent) or tData:GetEntityDistance() > 100 or ent:GetClass() ~= "ttt_springmine"
			or client:GetTeam() ~= ent:GetOwner():GetTeam()
		then return end

		-- enable targetID rendering
		tData:EnableText()
		tData:EnableOutline()
		tData:SetOutlineColor(client:GetRoleColor())

		tData:SetTitle(TryT(ent.PrintName))
		tData:AddIcon(materialSpringmine)
	end)

	hook.Add("TTT2RenderMarkerVisionInfo", "HUDDrawMarkerVisionSpringMine", function(mvData)
		local client = LocalPlayer()
		local ent = mvData:GetEntity()

		if not client:IsTerror() or not IsValid(ent) or ent:GetClass() ~= "ttt_springmine" then return end

		local owner = ent:GetOwner()
		local nick = IsValid(owner) and owner:Nick() or "---"

		local distance = math.Round(util.HammerUnitsToMeters(mvData:GetEntityDistance()), 1)

		mvData:EnableText()

		mvData:AddIcon(materialSpringmine)
		mvData:SetTitle(TryT(ent.PrintName))

		mvData:AddDescriptionLine(ParT("marker_vision_owner", {owner = nick}))
		mvData:AddDescriptionLine(ParT("marker_vision_distance", {distance = distance}))

		mvData:AddDescriptionLine(TryT("marker_vision_visible_for_" .. markerVision.GetVisibleFor(ent)), COLOR_SLATEGRAY)
	end)
end
