extends Node

var currentLantern: Lantern

func register(lantern : Lantern):
	currentLantern = lantern

func isInCone(targetPosition : Vector3) -> bool:
	#to check if something is in the cone, we need to check if it is both in the Range of the cone, and the angle 
	#this is chekcing, if the target distance further than the light can reach, return false 
	var distance = currentLantern.cone.global_position.distance_to(targetPosition)
	var distanceTolerance = 1.2
	if distance > (currentLantern.lightRange + distanceTolerance):
		return false 
	#basis is oreintaton of xyz. -z represents "forward" , so this next line just returns which way forward is 
	var lanternForward = -currentLantern.cone.global_basis.z
	#this gets a vector that points from the lantern to the target by subtracticing postion between them. normalzied serves to only take the direction value from that calc
	var directionToTarget = (targetPosition - currentLantern.global_position).normalized()
	#dot is used to compare the angle between two vectors. when "dotting" two normalized vectors you get a number bwteen -1 and 1. 1 means they are pointed the same direction
	#0 means they are perpendicular, -1 means opposite directions
	# so if target is directly infront of the lantern, dont will be close to 1, the further off to the side form the direction of the lantern, the smaller the number
	var dot = lanternForward.dot(directionToTarget)
	#this converts the cone angle into a dot value to compare with dot. cos == cos(0deg) = 1(straight ahead), cos(90) = perpedicualr
	#so if cone is at 20 degrees, cos(20)=0.94. that means that the target needs a dot product oif at least 0.94 to be insaide the cone, basically almost striagth ahead 
	var threshold = cos(deg_to_rad(currentLantern.angle))
	var angleTolerance = 0.3
	if dot < (threshold - angleTolerance):
		return false
	return true


func isInOmniLight(targetPosition: Vector3) -> bool:
	var distance = currentLantern.omni_light_3d.global_position.distance_to(targetPosition)
	if distance <= currentLantern.omni_light_3d.omni_range:
		return true
	return false


func getCurrentColor() -> Color:
	return currentLantern.currentColor
