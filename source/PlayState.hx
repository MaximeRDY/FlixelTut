package;

import flixel.util.FlxColor;
import flixel.system.debug.log.LogStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxState;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	var _player:Player;
	var _map:TiledMap;
	var _mWalls:FlxTilemap;
	var _grpCoins:FlxTypedGroup<Coin>;
	var _grpEnemies:FlxTypedGroup<Enemy>;
	var _hud:HUD;
	var _money:Int = 0;
	var _health:Int = 3;
	var _inCombat:Bool = false;
	var _combatHud:CombatHUD;
	var _ending:Bool;
	var _won:Bool;

	override public function create():Void {
		_map = new TiledMap(AssetPaths.map__tmx);

		_mWalls = new FlxTilemap();
		_mWalls.loadMapFromArray(cast(_map.getLayer("walls"), flixel.addons.editors.tiled.TiledTileLayer).tileArray, _map.width, _map.height,
			AssetPaths.tiles__png, _map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 3);
		_mWalls.follow();
		_mWalls.setTileProperties(2, FlxObject.NONE);
		_mWalls.setTileProperties(3, FlxObject.ANY);
		add(_mWalls);

		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);

		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);

		_player = new Player(20, 20);
		var tmpMap:TiledObjectLayer = cast _map.getLayer("entities");
		FlxG.watch.add(_player, "x");
		FlxG.watch.add(_player, "y");
		for (e in tmpMap.objects) {
			placeEntities(e.type, e.xmlData.x);
		}
		add(_player);

		FlxG.camera.follow(_player, TOPDOWN, 1);

		_hud = new HUD();
		add(_hud);

		_combatHud = new CombatHUD();
		add(_combatHud);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		if (!_inCombat) {
			FlxG.collide(_player, _mWalls);
			FlxG.overlap(_player, _grpCoins, playerTouchCoin);
			FlxG.collide(_grpEnemies, _mWalls);
			_grpEnemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		} else {
			if (!_combatHud.visible) {
				_health = _combatHud.playerHealth;
				_hud.updateHUD(_health, _money);
				if (_combatHud.outcome == DEFEAT) {
					_ending = true;
					FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
				} else {
					if (_combatHud.outcome == VICTORY) {
						_combatHud.e.kill();
						if (_combatHud.e.etype == 1) {
							_won = true;
							_ending = true;
							FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
						}
					} else {
						_combatHud.e.flicker();
					}
					_inCombat = false;
					_player.active = true;
					_grpEnemies.active = true;
				}
			}
		}
		super.update(elapsed);
		if (_ending)
			return;
	}

	function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player") {
			_player.x = x;
			_player.y = y;
		} else if (entityName == "coin") {
			_grpCoins.add(new Coin(x + 4, y + 4));
		} else if (entityName == "enemy") {
			_grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(getProperty(entityData, "etype"))));
		}
	}

	function getProperty(xml:Xml, propertyName:String):String {
		for (property in xml.elementsNamed("properties").next().elementsNamed('property')) {
			if (property.get('name') == 'etype') {
				return property.get('value');
			}
		}
		return "null";
	}

	function checkEnemyVision(e:Enemy):Void {
		if (_mWalls.ray(e.getMidpoint(), _player.getMidpoint())) {
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		} else
			e.seesPlayer = false;
	}

	function playerTouchCoin(player:Player, coin:Coin):Void {
		if (player.alive && player.exists && coin.alive && coin.exists) {
			_money++;
			_hud.updateHUD(_health, _money);
			coin.kill();
		}
	}

	function playerTouchEnemy(P:Player, E:Enemy):Void {
		if (P.alive && P.exists && E.alive && E.exists && !E.isFlickering()) {
			startCombat(E);
		}
	}

	function startCombat(E:Enemy):Void {
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHud.initCombat(_health, E);
	}

	function doneFadeOut():Void {
		FlxG.switchState(new GameOverState(_won, _money));
	}
}
