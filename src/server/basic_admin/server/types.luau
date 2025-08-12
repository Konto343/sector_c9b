--!strict

local module = {}

export type humanoid = Humanoid & {
	['Animator'] : Animator
}

export type humanoidrootpart = BasePart & {
	['RootAttachment'] : Attachment,
	['RootJoint'] : Motor6D
}

export type char_r6 = Model & {
	['Humanoid'] : humanoid,
	['Animate'] : LocalScript,
	['Health'] : Script,
	['Body Colors'] : BodyColors,
	['Shirt Graphic'] : ShirtGraphic,
	['HumanoidRootPart'] : humanoidrootpart,
	
	['Head'] : BasePart,
	['Left Arm'] : BasePart,
	['Right Arm'] : BasePart,
	['Left Arm'] : BasePart,
	['Left Leg'] : BasePart,
	['Torso'] : BasePart
}

export type char_r15 = Model & {
	['Humanoid'] : humanoid,
	['Animate'] : LocalScript,
	['Health'] : Script,
	['Body Colors'] : BodyColors,
	['Shirt Graphic'] : ShirtGraphic,
	['HumanoidRootPart'] : humanoidrootpart,

	['LeftLowerArm'] : MeshPart,
	['RightUpperLeg'] : MeshPart,
	['LeftUpperLeg'] : MeshPart,
	['UpperTorso'] : MeshPart,
	['LeftLowerLeg'] : MeshPart,
	['RightUpperArm'] : MeshPart,
	['LeftUpperArm'] : MeshPart,
	['LeftFoot'] : MeshPart,
	['LowerTorso'] : MeshPart,
	['RightLowerLeg'] : MeshPart,
	['RightFoot'] : MeshPart,
	['RightLowerArm'] : MeshPart,
	['RightHand'] : MeshPart,
	['Head'] : MeshPart,
	['LeftHand'] : MeshPart
}

export type player = Player & {
	Character : char_r6,
	CharacterAdded : (RBXScriptSignal) -> char_r6
}

return module
