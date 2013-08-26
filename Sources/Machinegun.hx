package;

import kha.Loader;
import kha.Sprite;

class Machinegun extends Sprite {
	public function new(x: Float, y: Float) {
		super(Loader.the.getImage("machinegun"), 10, 10);
		this.x = x;
		this.y = y;
	}
}