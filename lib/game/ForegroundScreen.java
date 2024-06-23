package net.intensicode.droidshock.screens;

import net.intensicode.core.*;
import net.intensicode.droidshock.game.VisualConfiguration;
import net.intensicode.droidshock.game.objects.*;
import net.intensicode.screens.ScreenBase;
import net.intensicode.util.*;

public final class ForegroundScreen extends ScreenBase
    {
    private final Random myRandom;

    public ForegroundScreen( final VisualConfiguration aConfiguration )
        {
        myConfiguration = aConfiguration;
        myRandom = Random.INSTANCE;
        }

    // From ScreenBase

    public final void onInitEverytime()
        {
        myLeftSideImage = skin().image( "left_side" );
        myRightSideImage = skin().image( "right_side" );
        myScoreboardImage = skin().image( "scoreboard" );
        myTouchbuttonsImage = skin().image( "touchbuttons" );
        }

    public final void onControlTick() throws Exception
        {
        //#if FULL_FX && !DROIDSHOCK
        if ( myConfiguration.disableSideBubbles ) return;
        final int bubbleCount = myBubbles.numberOfActiveParticles();
        if ( bubbleCount < myConfiguration.sideBubbleParticles ) addNewBubbleParticle();
        myBubbles.onControlTick();
        //#endif
        }

    //#if FULL_FX && !DROIDSHOCK

    private void addNewBubbleParticle()
        {
        final int sidePos;
        if ( mySideFlag ) sidePos = myConfiguration.leftSidePosition.x;
        else sidePos = myConfiguration.rightSidePosition.x;
        mySideFlag = !mySideFlag;

        final int height = myConfiguration.fullHeightSideBubbles ? screen().height() : myLeftSideImage.getHeight();

        final BubbleParticle particle = (BubbleParticle) myBubbles.create();
        final float xOffset = myLeftSideImage.getWidth() * 20f / 100;
        final float xPos = myLeftSideImage.getWidth() * 60f / 100;
        final float yOffset = height * 90f / 100;
        final float yPos = height * 5f / 100;
        final float x = myRandom.nextFloat( xPos ) + xOffset + sidePos;
        final float y = myRandom.nextFloat( yPos ) + yOffset;
        particle.setPosition( x, y );
        final int tickOffset = timing().ticksPerSecond * 4;
        final int tickCount = myRandom.nextInt( timing().ticksPerSecond * 3 );
        particle.setTiming( 0, tickOffset + tickCount );
        particle.activate();

        final float driftOffset = myLeftSideImage.getHeight() * 10f / 100;
        final float driftSpeed = myLeftSideImage.getHeight() * 20f / 100;
        particle.driftSpeed = driftOffset + myRandom.nextFloat( driftSpeed );
        particle.wobbleStrength = myRandom.nextFloat( 2f );
        }

    //#endif

    public final void onDrawFrame()
        {
        final VisualConfiguration config = myConfiguration;
        drawForeground( myLeftSideImage, config.leftSidePosition );
        drawForeground( myRightSideImage, config.rightSidePosition );
        drawForeground( myScoreboardImage, config.scoreboardPosition );
        drawForeground( myTouchbuttonsImage, config.touchbuttonsPosition );

        if ( myConfiguration.disableSideBubbles ) return;

        //#if FULL_FX && !DROIDSHOCK
        final DirectGraphics gc = graphics();
        for ( int idx = 0; idx < myBubbles.particles.size; idx++ )
            {
            final BubbleParticle particle = (BubbleParticle) myBubbles.particles.objects[ idx ];
            if ( particle == null ) continue;
            if ( !particle.active ) continue;
            if ( particle.tickDuration == 0 ) continue;

            final int x = MathExtended.round( particle.xPos + particle.wobbleOffset );
            final int y = MathExtended.round( particle.yPos );
            gc.setColorRGB24( particle.colorRGB );
            gc.drawLine( x, y, x, y );
            }
        //#endif
        }

    // Implementation

    private void drawForeground( final ImageResource aImage, final Position aPosition )
        {
        final DirectGraphics gc = graphics();
        if ( aImage != NullImageResource.NULL ) gc.drawImage( aImage, aPosition.x, aPosition.y, ALIGN_TOP_LEFT );
        }


    private boolean mySideFlag;

    private ImageResource myLeftSideImage;

    private ImageResource myRightSideImage;

    private ImageResource myScoreboardImage;

    private ImageResource myTouchbuttonsImage;

    private final VisualConfiguration myConfiguration;

    //#if FULL_FX && !DROIDSHOCK
    private final Particles myBubbles = new Particles( "net.intensicode.droidshock.game.objects.BubbleParticle" );
    //#endif

    private static final int ALIGN_TOP_LEFT = DirectGraphics.ALIGN_TOP_LEFT;
    }
