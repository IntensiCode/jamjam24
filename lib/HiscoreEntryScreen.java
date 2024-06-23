package net.intensicode.droidshock.screens;

import net.intensicode.core.*;
import net.intensicode.droidshock.game.*;
import net.intensicode.droidshock.game.objects.Level;
import net.intensicode.droidshock.game.objects.Player;
import net.intensicode.graphics.FontGenerator;
import net.intensicode.screens.MultiScreen;
import net.intensicode.screens.SoftkeysScreen;
import net.intensicode.util.Position;

public final class HiscoreEntryScreen extends MultiScreen
    {
    public HiscoreEntryScreen( final MainLogic aMainLogic, final GameModel aGameModel )
        {
        myMainLogic = aMainLogic;
        myGameModel = aGameModel;

        myHiscore = aMainLogic.hiscore();
        myTitleFont = aMainLogic.visualContext().menuFont();
        myTextFont = aMainLogic.visualContext().textFont();
        }

    // From ScreenBase

    public final void onInitOnce() throws Exception
        {
        addScreen( myMainLogic.sharedBackground() );
        addScreen( mySoftkeys = myMainLogic.sharedSoftkeys() );
        }

    //#if ORIENTATION_DYNAMIC

    public void onOrientationChanged() throws Exception
        {
        if ( mySoftkeys != null ) removeScreen( mySoftkeys );
        addScreen( mySoftkeys = myMainLogic.sharedSoftkeys() );
        super.onOrientationChanged();
        }

    //#endif

    public final void onInitEverytime() throws Exception
        {
        myTitlePos.x = screen().width() / 2;
        myTitlePos.y = myTitleFont.charHeight();

        myCurrentCharIndex = 'A';

        final int tps = timing().ticksPerSecond;

        final KeysHandler keys = keys();
        keys.reset( tps );

        keys.keyRepeatDelayInTicks = tps * 50 / 100;
        keys.keyRepeatIntervalInTicks = tps * 10 / 100;
        keys.dontRepeatFlags[ KeysHandler.UP ] = true;
        keys.dontRepeatFlags[ KeysHandler.DOWN ] = true;
        keys.dontRepeatFlags[ KeysHandler.FIRE1 ] = true;
        keys.dontRepeatFlags[ KeysHandler.FIRE2 ] = true;
        keys.dontRepeatFlags[ KeysHandler.STICK_DOWN ] = true;
        keys.dontRepeatFlags[ KeysHandler.LEFT_SOFT ] = true;
        keys.dontRepeatFlags[ KeysHandler.RIGHT_SOFT ] = true;

        myMainLogic.sharedSoftkeys().setSoftkeys( I18n._( "ADD CHAR" ), I18n._( "CLEAR CHAR" ) );
        }

    public final void onControlTick() throws Exception
        {
        final KeysHandler keys = keys();
        if ( keys.checkUpAndConsume() || keys.checkDownAndConsume() ) myOnEndFlag = !myOnEndFlag;

        if ( myOnEndFlag ) onEndButton( keys );
        else onCharSelector( keys );

        super.onControlTick();
        }

    public final void onDrawFrame()
        {
        super.onDrawFrame();

        final DirectGraphics gc = graphics();

        myBlitPos.setTo( myTitlePos );
        myTitleFont.blitString( gc, I18n._( "HISCORE" ), myBlitPos, FontGenerator.CENTER );

        myBlitPos.y += myTitleFont.charHeight();
        myTextFont.blitString( gc, I18n._( "ENTER YOUR NAME" ), myBlitPos, FontGenerator.CENTER );

        final int refWidth = myTitleFont.stringWidth( "X" );

        if ( myOnEndFlag )
            {
            final int x = screen().width() / 2 - myTitleFont.stringWidth( I18n._( "END" ) );
            final int y = screen().height() * 2 / 5 - myTitleFont.charHeight() * 3 / 2;
            final int width = myTextFont.stringWidth( I18n._( "END" ) ) * 2;
            final int height = myTitleFont.charHeight();

            gc.setColorRGB24( 0x800000 );
            gc.fillRect( x, y, width, height );
            gc.setColorRGB24( 0xC04040 );
            gc.drawRect( x, y, width, height );
            }
        else
            {
            final int x = screen().width() / 2 - refWidth * 2 / 3;
            final int y = screen().height() / 2 - myTitleFont.charHeight() / 2;
            final int width = refWidth * 3 / 2 - refWidth / 4 + 3;
            final int height = myTitleFont.charHeight();

            gc.setColorRGB24( 0x800000 );
            gc.fillRect( x, y, width, height );
            gc.setColorRGB24( 0xC04040 );
            gc.drawRect( x, y, width, height );
            }

        myBlitPos.y = screen().height() * 2 / 5 - myTitleFont.charHeight();
        myTitleFont.blitString( gc, I18n._( "END" ), myBlitPos, FontGenerator.CENTER );

        for ( int idx = -6; idx < 7; idx++ )
            {
            int charCode = myCurrentCharIndex + idx;
            if ( charCode < MIN_CHAR_INDEX ) charCode += NUM_CHARS;
            if ( charCode > MAX_CHAR_INDEX ) charCode -= NUM_CHARS;

            final int yOffset = Math.abs( idx ) * myTitleFont.charHeight();

            myBlitPos.x = screen().width() / 2 + idx * refWidth * 3 / 2;
            myBlitPos.y = screen().height() / 2 + yOffset * yOffset / 15 / 15;

            final FontGenerator font = ( idx != 1000 ) ? myTitleFont : myTextFont;
            font.blitChar( gc, myBlitPos.x - refWidth / 2, myBlitPos.y - font.charHeight() / 2, charCode );
            }

        myBlitPos.x = screen().width() / 2;
        myBlitPos.y = screen().height() * 3 / 4 - myTitleFont.charHeight();

        myTitleFont.blitString( gc, myCurrentName, myBlitPos, FontGenerator.CENTER );

        myBlitPos.y += myTitleFont.charHeight() * 2;

        myTitleFont.blitNumber( gc, myBlitPos, myGameModel.player.score, FontGenerator.CENTER );
        }

    // Implementation

    private void onEndButton( final KeysHandler aKeys ) throws Exception
        {
        final String accept = I18n._( "ACCEPT" );
        final String invalid = I18n._( "" );
        final String clear = I18n._( "CLEAR" );
        myMainLogic.sharedSoftkeys().setSoftkeys( nameValid() ? accept : invalid, clear );

        if ( aKeys.checkLeftSoftAndConsume() || aKeys.checkFireAndConsume() || aKeys.checkStickDownAndConsume() )
            {
            onEndAction();
            }

        if ( aKeys.checkRightSoftAndConsume() ) myCurrentName = "";
        }

    private void onEndAction() throws Exception
        {
        if ( !nameValid() ) return;

        stack().popScreen( this );

        final Player player = myGameModel.player;
        final Level level = myGameModel.level;
        myHiscore.insert( player.score, level.levelNumberStartingAt1, myCurrentName );

        myMainLogic.postOnline( "New hiscore for " + myCurrentName + ": " + player.score );

        myMainLogic.showHiscoreWithoutUpdatingFirst();
        myMainLogic.saveHiscore();
        }

    private void onCharSelector( final KeysHandler aKeys )
        {
        mySoftkeys.setSoftkeys( nameMaxLength() ? "" : I18n._( "ADD CHAR" ), I18n._( "REMOVE" ) );

        if ( aKeys.checkFireAndConsume() || aKeys.checkLeftSoftAndConsume() || aKeys.checkStickDownAndConsume() )
            {
            addCurrentChar();
            }

        if ( aKeys.checkLeftAndConsume() ) myCurrentCharIndex--;
        else if ( aKeys.checkRightAndConsume() ) myCurrentCharIndex++;
        else if ( aKeys.checkRightSoftAndConsume() ) removeLastChar();

        updateCharIndex();
        }

    private void updateCharIndex()
        {
        if ( myCurrentCharIndex < MIN_CHAR_INDEX ) myCurrentCharIndex = MAX_CHAR_INDEX;
        else if ( myCurrentCharIndex > MAX_CHAR_INDEX ) myCurrentCharIndex = MIN_CHAR_INDEX;
        }

    private void addCurrentChar()
        {
        if ( nameMaxLength() ) return;
        myBuffer.setLength( 0 );
        myBuffer.append( myCurrentName );
        myBuffer.append( (char) myCurrentCharIndex );
        myCurrentName = myBuffer.toString();
        }

    private void removeLastChar()
        {
        if ( myCurrentName.length() == 0 ) return;
        myCurrentName = myCurrentName.substring( 0, myCurrentName.length() - 1 );
        }

    private boolean nameValid()
        {
        return myCurrentName.length() >= 3;
        }

    private boolean nameMaxLength()
        {
        return myCurrentName.length() >= Hiscore.MAX_NAME_LENGTH;
        }


    private boolean myOnEndFlag;

    private int myCurrentCharIndex;

    private SoftkeysScreen mySoftkeys;

    private String myCurrentName = "DUDE";


    private final Hiscore myHiscore;

    private final FontGenerator myTextFont;

    private final FontGenerator myTitleFont;

    private final MainLogic myMainLogic;

    private final GameModel myGameModel;

    private final Position myBlitPos = new Position();

    private final Position myTitlePos = new Position();


    private static final char MIN_CHAR_INDEX = ' ';

    private static final char MAX_CHAR_INDEX = '_';

    private static final int NUM_CHARS = MAX_CHAR_INDEX - MIN_CHAR_INDEX + 1;

    private final StringBuffer myBuffer = new StringBuffer();
    }
