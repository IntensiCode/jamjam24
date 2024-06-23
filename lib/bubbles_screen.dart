import 'package:flame/components.dart';

class BubblesScreen extends Component {

    @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }
}

//     public final void onControlTick() throws Exception
//         {
//         final int bubbleCount = myBubbles.numberOfActiveParticles();
//         if ( bubbleCount < myConfig.bubbleParticles )
//             {
//             final int width = screen().width();
//             final int height = screen().height();
//
//             final BubbleParticle particle = (BubbleParticle) myBubbles.create();
//             final float yOffset = height * 90f / 100;
//             final float yPos = height * 10f / 100;
//             final float x = myRandom.nextFloat( width );
//             final float y = myRandom.nextFloat( yPos ) + yOffset;
//             particle.setPosition( x, y );
//
//             final int speedAndTimeFactor = myRandom.nextInt( 100 );
//
//             final int tickOffset = timing().ticksPerSecond * 4;
//             final int tickCount = timing().ticksPerSecond * 3 * speedAndTimeFactor / 100;
//             particle.setTiming( 0, tickOffset + tickCount );
//             particle.activate();
//
//             final float driftOffset = height * 10f / 100;
//             final float driftSpeed = height * 20f / 100;
//             particle.driftSpeed = driftOffset + driftSpeed * speedAndTimeFactor / 100;
//             particle.wobbleStrength = myRandom.nextFloat( 2f );
//             }
//
//         myBubbles.onControlTick();
//         }
//
//     public final void onDrawFrame()
//         {
//         final DirectGraphics gc = graphics();
//         for ( int idx = 0; idx < myBubbles.particles.size; idx++ )
//             {
//             final BubbleParticle particle = (BubbleParticle) myBubbles.particles.objects[ idx ];
//             if ( particle == null ) continue;
//             if ( !particle.active ) continue;
//             if ( particle.tickDuration == 0 ) continue;
//
//             final int x = MathExtended.round( particle.xPos + particle.wobbleOffset );
//             final int y = MathExtended.round( particle.yPos );
//             gc.setColorRGB24( particle.colorRGB );
//             gc.drawLine( x, y, x, y );
//             }
//         }
//
//
//     private VisualConfiguration myConfig;
//
//     private final Random myRandom = Random.INSTANCE;
//
//     private final Particles myBubbles = new Particles( "net.intensicode.droidshock.game.objects.BubbleParticle" );
//     }
