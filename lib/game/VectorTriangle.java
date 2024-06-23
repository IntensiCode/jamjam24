package net.intensicode.droidshock.effects;

import net.intensicode.core.DirectGraphics;

public final class VectorTriangle
    {
    public VectorTriangle( final int aX, final int aY, final boolean aLowerTriangle )
        {
        if ( aLowerTriangle )
            {
            myX1 = aX + 1;
            myY1 = aY;
            myX2 = aX + 1;
            myY2 = aY + 1;
            myX3 = aX;
            myY3 = aY + 1;
            }
        else
            {
            myX1 = aX;
            myY1 = aY;
            myX2 = aX + 1;
            myY2 = aY;
            myX3 = aX;
            myY3 = aY + 1;
            }
        }

    public final void draw( final DirectGraphics aGC, final float aSin, final float aCos, final int aX, final int aY, final int aSize )
        {
        final int x1 = (int) ( aX + ( myX1 * aSize * aCos ) / 512 + ( myY1 * aSize * aSin ) / 512 );
        final int y1 = (int) ( aY + ( myX1 * aSize * aSin ) / 512 - ( myY1 * aSize * aCos ) / 512 );
        final int x2 = (int) ( aX + ( myX2 * aSize * aCos ) / 512 + ( myY2 * aSize * aSin ) / 512 );
        final int y2 = (int) ( aY + ( myX2 * aSize * aSin ) / 512 - ( myY2 * aSize * aCos ) / 512 );
        final int x3 = (int) ( aX + ( myX3 * aSize * aCos ) / 512 + ( myY3 * aSize * aSin ) / 512 );
        final int y3 = (int) ( aY + ( myX3 * aSize * aSin ) / 512 - ( myY3 * aSize * aCos ) / 512 );
        aGC.fillTriangle( x1, y1, x2, y2, x3, y3 );
        }

    private final int myX1;

    private final int myY1;

    private final int myX2;

    private final int myY2;

    private final int myX3;

    private final int myY3;
    }
