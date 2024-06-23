package net.intensicode.droidshock.game;

import net.intensicode.core.KeysHandler;
import net.intensicode.io.StorageByID;
import net.intensicode.util.Log;

import java.io.*;

public final class Controls extends StorageByID
    {
    public static final int ROTATE_UP = 0;

    public static final int MOVE_LEFT = 1;

    public static final int MOVE_RIGHT = 2;

    public static final int MOVE_DOWN = 3;

    public static final int DROP_TILE = 4;

    public static final int DETONATE_TILE = 5;

    public static final int LEFT_SOFTKEY = 6;

    public static final int RIGHT_SOFTKEY = 7;

    public static final int DROP_TILE_ALT = 8;

    public static final int DETONATE_TILE_ALT = 9;

    public int upCode;

    public int leftCode;

    public int rightCode;

    public int downCode;

    public int fireCode;

    public int fireCodeA;

    public int fireCodeB;

    public int fireCodeC;

    public int fireCodeD;

    public int starCode;

    public int poundCode;

    public int leftSoftCode;

    public int rightSoftCode;



    public Controls()
        {
        super( RECORD_STORE_NAME );
        }

    public final void initFrom( final KeysHandler aKeys )
        {
        //#if DEBUG
        Log.debug( "Initializing control scheme" );
        //#endif

        upCode = aKeys.upCode;
        downCode = aKeys.downCode;
        leftCode = aKeys.leftCode;
        rightCode = aKeys.rightCode;
        fireCode = aKeys.fireCode;
        fireCodeA = aKeys.fireCodeA;
        fireCodeB = aKeys.fireCodeB;
        fireCodeC = aKeys.fireCodeC;
        fireCodeD = aKeys.fireCodeD;
        starCode = aKeys.starCode;
        poundCode = aKeys.poundCode;
        leftSoftCode = aKeys.softLeftCode;
        rightSoftCode = aKeys.softRightCode;
        }

    public final void activate( final KeysHandler aKeys )
        {
        //#if DEBUG
        Log.debug( "Activating control scheme" );
        //#endif

        aKeys.upCode = upCode;
        aKeys.downCode = downCode;
        aKeys.leftCode = leftCode;
        aKeys.rightCode = rightCode;
        aKeys.fireCode = fireCode;
        aKeys.fireCodeA = fireCodeA;
        aKeys.fireCodeB = fireCodeB;
        aKeys.fireCodeC = fireCodeC;
        aKeys.fireCodeD = fireCodeD;
        aKeys.starCode = starCode;
        aKeys.poundCode = poundCode;
        aKeys.softLeftCode = leftSoftCode;
        aKeys.softRightCode = rightSoftCode;
        }

    // From StorageByID

    protected final void loadEntry( final int aID, final DataInputStream aInput ) throws IOException
        {
        final int value = aInput.readByte();
        switch ( aID )
            {
            case ROTATE_UP:
                upCode = value;
                break;
            case MOVE_LEFT:
                leftCode = value;
                break;
            case MOVE_RIGHT:
                rightCode = value;
                break;
            case MOVE_DOWN:
                downCode = value;
                break;
            case DROP_TILE:
                starCode = value;
                break;
            case DETONATE_TILE:
                poundCode = value;
                break;
            case LEFT_SOFTKEY:
                leftSoftCode = value;
                break;
            case RIGHT_SOFTKEY:
                rightSoftCode = value;
                break;
            case DROP_TILE_ALT:
                fireCodeA = value;
                break;
            case DETONATE_TILE_ALT:
                fireCodeB = value;
                break;
            }
        }

    // From StorageIO

    public final void saveTo( final DataOutputStream aOutput ) throws IOException
        {
        writeByte( aOutput, ROTATE_UP, upCode );
        writeByte( aOutput, MOVE_LEFT, leftCode );
        writeByte( aOutput, MOVE_RIGHT, rightCode );
        writeByte( aOutput, MOVE_DOWN, downCode );
        writeByte( aOutput, DROP_TILE, starCode );
        writeByte( aOutput, DETONATE_TILE, poundCode );
        writeByte( aOutput, DROP_TILE_ALT, fireCodeA );
        writeByte( aOutput, DETONATE_TILE_ALT, fireCodeB );
        writeByte( aOutput, LEFT_SOFTKEY, leftSoftCode );
        writeByte( aOutput, RIGHT_SOFTKEY, rightSoftCode );
        }



    private static final String RECORD_STORE_NAME = "controls";
    }
