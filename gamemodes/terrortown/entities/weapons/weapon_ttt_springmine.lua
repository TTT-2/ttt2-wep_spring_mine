if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName = "name_springmine"
	SWEP.Slot = 6

	SWEP.ViewModelFOV = 10

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "desc_springmine"
	}

	SWEP.Icon = "VGUI/ttt/icon_springmine.png"
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "slam"

local ammo = 3

SWEP.Primary.ClipSize = ammo
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "slam"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.0

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false

SWEP.UseHands = true
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

SWEP.AllowDrop = false

SWEP.NoSights = true

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:MineDrop()
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:MineDrop()
end

local throwsound = Sound("Weapon_SLAM.SatchelThrow")

function SWEP:MineDrop()
	if SERVER then
		local ply = self:GetOwner()

		if not IsValid(ply) then return end

		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()

		local vthrow = vvel + vang * 200

		local mine = ents.Create("ttt_springmine")

		if IsValid(mine) then
			mine:SetPos(vsrc + vang * 10)
			mine:Spawn()
			mine:SetOwner(ply)
			mine:PhysWake()

			local phys = mine:GetPhysicsObject()

			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end

			self:TakePrimaryAmmo(1)

			if not self:CanPrimaryAttack() then
				self:Remove()
			end
		end
	end

	self:EmitSound(throwsound)
end

function SWEP:WasBought(buyer)
	self:SetClip1(ammo)
end

function SWEP:Reload()
	return false
end

if CLIENT then
	function SWEP:OnRemove()
		if not IsValid(self:GetOwner()) or self:GetOwner() ~= LocalPlayer() or not self:GetOwner():IsTerror() then return end

		RunConsoleCommand("lastinv")
	end

	function SWEP:Initialize()
		self:AddTTT2HUDHelp("springmine_help_pri")

		self:AddCustomViewModel("vmodel", {
			type = "Model",
			model = "models/props_phx/smallwheel.mdl",
			bone = "ValveBiped.Bip01_R_Finger2",
			rel = "",
			pos = Vector(1.557, 4.9, 0),
			angle = Angle(120, 0, 20),
			size = Vector(0.55, 0.55, 0.55),
			color = Color(50, 50, 50, 255),
			surpresslightning = false,
			material = "models/debug/debugwhite",
			skin = 0,
			bodygroup = {}
		})

		self:AddCustomWorldModel("wmodel", {
			type = "Model",
			model = "models/props_phx/smallwheel.mdl",
			bone = "ValveBiped.Bip01_R_Hand",
			rel = "",
			pos = Vector(5, 6, 0),
			angle = Angle(120, 20, 0),
			size = Vector(0.625, 0.625, 0.625),
			color = Color(50, 50, 50, 255),
			surpresslightning = false,
			material = "models/debug/debugwhite",
			skin = 0,
			bodygroup = {}
		})

		self:ApplyViewModelBoneMods("v_weapon.c4", {
			scale = Vector(0.009, 0.009, 0.009),
			pos = Vector(0, 0, 0),
			angle = Angle(0, 0, 0)
		})

		self.BaseClass.Initialize(self)
	end
end
