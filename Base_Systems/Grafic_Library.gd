extends Node

var room
var funiture
var activ_funiture
var wall
var ware
var ui

func _init():
	
	var list = {}	
	list["Empty"] = load("res://Base_Systems/Images/Räume/Unbenutzt_Tile.jpg")
	list["Storage"] = load("res://Base_Systems/Images/Räume/Lager_Tile.jpg")
	list["Smithy"] = load("res://Base_Systems/Images/Räume/Schmiede_Tile.jpg")
	list["Lab"] = load("res://Base_Systems/Images/Räume/Labor_Tile.jpg")
	list["Salesroom"] = load("res://Base_Systems/Images/Räume/Verkaufsraum_Tile.jpg")
	room = list
	
	list = {}
	list["Chest"] = load("res://Base_Systems/Images/Funitur/Chest.png")
	list["Shelf"] = load("res://Base_Systems/Images/Funitur/Shelf.png")
	list["Smithy_Workstation"] = load("res://Base_Systems/Images/Funitur/Smithy_Workplace.png")
	list["Prepairforge"] = load("res://Base_Systems/Images/Funitur/Prepairforge.png")
	list["Shop_Table"] = load("res://Base_Systems/Images/Funitur/Shop_Table.png")
	funiture = list
	
	list = {}
	list["Chest"] = load("res://Base_Systems/Images/Funitur/Chest.png")
	list["Shelf"] = load("res://Base_Systems/Images/Funitur/Shelf.png")
	list["Smithy_Workstation"] = load("res://Base_Systems/Images/Funitur/Smithy_Workplace.png")
	list["Prepairforge"] = load("res://Base_Systems/Images/Funitur/Prepairforge.png")
	list["Shop_Table"] = load("res://Base_Systems/Images/Activ_Funiture/Shop_Table_Activ.png")
	activ_funiture = list
	
	list = {}
	list["T_Up"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_T_Up.jpg")
	list["T_Down"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_T_Down.jpg")
	list["T_Left"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_T_Left.jpg")
	list["T_Right"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_T_Right.jpg")
	list["Corner_Up"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Corner_Up.jpg")
	list["Corner_Down"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Corner_Down.jpg")
	list["Corner_Left"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Corner_Left.jpg")
	list["Corner_Right"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Corner_Right.jpg")
	list["End_Up"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Up_End.jpg")
	list["End_Down"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Down_End.jpg")
	list["End_Left"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Left_End.jpg")
	list["End_Right"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Right_End.jpg")
	list["Horizontal"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Horizontal.jpg")
	list["Vertical"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Vertical.jpg")
	list["Path_Horizontal"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Horizontal_Path.jpg")
	list["Path_Vertical"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Vertical_Path.jpg")
	list["Pillar"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Pillar.jpg")
	list["Cross"] = load("res://Base_Systems/Images/Funitur/Wall/Wall_Cross.jpg")
	wall = list
	
	list = {}
	list["Copper"] = load("res://Base_Systems/Images/Metalle/Kupfer.png")
	list["Iron"] = load("res://Base_Systems/Images/Metalle/Eisen.PNG")
	list["Chainlink"] = load("res://Base_Systems/Images/Schmiede_Halbfabrikat/Kettenglied.PNG")
	list["Ironhelmet"] = load("res://Base_Systems/Images/Schmiede_Ware/Eisenhelm.png")
	list["Chainmail"] = load("res://Base_Systems/Images/Schmiede_Ware/Kettenhemd.png")
	ware = list
	
	list = {}
	
	list["Highlight"] = load("res://Shop_Screen/Shop_Tile/imgs/shop_tile_marking.png")
	
	ui = list
