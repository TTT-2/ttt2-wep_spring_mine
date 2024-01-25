
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

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/props/cs_office/microwave.mdl"

SWEP.HoldType = "normal"

local ammo = 3

SWEP.DrawCrosshair = false
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
SWEP.WeaponID = AMMO_JUMPMINE

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

		local mine = ents.Create("ttt_spring_mine")

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
	function SWEP:Initialize()
		LANG.AddToLanguage("english", "springmine_help", "Press {primaryfire} to deploy the Spring Mine.")
		self:AddHUDHelp("springmine_help", nil, true)

		return self.BaseClass.Initialize(self)
	end

	function SWEP:OnRemove()
		if not IsValid(self:GetOwner()) or self:GetOwner() ~= LocalPlayer() or not self:GetOwner():IsTerror() then return end

		RunConsoleCommand("lastinv")
	end
end
