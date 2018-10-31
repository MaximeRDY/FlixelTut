package;

import flixel.FlxG;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxState;

class PlayState extends FlxState {
	var _player:Player;
	var _map:TiledMap;
	var _mWalls:FlxTilemap;

	override public function create():Void {
		_map = new TiledMap(AssetPaths.map__tmx);
		_mWalls = new FlxTilemap();
		_mWalls.loadMapFromArray(cast(_map.getLayer("walls"), flixel.addons.editors.tiled.TiledTileLayer).tileArray, _map.width, _map.height,
			AssetPaths.tiles__png, _map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 3);
		_mWalls.follow();
		_mWalls.setTileProperties(2, FlxObject.NONE);
		_mWalls.setTileProperties(3, FlxObject.ANY);
		add(_mWalls);

		_player = new Player(20, 20);
		var tmpMap:TiledObjectLayer = cast _map.getLayer("entities");
		FlxG.watch.add(_player, "x");
		FlxG.watch.add(_player, "y");
		for (e in tmpMap.objects) {
			placeEntities(e.type, e.xmlData.x);
		}
		add(_player);

		FlxG.camera.follow(_player, TOPDOWN, 1);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		FlxG.collide(_player, _mWalls);
		super.update(elapsed);
	}

	function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player") {
			_player.x = x;
			_player.y = y;
		}
	}
}
