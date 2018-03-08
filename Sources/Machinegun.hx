package;

import kha.audio1.Audio;
import kha.Assets;
import kha.Sound;
import kha2d.Sprite;

class Machinegun extends Sprite {
	private var sound: Sound;
	
	public function new(x: Float, y: Float) {
		super(Assets.images.machinegun, 42 * 2, 41 * 2);
		this.x = x;
		this.y = y;
		sound = Assets.sounds.machineshot;
	}
	
	override public function update(): Void {
		super.update();
		var player: Player = null;
		if (Level.the.gates[0].isOpen()) {
			for (i in 0...4) {
				var p = Player.getPlayer(i);
				if (p.isSleeping()) {
					continue;
				} if (player == null || p.x > player.x) {
					if (p.y > y - 30 && p.y < y + height) {
						if (p.x > Level.the.cars[0].x + Level.the.cars[0].width) {
							player = p;
						}
					}
				}
			}
		}
		if (player != null) {
			player.health -= 1;
			Audio.play(sound);
		}
	}
}
