package net.intensicode.droidshock.effects;

import net.intensicode.core.DirectGraphics;
import net.intensicode.droidshock.game.VisualConfiguration;
import net.intensicode.droidshock.game.objects.Particles;
import net.intensicode.droidshock.game.objects.TileSet;
import net.intensicode.screens.ScreenBase;
import net.intensicode.util.*;

public final class FallingTiles extends ScreenBase
    {
    public FallingTiles( final VisualConfiguration aConfiguration )
        {
        myConfiguration = aConfiguration;
        myFallingParticles = new Particles( "net.intensicode.droidshock.effects.FallingTile" );

        myVectorTiles = new VectorTile[TileSet.tiles.length];
        for ( int idx = 0; idx < myVectorTiles.length; idx++ )
            {
            myVectorTiles[ idx ] = new VectorTile( TileSet.tiles[ idx ] );
            }
        }

    // From ScreenBase

    public final void onControlTick() throws Exception
        {
        myFallingParticles.onControlTick();

        myTickCounter++;
        if ( myTickCounter < timing().ticksPerSecond ) return;

        final FallingTile tile = (FallingTile) myFallingParticles.create();
        final int x = myRandom.nextInt( screen().width() );
        final int y = -myRandom.nextInt( screen().height() / 4 );
        final float yMax = screen().height() * 5f / 4;
        final int tileID = myRandom.nextInt( TileSet.tiles.length );

        tile.init( tileID, yMax );
        tile.setPosition( x, y );
        tile.activate();

        final int baseSize = screen().width() / 32;
        final int maxSize = screen().width() / 32;
        final int addedSize = Random.INSTANCE.nextInt( maxSize );
        final int size = baseSize + addedSize;
        final int intensity = 128 + addedSize * 127 / maxSize;
        tile.setSize( size, myConfiguration.tileColors[ tile.animSequenceIndex ], intensity );

        myTickCounter = 0;
        }

    public final void onDrawFrame()
        {
        final DirectGraphics gc = graphics();

        final DynamicArray particles = myFallingParticles.particles;
        for ( int idx = 0; idx < particles.size; idx++ )
            {
            final FallingTile tile = (FallingTile) particles.objects[ idx ];
            if ( !tile.active ) continue;
            drawTile( gc, tile, false );
            }
        }

    // Implemenation

    private void drawTile( final DirectGraphics aGC, final FallingTile aTile, final boolean aShadow )
        {
        final int x = MathExtended.round( aTile.xPos );
        final int y = MathExtended.round( aTile.yPos );

        final VectorTile tile = myVectorTiles[ aTile.animSequenceIndex ];
        tile.draw( aGC, aTile, x, y, aShadow );
        }


    private int myTickCounter;

    private final VectorTile[] myVectorTiles;

    private final Particles myFallingParticles;

    private final Random myRandom = new Random( 1704 );

    private final VisualConfiguration myConfiguration;
    }
