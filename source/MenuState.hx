package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState {
	var _btnPlay:FlxButton;
	var _txtTitle:FlxText;
	var _btnOptions:FlxButton;

	override public function create():Void {
		FlxG.debugger.visible = true;
		FlxG.debugger.drawDebug = true;
		FlxG.log.redirectTraces = true;

		_txtTitle = new FlxText(20, 0, 0, "HaxeFlixel\nTutorial\nGame", 22);
		_txtTitle.alignment = CENTER;
		_txtTitle.screenCenter(X);
		add(_txtTitle);

		_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
		_btnPlay.x = (FlxG.width / 2) - _btnPlay.width - 10;
		_btnPlay.y = FlxG.height - _btnPlay.height - 10;
		add(_btnPlay);

		_btnOptions = new FlxButton(0, 0, "Options", clickOptions);
		_btnOptions.x = (FlxG.width / 2) + 10;
		_btnOptions.y = FlxG.height - _btnOptions.height - 10;
		add(_btnOptions);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function clickPlay():Void {
		FlxG.switchState(new PlayState());
	}

	function clickOptions():Void {
		FlxG.switchState(new OptionsState());
	}
}
