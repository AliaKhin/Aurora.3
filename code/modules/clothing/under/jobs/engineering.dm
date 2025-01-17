//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/chief_engineer
	name = "chief engineer's jumpsuit"
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief Engineer\". It has minor radiation shielding."
	icon = 'icons/obj/contained_items/department_uniforms/command.dmi'
	icon_state = "chief_engineer"
	item_state = "chief_engineer"
	contained_sprite = TRUE
	armor = list(
		rad = ARMOR_RAD_MINOR
	)
	siemens_coefficient = 0.75

/obj/item/clothing/under/rank/atmospheric_technician
	name = "atmospheric technician's jumpsuit"
	desc = "It's a jumpsuit worn by atmospheric technicians."
	icon_state = "atmos"
	item_state = "atmos_suit"
	worn_state = "atmos"
	siemens_coefficient = 0.75

/obj/item/clothing/under/rank/atmospheric_technician/heph
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "heph_atmos"
	item_state = "heph_atmos"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/atmospheric_technician/zavod
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "zav_atmos"
	item_state = "zav_atmos"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/engineer
	name = "engineer's jumpsuit"
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	icon_state = "engine"
	item_state = "engi_suit"
	worn_state = "engine"
	armor = list(
		rad = ARMOR_RAD_MINOR
	)
	siemens_coefficient = 0.75

/obj/item/clothing/under/rank/engineer/heph
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "heph_engineer"
	item_state = "heph_engineer"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/engineer/zavod
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "zav_engineer"
	item_state = "zav_engineer"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/engineer/apprentice
	name = "engineering apprentice's jumpsuit"
	desc = "It's a noticeably cheaper high visibility jumpsuit worn by engineering apprentices. It has minor radiation shielding."
	icon_state = "engine_app"
	worn_state = "engine_app"

/obj/item/clothing/under/rank/engineer/apprentice/heph
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "heph_apprentice"
	item_state = "heph_apprentice"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/engineer/apprentice/zavod
	icon = 'icons/obj/contained_items/department_uniforms/engineering.dmi'
	icon_state = "zav_apprentice"
	item_state = "zav_apprentice"
	contained_sprite = TRUE

/obj/item/clothing/under/rank/roboticist
	name = "roboticist's jumpsuit"
	desc = "It's a white and purple jumpsuit with reinforced seams; great for industrial work."
	icon_state = "robotics"
	item_state = "bl_suit"
	worn_state = "robotics"
	siemens_coefficient = 0.75
