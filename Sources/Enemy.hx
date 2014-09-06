package;

import kha.Animation;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Loader;
import kha.math.Random;
import kha.math.Vector2;
import kha.Rectangle;
import kha.Rotation;
import kha.Sound;
import kha.Sprite;
import projectiles.PistolProjectile;

class Enemy extends DestructibleSprite {
	private var killed: Bool;
	private var walkLeft: Animation;
	private var walkRight: Animation;
	private var standLeft: Animation;
	private var standRight: Animation;
	private var distances: Array<Float>;
	private var focus: Player = null;
	private var nextShootTime: Float = 0;
	private var lookRight: Bool = true;
	private var watchRect : Rectangle;
	private var hitSound: Sound;
	
	public function new(x: Float, y: Float) {
		super(50, Loader.the.getImage("soldier"), Std.int(410 / 10) * 2, Std.int(455 / 7) * 2);
		killed = false;
		this.x = x;
		this.y = y;
		walkLeft = Animation.createRange(30, 33, 8);
		walkRight = Animation.createRange(20, 23, 8);
		standLeft = Animation.create(10);
		standRight = Animation.create(0);
		setAnimation(walkRight);
		speedx = 0;
		hitSound = Loader.the.getSound("hit");
		distances = new Array<Float>();
		collider = new Rectangle(20, 30, 41 * 2 - 40, (65 - 1) * 2 - 30);
		watchRect = new Rectangle(x, y - 75, 300, 150);
	}
	
	override private function set_health(value:Int):Int {
		if ( value <= 0 ) {
			if ( value < _health ) {
				hitSound.play();
				for (i in 0...Math.ceil(0.3 * (_health - value))) kha.Scene.the.addProjectile(new Blood(x + 20, y + 20));
			}
			if (!killed) {
				kill();
			}
		} else if ( value < _health ) {
			for (i in 0...Math.ceil(0.3 * (_health - value))) kha.Scene.the.addProjectile(new Blood(x + 20, y + 20));
			hitSound.play();
		}
		return super.set_health(value);
	}

	public function kill() {
		hitSound.play();
		killed = true;
		setAnimation(Animation.create(0));
		speedx = 0;
		angle = Math.PI * 1.5;
		originX = width / 2;
		originY = collider.height - 4;
		y += collider.height - collider.width;
		x += collider.width - collider.height;
		collider = new Rectangle(-collider.y,collider.x + collider.width,collider.height,collider.width);
	}
	
	public function isKilled(): Bool {
		return killed;
	}
	
	public override function hit(sprite: Sprite) {
		//Jumpman.getInstance().hitEnemy(this);
	}
	
	@:access(projectiles.PistolProjectile) 
	private function tryToShoot(): Void {
		if (TenUp.getInstance().currentGameTime > nextShootTime) {
			var c = center;
			var focusCenter = focus.center;
			var dir = new Vector2(focusCenter.x - c.x, focusCenter.y - c.y);
			dir = dir.div( dir.length );
			var projectile = new PistolProjectile( dir, 5, 5, this.z);
			projectile.x = c.x + dir.x * width;
			projectile.y = c.y + dir.y * height;
			projectile.speedx *= 0.7;
			projectile.speedy *= 0.7;
			projectile.creatureDamage = Math.round(projectile.creatureDamage * 0.5);
			kha.Scene.the.addProjectile(projectile);
			nextShootTime = TenUp.getInstance().currentGameTime + 1 + Random.getUpTo(2) + Random.getUpTo(2);
		}
	}
	
	public var patrolSpeed: Float = 5.0;
	var watchCounter : Int = 0;
	override public function update(): Void {
		if (speedx < 0) {
			setAnimation(walkLeft);
			lookRight = false;
		}
		else if (speedx > 0) {
			setAnimation(walkRight);
			lookRight = true;
		}
		else if (lookRight) {
			setAnimation(standRight);
		}
		else {
			setAnimation(standLeft);
		}
		
		super.update();
		if (killed) {
			return;
		}
		if (watchCounter == 0) {
			watchCounter = 1;
			var myXmin = x - collider.x;
			var myXmax = myXmin + width;
			watchRect.x = x;
			watchRect.y = y;
			if (!lookRight) watchRect.x = x - watchRect.width;
			var minDistance = 99999999.0;
			for (i in 0...Player.getPlayerCount()) {
				var player = Player.getPlayer(i);
				if (player.isSleeping()) {
					if (focus == player) {
						focus = null;
					}
					continue;
				}
				var xMin = player.x - player.collider.x;
				var xMax = xMin + width;
				var xDist = Math.min( Math.abs(myXmin - xMax), Math.abs( myXmax - xMin ) );
				distances[i] = new Vector2( xDist, y - player.y ).length;
				//trace ( distances[i] );
				if (watchRect.collision(player.collisionRect())) {
					if ( focus == null || (minDistance > distances[i]) ) {
						focus = player;
						minDistance = distances[i];
					}
				} else if (player.walking && distances[i] < 500) {
					if ( focus == null || (minDistance > distances[i]) ) {
						focus = player;
						minDistance = distances[i];
					}
				}
			}
			
			if (focus != null) {
				speedx = (focus.x - x) > 0 ? 3 : -3;
				if ( minDistance > 100 ) {
					if ( Std.is( focus, PlayerBlondie ) ) {
						speedx *= 0.5;
					} else {
						tryToShoot();
					}
				} else if ( minDistance > 50 ) {
					if ( Std.is( focus, PlayerBlondie ) ) {
						speedx *= 0.5;
					} else {
						tryToShoot();
					}
				} else if (minDistance < 25) {
					speedx *= -0.5;
				} else {
					if ( Std.is( focus, PlayerBlondie ) ) {
						var blondie : PlayerBlondie = cast focus;
						if ( !blondie.isDancing ) {
							tryToShoot();
						}
					} else {
						tryToShoot();
					}
					speedx = 0;
				}
			} else {
				speedx = patrolSpeed;
			}
		} else {
			watchCounter = (watchCounter + 1) % 30;
		}
	}
	
	override public function render(g: Graphics): Void {
		super.render(g);
		/*painter.setColor( kha.Color.ColorBlack );
		if (focus != null)
			painter.drawRect( focus.x - focus.collider.x, focus.y - focus.collider.y, focus.width, focus.height );//*/
			
		/*painter.setColor( kha.Color.fromBytes(255,0,0) );
		var rect = collisionRect();
		painter.drawRect( rect.x, rect.y, rect.width, rect.height );
		painter.setColor( kha.Color.ColorBlack );
		painter.drawRect( x - collider.x, y - collider.y, width, height );
		painter.setColor( kha.Color.fromBytes(0,255,0) );
		painter.fillRect( x - 2, y - 2, 5, 5 );//*/
	}
}
