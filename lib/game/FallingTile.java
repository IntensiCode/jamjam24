package net.intensicode.droidshock.effects;

import net.intensicode.droidshock.game.objects.Particle;
import net.intensicode.util.*;

import java.io.*;

public final class FallingTile extends Particle
    {
    public int sizeInPixels;

    public int colorRGB24;

    public float rotationInDegrees;

    public float rotationSpeedInDegrees;


    public final void reset()
        {
        super.reset();
        mySpeedY = 0;
        }

    public final void init( final int aTileID, final float aMaxY )
        {
        animSequenceIndex = aTileID;
        rotationSpeedInDegrees = Random.INSTANCE.nextFloat( 90 ) + 45f;
        rotationInDegrees = Random.INSTANCE.nextFloat( MAX_ROTATION );
        mySpeedY = FALL_SPEED;
        mySpeedY += Random.INSTANCE.nextFloat( FALL_SPEED_DELTA );
        theFixedMaxY = aMaxY;
        }

    public final void setSize( final int aSize, final int aTileColor, final int aIntensity )
        {
        sizeInPixels = aSize;
        colorRGB24 = ColorUtils.darker( aTileColor, aIntensity );
        }

    // From Particle

    public final void onControlTick()
        {
        final int tps = theTicksPerSecond;
        rotationInDegrees += rotationSpeedInDegrees / tps;
        if ( rotationInDegrees >= MAX_ROTATION ) rotationInDegrees -= MAX_ROTATION;

        yPos += mySpeedY / tps;
        if ( yPos >= theFixedMaxY ) active = false;
        }

    public final void save( final DataOutputStream aStream )
        {
        throw new RuntimeException( "nyi" );
        }

    public final void load( final DataInputStream aStream )
        {
        throw new RuntimeException( "nyi" );
        }


    private float mySpeedY;

    private static float theFixedMaxY;

    private static final float MAX_ROTATION = 360f;

    private static final float FALL_SPEED = 128f;

    private static final float FALL_SPEED_DELTA = 64f;
    }
