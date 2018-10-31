package;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState {
	var _btnPlay:FlxButton;

	override public function create():Void {
		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.log.redirectTraces = true;
		_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
		_btnPlay.screenCenter();
		add(_btnPlay);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function clickPlay():Void {
		FlxG.switchState(new PlayState());
	}
}
