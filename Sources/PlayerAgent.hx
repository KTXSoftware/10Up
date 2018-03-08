package;

import kha2d.Animation;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha2d.Rectangle;
import kha2d.Scene;
import projectiles.PistolProjectile;

class PlayerAgent extends Player {
	private var graple: GrapleHook;
	private var grapleVec: Vector2;
	private var grapleHit: Vector2;
	private var grapleLength: Float;
	private var grapleBack = false;
	private var maxGrapleLength: Float = 550;
	private var pulling = false;
	
	public function new(x: Float, y: Float) {
		super(x, y - 2, "agent", Std.int(410 / 10) * 2, Std.int(455 / 7) * 2);
		Player.setPlayer(0, this);
		graple = new GrapleHook();
		grapleVec = null;
		grapleLength = 0;
		//Scene.the.addHero(graple);
		
		collider = new Rectangle(20, 30, 41 * 2 - 40, (65 - 1) * 2 - 30);
		walkLeft = Animation.createRange(11, 18, 4);
		walkRight = Animation.createRange(1, 8, 4);
		standLeft = Animation.create(10);
		standRight = Animation.create(0);
		jumpLeft = Animation.create(31);
		jumpRight = Animation.create(30);
	}
	
	override public function leftButton(): String {
		return "Shoot";
	}
	
	override public function rightButton(): String {
		return "Grapple";
	}
	
	var lastFired : Float = 0;
	
	override public function prepareSpecialAbilityA(gameTime:Float) : Void {
		isCrosshairVisible = true;
	}
	
	/**
	  Pistole
	**/
	override public function useSpecialAbilityA(gameTime : Float) : Void {
		if (lastFired + 0.2 < gameTime) {
			var projectile = new PistolProjectile( crosshair, 5, 5, this.z);
			projectile.x = muzzlePoint.x + (0.8 * projectile.width * crosshair.x);
			projectile.y = muzzlePoint.y + (0.8 * projectile.height * crosshair.y);
			Scene.the.addProjectile( projectile );
			lastFired = gameTime;
		}
		isCrosshairVisible = false;
	}
	
	/**
	  Haken
	**/
	override public function prepareSpecialAbilityB(gameTime:Float) : Void {
		isCrosshairVisible = true;
	}
	
	override public function useSpecialAbilityB(gameTime : Float) : Void {
		// TODO: Fixme!
		grapleVec = new Vector2(crosshair.x, crosshair.y);
		grapleBack = false;
		grapleLength = 0;
		grapleHit = null;
	}
	
	override public function update() {
		super.update();
		var c = center;
		graple.x = c.x - 0.5 * graple.width;
		//graple.x = x + 10;
		graple.y = c.y - 0.5 * graple.height + 5;
		graple.angle = Math.atan2(crosshair.y, crosshair.x);
		if (lookRight) {
			graple.setAnimation( graple.rightAnim );
		} else {
			graple.setAnimation( graple.leftAnim );
			graple.angle = graple.angle + Math.PI;
		}
		
		if (grapleVec != null) {
			if (pulling) {
				x += grapleVec.x * 10;
				y += grapleVec.y * 10;
				grapleVec = grapleHit.sub(center);
				grapleLength = grapleVec.length;
				grapleVec.length = 1.0;
				if (grapleLength < 30 || Scene.the.collidesSprite(this)) {
					x -= grapleVec.x * 10;
					y -= grapleVec.y * 10;
					grapleLength = 0;
					grapleVec = null;
					grapleHit = null;
					pulling = false;
					grapleHit = null;
					accy = 0.2;
					speedy = -12;
				}
			}
			else {
				if (grapleBack) {
					grapleLength -= 20;
					if (grapleLength < 0) {
						grapleLength = 0;
						grapleBack = false;
						grapleVec = null;
						grapleHit = null;
					}
				}
				else {
					grapleLength += 20;
					if (grapleLength > maxGrapleLength) {
						grapleLength -= (grapleLength - maxGrapleLength);
						grapleBack = true;
					}
					var hitCheck = new Vector2(hookX(), hookY());
					if (Scene.the.collidesPoint(hitCheck)) {
						grapleHit = hitCheck;
						grapleBack = false;
						pulling = true;
						accy = 0;
						speedy = 0;
					}
				}
			}
		}
	}
	
	private function hookX(): Float {
		if (grapleHit != null) {
			return grapleHit.x;
		}
		return muzzlePoint.x + grapleVec.x * grapleLength;
	}
	
	private function hookY(): Float {
		if (grapleHit != null) {
			return grapleHit.y;
		}
		return muzzlePoint.y + grapleVec.y * grapleLength;
	}
	
	override public function render(g: Graphics): Void {
		super.render(g);
		graple.render(g);
		if (grapleVec != null) {
			g.color = Color.Black;
			var c = center;
			g.drawLine(c.x + 10 * grapleVec.x, c.y - 10 * grapleVec.y, hookX(), hookY(), 2.0);
		}
	}
}
