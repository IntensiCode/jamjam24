package net.intensicode.droidshock.game;

import net.intensicode.droidshock.effects.GradientScreen;
import net.intensicode.graphics.BitmapFontGenerator;
import net.intensicode.io.StorageByID;
import net.intensicode.screens.ConsoleOverlay;
import net.intensicode.screens.EngineStats;
import net.intensicode.util.Log;

import java.io.*;

public final class Options extends StorageByID
    {
    private static final int VERSION = 255;

    private static final int VERSION_1 = 1;

    private static final int VERSION_2 = 2;

    public static final int SHOW_ENGINE_STATS = 0;

    public static final int SHOW_CONSOLE = 1;

    public static final int BUFFERED_FONTGEN = 2;

    public static final int TRACKBALL_SENSITIVITY = 9;

    public static final int BUFFERED_CONTAINER = 10;

    public static final int BUFFERED_GRADIENTS = 11;

    public static final int BACKGROUND_BUBBLES = 12;

    public static final int SIDE_BUBBLES = 13;

    public static final int FALLING_TILES = 14;

    public static final int FALLING_HEARTS = 15;

    public static final int ROTATE_CLOCKWISE = 17;

    public static final int ROTATE_CAN_MOVE = 18;

    public static final int DARK_BACKGROUND = 19;

    public static final int DROP_HINT_MODE = 20;

    public static final int DRAG_N_PUSH_SENSITIVITY = 30;

    public static final int DRAG_N_PUSH_INFO_SHOWN = 32;

    public static final int SHOW_TUTORIAL = 33;

    public static final int TUTORIAL_INFO_SHOWN = 34;

    public static final int TWITTER = 35;

    public static final int FACEBOOK = 36;


    public Options( final MainLogic aMainLogic )
        {
        super( RECORD_STORE_NAME );
        myMainLogic = aMainLogic;
        }

    // From StorageIO

    public final void loadFrom( final DataInputStream aInput ) throws IOException
        {
        myLoadVersion = VERSION_1;
        super.loadFrom( aInput );
        }

    // From StorageByID

    protected final void loadEntry( final int aId, final DataInputStream aInput ) throws IOException
        {
        if ( aId == VERSION )
            {
            myLoadVersion = aInput.readInt();
            }
        else
            {
            if ( myLoadVersion > VERSION_1 ) loadEntryV2( aId, aInput );
            else loadEntryV1( aId, aInput );
            }
        }

    private void loadEntryV2( final int aId, final DataInputStream aInput ) throws IOException
        {
        final int intValue = aInput.readInt();
        final boolean boolValue = intValue != 0 ? true : false;

        final GameConfiguration game = myMainLogic.gameController().gameConfiguration();
        final VisualConfiguration config = myMainLogic.visualConfig();
        switch ( aId )
            {
            //#if STATS
            case SHOW_ENGINE_STATS:
                EngineStats.show = boolValue;
                break;
            //#endif
            //#if CONSOLE
            case SHOW_CONSOLE:
                ConsoleOverlay.show = boolValue;
                break;
            //#endif
            case BUFFERED_FONTGEN:
                BitmapFontGenerator.buffered = boolValue;
                break;
            //#if TRACKBALL
            case TRACKBALL_SENSITIVITY:
                game.trackballSensitivity = intValue;
                break;
            //#endif
            //#if TOUCH
            case DRAG_N_PUSH_SENSITIVITY:
                game.touchControlsSensitivity = intValue;
                break;
            case DRAG_N_PUSH_INFO_SHOWN:
                game.dragAndPushInfoShown = boolValue;
                break;
            //#endif

            case TUTORIAL_INFO_SHOWN:
                game.tutorialInfoShown = boolValue;
                break;

            //#if !ANDROID
            case BUFFERED_CONTAINER:
                config.bufferedContainer = boolValue;
                break;
            //#endif
            case BUFFERED_GRADIENTS:
                GradientScreen.buffered = boolValue;
                break;
            case FALLING_TILES:
                config.disableFallingTiles = boolValue;
                break;
            case BACKGROUND_BUBBLES:
                config.disableBubbleParticles = boolValue;
                break;
            case SIDE_BUBBLES:
                config.disableSideBubbles = boolValue;
                break;
            case FALLING_HEARTS:
                config.disableFallingHearts = boolValue;
                break;
            case ROTATE_CLOCKWISE:
                game.rotateClockWise = boolValue;
                break;
            case ROTATE_CAN_MOVE:
                game.rotateCanMove = boolValue;
                break;
            //#if DROIDSHOCK
            case DARK_BACKGROUND:
                config.darkBackground = boolValue;
                break;
            //#endif
            case DROP_HINT_MODE:
                game.dropHintMode = intValue;
                break;
            //#if TUTORIAL
            case SHOW_TUTORIAL:
                game.showTutorial = boolValue;
                break;
            //#endif
            //#if TWITTER
            case TWITTER:
                game.tweetHiscoresAndAchievements = boolValue;
                break;
            //#endif
            //#if FACEBOOK
            case FACEBOOK:
                game.postHiscoresAndAchievementsToFacebook = boolValue;
                break;
            //#endif
            }
        }

    private void loadEntryV1( final int aId, final DataInputStream aInput ) throws IOException
        {
        final GameConfiguration game = myMainLogic.gameController().gameConfiguration();
        final VisualConfiguration config = myMainLogic.visualConfig();
        switch ( aId )
            {
            //#if STATS
            case SHOW_ENGINE_STATS:
                EngineStats.show = aInput.readBoolean();
                break;
            //#endif
            //#if CONSOLE
            case SHOW_CONSOLE:
                ConsoleOverlay.show = aInput.readBoolean();
                break;
            //#endif
            case BUFFERED_FONTGEN:
                BitmapFontGenerator.buffered = aInput.readBoolean();
                break;
            //#if TRACKBALL
            case TRACKBALL_SENSITIVITY:
                game.trackballSensitivity = aInput.readInt();
                break;
            //#endif
            //#if TOUCH
            case DRAG_N_PUSH_SENSITIVITY:
                game.touchControlsSensitivity = aInput.readInt();
                break;
            case DRAG_N_PUSH_INFO_SHOWN:
                game.dragAndPushInfoShown = aInput.readBoolean();
                break;
            //#endif

            case TUTORIAL_INFO_SHOWN:
                game.tutorialInfoShown = aInput.readBoolean();
                break;

            //#if !ANDROID
            case BUFFERED_CONTAINER:
                config.bufferedContainer = aInput.readBoolean();
                break;
            //#endif
            case BUFFERED_GRADIENTS:
                GradientScreen.buffered = aInput.readBoolean();
                break;
            case FALLING_TILES:
                config.disableFallingTiles = aInput.readBoolean();
                break;
            case BACKGROUND_BUBBLES:
                config.disableBubbleParticles = aInput.readBoolean();
                break;
            case SIDE_BUBBLES:
                config.disableSideBubbles = aInput.readBoolean();
                break;
            case FALLING_HEARTS:
                config.disableFallingHearts = aInput.readBoolean();
                break;
            case ROTATE_CLOCKWISE:
                game.rotateClockWise = aInput.readBoolean();
                break;
            case ROTATE_CAN_MOVE:
                game.rotateCanMove = aInput.readBoolean();
                break;
            //#if DROIDSHOCK
            case DARK_BACKGROUND:
                config.darkBackground = aInput.readBoolean();
                break;
            //#endif
            case DROP_HINT_MODE:
                game.dropHintMode = aInput.readInt();
                break;
            //#if TUTORIAL
            case SHOW_TUTORIAL:
                game.showTutorial = aInput.readBoolean();
                break;
            //#endif
            //#if TWITTER
            case TWITTER:
                game.tweetHiscoresAndAchievements = aInput.readBoolean();
                break;
            //#endif
            //#if FACEBOOK
            case FACEBOOK:
                game.postHiscoresAndAchievementsToFacebook = aInput.readBoolean();
                break;
            //#endif
            }
        }

    // From StorageIO

    public final void saveTo( final DataOutputStream aOutput ) throws IOException
        {
        final GameConfiguration game = myMainLogic.gameController().gameConfiguration();
        final VisualConfiguration config = myMainLogic.visualConfig();

        // Version marker first:
        write( aOutput, VERSION, VERSION_2 );

        //#if STATS
        write( aOutput, SHOW_ENGINE_STATS, EngineStats.show );
        //#endif
        //#if CONSOLE
        write( aOutput, SHOW_CONSOLE, ConsoleOverlay.show );
        //#endif
        write( aOutput, BUFFERED_FONTGEN, BitmapFontGenerator.buffered );
        //#if TRACKBALL
        write( aOutput, TRACKBALL_SENSITIVITY, game.trackballSensitivity );
        //#endif
        //#if TOUCH
        write( aOutput, DRAG_N_PUSH_SENSITIVITY, game.touchControlsSensitivity );
        write( aOutput, DRAG_N_PUSH_INFO_SHOWN, game.dragAndPushInfoShown );
        //#endif

        write( aOutput, TUTORIAL_INFO_SHOWN, game.tutorialInfoShown );

        //#if !ANDROID
        write( aOutput, BUFFERED_CONTAINER, config.bufferedContainer );
        //#endif
        write( aOutput, BUFFERED_GRADIENTS, GradientScreen.buffered );
        write( aOutput, FALLING_TILES, config.disableFallingTiles );
        write( aOutput, BACKGROUND_BUBBLES, config.disableBubbleParticles );
        write( aOutput, SIDE_BUBBLES, config.disableSideBubbles );
        write( aOutput, FALLING_HEARTS, config.disableFallingHearts );
        write( aOutput, ROTATE_CLOCKWISE, game.rotateClockWise );
        write( aOutput, ROTATE_CAN_MOVE, game.rotateCanMove );
        //#if DROIDSHOCK
        write( aOutput, DARK_BACKGROUND, config.darkBackground );
        //#endif

        write( aOutput, DROP_HINT_MODE, game.dropHintMode );

        //#if TUTORIAL
        write( aOutput, SHOW_TUTORIAL, game.showTutorial );
        //#endif
        //#if TWITTER
        write( aOutput, TWITTER, game.tweetHiscoresAndAchievements );
        //#endif
        //#if FACEBOOK
        write( aOutput, FACEBOOK, game.postHiscoresAndAchievementsToFacebook );
        //#endif
        }

    protected void write( final DataOutputStream aOutput, final int aID, final boolean aValue ) throws IOException
        {
        writeInt( aOutput, aID, aValue ? 1 : 0 );
        }

    protected void write( final DataOutputStream aOutput, final int aID, final int aValue ) throws IOException
        {
        writeInt( aOutput, aID, aValue );
        }

    private int myLoadVersion = VERSION_1;

    private final MainLogic myMainLogic;

    private static final String RECORD_STORE_NAME = "options";
    }
