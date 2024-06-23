//#condition TOUCH

package net.intensicode.droidshock.screens;

import net.intensicode.core.*;
import net.intensicode.droidshock.game.*;
import net.intensicode.droidshock.game.objects.*;
import net.intensicode.graphics.FontGenerator;
import net.intensicode.screens.*;
import net.intensicode.util.Rectangle;

public final class HiscoreEntryTouch extends MultiScreen
    {
    public HiscoreEntryTouch( final MainLogic aMainLogic, final GameModel aGameModel )
        {
        myMainLogic = aMainLogic;
        myGameModel = aGameModel;

        myHiscore = aMainLogic.hiscore();
        myTextFont = aMainLogic.visualContext().textFont();
        myTitleFont = aMainLogic.visualContext().menuFont();
        }

    // From ScreenBase

    public final void onInitOnce() throws Exception
        {
        addScreen( myMainLogic.sharedBackground() );
        addScreen( mySoftkeys = myMainLogic.sharedSoftkeys() );

        final int centerX = screen().width() / 2;

        final int fontHeight = myTitleFont.charHeight();

        final int titleY = fontHeight;
        final int scoreLabelY = fontHeight * 4;
        final int scoreY = fontHeight * 5;
        final int nameLabelY = fontHeight * 7;
        final int nameY = fontHeight * 8;
        final int selectorY = fontHeight * 10;

        addScreen( new AlignedTextScreen( myTitleFont, I18n._( "HISCORE" ), centerX, titleY, FontGenerator.CENTER ) );
        addScreen( new AlignedTextScreen( myTextFont, I18n._( "YOUR SCORE:" ), centerX, scoreLabelY, FontGenerator.CENTER ) );
        addScreen( myScoreScreen = new AlignedTextScreen( myTitleFont, "SCORE", centerX, scoreY, FontGenerator.CENTER ) );
        addScreen( new AlignedTextScreen( myTextFont, I18n._( "ENTER YOUR NAME:" ), centerX, nameLabelY, FontGenerator.CENTER ) );
        addScreen( myNameScreen = new AlignedTextScreen( myTitleFont, "NAME", centerX, nameY, FontGenerator.CENTER ) );
        addScreen( myCharSelector = new CharacterSelector( myTitleFont ) );

        final Rectangle selectorBounds = myCharSelector.bounds;
        selectorBounds.x = 0;
        selectorBounds.y = selectorY;
        selectorBounds.width = screen().width();
        selectorBounds.height = fontHeight * 8;

        final TextScreen textScreen = new TextScreen();
        textScreen.alignment = FontGenerator.CENTER;
        textScreen.font = myTextFont;
        textScreen.text = I18n._( "DRAG LEFT AND RIGHT TO CHOOSE CHARACTER. SINGLE TAP TO ADD CHARACTER TO NAME." );
        textScreen.updateRequired = true;
        addScreen( textScreen );

        final Rectangle helpBounds = textScreen.optionalBoundingBox = new Rectangle();
        helpBounds.x = 0;
        helpBounds.y = selectorBounds.y + selectorBounds.height / 2;
        helpBounds.width = screen().width();
        helpBounds.height = screen().height() - helpBounds.y;
        }

    public final void onInitEverytime() throws Exception
        {
        myScoreScreen.text = Integer.toString( myGameModel.player.score );
        }

    public final void onControlTick() throws Exception
        {
        updateAndHandleSoftkeys();
        animateBlinkingName();
        super.onControlTick();
        handleCharSelection();
        }

    private void updateAndHandleSoftkeys() throws Exception
        {
        final String accept = I18n._( "ACCEPT" );
        final String invalid = I18n._( "" );
        final String clear = I18n._( "CLEAR" );
        mySoftkeys.setSoftkeys( nameValid() ? accept : invalid, clear );

        final KeysHandler keys = keys();
        if ( keys.checkLeftSoftAndConsume() ) saveHiscoreIfNameValid();
        if ( keys.checkRightSoftAndConsume() ) removeLastChar();
        }

    private boolean nameValid()
        {
        return myCurrentName.length() >= 3;
        }

    private void saveHiscoreIfNameValid() throws Exception
        {
        if ( !nameValid() ) return;

        final Player player = myGameModel.player;
        final Level level = myGameModel.level;
        myHiscore.insert( player.score, level.levelNumberStartingAt1, myCurrentName );

        stack().popScreen( this );

        myMainLogic.postOnline( "New hiscore for " + myCurrentName + ": " + player.score );

        myMainLogic.showHiscoreWithoutUpdatingFirst();
        myMainLogic.saveHiscore();
        }

    private void removeLastChar()
        {
        if ( myCurrentName.length() == 0 ) return;
        myCurrentName = myCurrentName.substring( 0, myCurrentName.length() - 1 );
        }

    private void animateBlinkingName()
        {
        if ( myNameBlinkTicks < timing().ticksPerSecond ) myNameBlinkTicks++;
        else myNameBlinkTicks = 0;

        final boolean nameVisible = myNameBlinkTicks < timing().ticksPerSecond * 2 / 3;
        setVisibility( myNameScreen, nameVisible );
        }

    private void handleCharSelection()
        {
        final char selected = myCharSelector.getSelectedCharacterAndReset();
        if ( selected == CharacterSelector.NOTHING_SELECTED ) return;

        if ( selected == CharacterSelector.DELETE_CHARACTER ) removeLastChar();
        else addSelectedChar( selected );
        }

    private void addSelectedChar( final char aCharCode )
        {
        if ( nameMaxLength() ) return;
        myNameBuffer.setLength( 0 );
        myNameBuffer.append( myCurrentName );
        myNameBuffer.append( aCharCode );
        myCurrentName = myNameBuffer.toString();
        }

    private boolean nameMaxLength()
        {
        return myCurrentName.length() >= Hiscore.MAX_NAME_LENGTH;
        }

    public final void onDrawFrame()
        {
        updateNameScreen();
        super.onDrawFrame();
        }

    private void updateNameScreen()
        {
        myNameScreen.text = myCurrentName;
        }


    private int myNameBlinkTicks;

    private SoftkeysScreen mySoftkeys;

    private String myCurrentName = "DUDE";

    private AlignedTextScreen myNameScreen;

    private AlignedTextScreen myScoreScreen;

    private CharacterSelector myCharSelector;


    private final Hiscore myHiscore;

    private final MainLogic myMainLogic;

    private final GameModel myGameModel;

    private final FontGenerator myTextFont;

    private final FontGenerator myTitleFont;

    private final StringBuffer myNameBuffer = new StringBuffer();
    }
