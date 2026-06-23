extends MultiMeshInstance3D

@export var grass_count := 70

func _ready():
	multimesh.instance_count = grass_count

	for i in grass_count:
		var transformar := Transform3D()

		transformar.origin = Vector3(
			randf_range(-0.45, 0.45),
			0.5,
			randf_range(-0.45, 0.45)
		)

		transformar.basis = transformar.basis.rotated(
			Vector3.UP,
			randf() * TAU
		)

		var scale_factor = randf_range(0.4, 0.8)

		transformar.basis = transformar.basis.scaled(
			Vector3.ONE * scale_factor
		)

		multimesh.set_instance_transform(i, transformar)
