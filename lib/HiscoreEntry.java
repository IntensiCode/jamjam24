package net.intensicode.droidshock.screens;

import net.intensicode.core.I18n;
import net.intensicode.droidshock.game.Hiscore;
import net.intensicode.graphics.FontGenerator;
import net.intensicode.screens.ScreenBase;
import net.intensicode.util.*;

public final class HiscoreEntry extends ScreenBase implements PositionableEntry
    {
    public final Position position = new Position();

    public boolean showLevel;


    public HiscoreEntry( final FontGenerator aFont )
        {
        Assert.notNull( "font valid", aFont );
        myFont = aFont;
        }

    public final void setData( final Hiscore aHiscore, final int aIndex )
        {
        Assert.notNull( "font valid", aHiscore );
        Assert.isTrue( "index valid", aIndex >= 0 && aIndex <= aHiscore.numberOfEntries() );
        myScore = String.valueOf( aHiscore.score( aIndex ) );
        myLevel = String.valueOf( aHiscore.level( aIndex ) );
        myName = String.valueOf( aHiscore.name( aIndex ) );

        if ( myLevel.equals( "0" ) ) myLevel = "";
        }

    // From PositionableEntry

    public final Position getPositionByReference()
        {
        return position;
        }

    public final void setAvailableWidth( final int aWidthInPixels )
        {
        myAvailableWidth = aWidthInPixels;
        }

    public final void updateTouchable()
        {
        }

    // From ScreenBase

    public final void onControlTick() throws Exception
        {
        }

    public final void onDrawFrame()
        {
        if ( myFont == null ) return;

        myBlitPos.setTo( position );

        myBlitPos.x += myAvailableWidth * 5 / 32;
        myFont.blitString( graphics(), myScore, myBlitPos, FontGenerator.HCENTER | FontGenerator.VCENTER );
        myBlitPos.x += myAvailableWidth * 9 / 32;
        if ( showLevel ) myFont.blitString( graphics(), myLevel, myBlitPos, FontGenerator.HCENTER | FontGenerator.VCENTER );
        myBlitPos.x += myAvailableWidth * 11 / 32;
        myFont.blitString( graphics(), myName, myBlitPos, FontGenerator.HCENTER | FontGenerator.VCENTER );
        }


    private int myAvailableWidth;

    private String myName = I18n._( "NAME" );

    private String myLevel = I18n._( "LEVEL" );

    private String myScore = I18n._( "SCORE" );

    private final FontGenerator myFont;

    private final Position myBlitPos = new Position();
    }
