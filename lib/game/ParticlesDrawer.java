package net.intensicode.droidshock.game.drawers;

import net.intensicode.core.*;
import net.intensicode.droidshock.game.*;
import net.intensicode.droidshock.game.objects.*;
import net.intensicode.graphics.SpriteGenerator;
import net.intensicode.screens.ScreenBase;
import net.intensicode.util.MathExtended;

public final class ParticlesDrawer extends ScreenBase
    {
    public int unitWidthInPixels = 1;

    public int unitHeightInPixels = 1;

    public int xOffsetInPixels = 0;

    public int yOffsetInPixels = 0;


    public ParticlesDrawer( final GameContext aGameContext, final Particles aParticles, final String aImageName )
        {
        myGameContext = aGameContext;
        myParticles = aParticles;
        myImageName = aImageName;
        }

    public final ParticlesDrawer setInGameDrawer( final boolean aInGameFlag )
        {
        myInGameFlag = aInGameFlag;
        return this;
        }

    public final ParticlesDrawer setNumberOfAnimSequences( final int aNumberOfSequences )
        {
        myNumberOfSequences = aNumberOfSequences;
        return this;
        }

    public final ParticlesDrawer setSingleFrame()
        {
        myNumberOfSequences = -1;
        return this;
        }

    // From GameObject

    public final void onInitOnce() throws Exception
        {
        final SkinManager skin = myGameContext.visualConfiguration().skin;
        myParticleGen = skin.sprite( myImageName );
        myParticleGen.defineReferencePixel( myParticleGen.getWidth() / 2, myParticleGen.getHeight() / 2 );

        if ( myNumberOfSequences == -1 ) myNumberOfSequences = myParticleGen.getRawFrameCount();

        myNumberOfFrames = myParticleGen.getRawFrameCount() / myNumberOfSequences;
        }

    public void onInitEverytime() throws Exception
        {
        if ( !myInGameFlag ) return;

        final VisualConfiguration configuration = myGameContext.visualConfiguration();
        unitWidthInPixels = configuration.blockSizeInPixels.width;
        unitHeightInPixels = configuration.blockSizeInPixels.height;
        xOffsetInPixels = configuration.containerPosition.x;
        yOffsetInPixels = configuration.containerPosition.y;
        }

    public final void onControlTick() throws Exception
        {
        }

    public final void onDrawFrame()
        {
        final DirectGraphics gc = graphics();

        final Object[] particles = myParticles.particles.objects;
        final int numberOfParticles = myParticles.particles.size;
        for ( int idx = 0; idx < numberOfParticles; idx++ )
            {
            final Particle particle = (Particle) particles[ idx ];
            if ( !particle.active ) continue;

            final int frameOffset = particle.animSequenceIndex * myNumberOfFrames;
            if ( myNumberOfFrames > 1 && particle.tickDuration > 0 )
                {
                final int frame = particle.tickCounter * ( myNumberOfFrames - 1 ) / particle.tickDuration;
                myParticleGen.setFrame( frameOffset + frame );
                }
            else
                {
                myParticleGen.setFrame( frameOffset );
                }

            final int x = MathExtended.round( particle.xPos * unitWidthInPixels ) + xOffsetInPixels;
            final int y = MathExtended.round( particle.yPos * unitHeightInPixels ) + yOffsetInPixels;
            myParticleGen.paint( gc, x, y );
            }
        }


    private SpriteGenerator myParticleGen;

    private boolean myInGameFlag = true;

    private int myNumberOfFrames;

    private int myNumberOfSequences = 1;


    private final String myImageName;

    private final Particles myParticles;

    private final GameContext myGameContext;
    }
