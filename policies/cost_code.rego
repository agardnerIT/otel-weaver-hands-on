package live_check_advice

import rego.v1

deny contains make_finding(id, level, context, message) if {
	input.sample.attribute
	input.sample.attribute.name == "acme.cost.code"
	is_string(input.sample.attribute.value)
	not regex.match(`^[A-Z]{3}[0-9]{4}$`, input.sample.attribute.value)
	id := "invalid_cost_code"
	level := "violation"
	context := {"attribute_name": input.sample.attribute.name}
	message := sprintf("acme.cost.code value '%s' does not match ^[A-Z]{3}[0-9]{4}$", [input.sample.attribute.value])
}

make_finding(id, level, context, message) := {
	"id": id,
	"level": level,
	"context": context,
	"message": message,
}
