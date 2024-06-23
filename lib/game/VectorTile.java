package net.intensicode.droidshock.effects;

import net.intensicode.core.DirectGraphics;
import net.intensicode.droidshock.game.objects.Tile;
import net.intensicode.util.*;

public final class VectorTile
    {
    public VectorTile( final Tile aTile )
        {
        final int xOffset = aTile.offset_x( Tile.ROTATE_0 );
        final int yOffset = aTile.offset_y( Tile.ROTATE_0 );

        for ( int y = 0; y < aTile.height( Tile.ROTATE_0 ); y++ )
            {
            for ( int x = 0; x < aTile.width( Tile.ROTATE_0 ); x++ )
                {
                if ( !aTile.isSet( x, y, Tile.ROTATE_0 ) ) continue;
                myTriangles.add( new VectorTriangle( x + xOffset, y + yOffset, false ) );
                myTriangles.add( new VectorTriangle( x + xOffset, y + yOffset, true ) );
                }
            }
        }

    public final void draw( final DirectGraphics aGC, final FallingTile aTile, final int aX, final int aY, final boolean aShadow )
        {
        if ( aShadow ) aGC.setColorRGB24( 0x202020 );
        else aGC.setColorRGB24( aTile.colorRGB24 );

        final float sinIndex = MathExtended.toRadians( aTile.rotationInDegrees );
        final float sin = MathExtended.sin( sinIndex ) * 512;
        final float cos = MathExtended.cos( sinIndex ) * 512;
        final int x = aShadow ? aX + aTile.sizeInPixels / 2 : aX;
        final int y = aShadow ? aY + aTile.sizeInPixels / 3 : aY;
        for ( int idx = 0; idx < myTriangles.size; idx++ )
            {
            final VectorTriangle triangle = (VectorTriangle) myTriangles.objects[ idx ];
            triangle.draw( aGC, sin, cos, x, y, aTile.sizeInPixels );
            }
        }

    private final DynamicArray myTriangles = new DynamicArray();
    }
