class_name ItemData
extends Resource

@export var itemName : String
@export var description : String
@export var icon : Texture2D
@export var effectValue : float 
@export var maxCharge : float = 200
@export var currentCharge : float = 200

enum CrystalTypes {General, Red, Green, Blue}
@export var crystalType : CrystalTypes

enum EffectTypes {RotationSpeed, Angle, Energy, DamageMult, WalkSpeed, DamageReduct, LightRange, SourceRadius, SlowEnemy, IncreaseAOE, IncreaseCharge, SlowerDrain, aoeDamage, HealOverTime, RechargeAllCrsyatls,DoubleALLDamage, EnergyAngleMinusRange}
@export var effectType : EffectTypes



func getCurrentCharge()-> float:
	return currentCharge / maxCharge

func hasCharge() -> bool:
	if currentCharge < 0.01:
		return false
	return true
