package net.intensicode.droidshock.screens;

import net.intensicode.droidshock.effects.*;
import net.intensicode.droidshock.game.*;
import net.intensicode.screens.*;

public final class SharedBackgroundScreen extends MultiScreen
    {
    public SharedBackgroundScreen( final GameContext aGameContext )
        {
        myGameContext = aGameContext;
        myVisuals = aGameContext.visualConfiguration();
        }

    // From MultiScreen

    public void onInitOnce() throws Exception
        {
        super.onInitOnce();

        if ( myVisuals.sharedBackgroundGradient )
            {
            final int from = myVisuals.gradientColorTop;
            final int to = myVisuals.gradientColorBottom;
            addScreen( new GradientScreen( from, to ) );
            }
        else
            {
            //#if DROIDSHOCK
            myVisuals.disableBackgroundImage = true;
            //#endif
            //#if FULL_FX
            if ( myVisuals.disableBackgroundImage )
                {
                addScreen( myClearScreen = new ClearScreen() );
                myClearScreen.clearColorARGB32 = myVisuals.sharedBackgroundColor;
                }
            else
                {
            try
                {
                addScreen( new ImageScreen( skin().image( "background" ) ) );
                }
                catch ( final Exception e )
                    {
                    addScreen( myClearScreen = new ClearScreen() );
                    myClearScreen.clearColorARGB32 = myVisuals.sharedBackgroundColor;
                    }
                }
            //#else
            //# addScreen( myClearScreen = new ClearScreen() );
            //# myClearScreen.clearColorARGB32 = myVisuals.sharedBackgroundColor;
            //#endif
            }

        //#if FULL_FX
        if ( myVisuals.sharedBackgroundBubbles )
            {
            addScreen( myBubbles = new BubblesScreen( myVisuals ) );
            }
        if ( myVisuals.sharedBackgroundTiles )
            {
            //#if !DISABLE_TILES
            addScreen( myTiles = new FallingTiles( myVisuals ) );
            //#endif
            //#if ENABLE_HEARTS
            //# addScreen( myHearts = new FallingHearts( myGameContext ) );
            //#endif
            }
        //#endif
        }

    //#if ORIENTATION_DYNAMIC

    public void onOrientationChanged() throws Exception
        {
        removeAllScreens();
        super.onOrientationChanged();
        onInitOnce();
        }

    //#endif

    public void onControlTick() throws Exception
        {
        super.onControlTick();

        if ( myClearScreen != null )
            {
            myClearScreen.clearColorARGB32 = myVisuals.darkBackground ? myVisuals.sharedBackgroundColorDark : myVisuals.sharedBackgroundColor;
            }

        //#if FULL_FX

        if ( myVisuals.sharedBackgroundBubbles )
            {
            setVisibility( myBubbles, !myVisuals.disableBubbleParticles );
            }

        //#if !DISABLE_TILES
        if ( myTiles != null ) setVisibility( myTiles, !myVisuals.disableFallingTiles );
        //#endif

        //#if ENABLE_HEARTS
        if ( myHearts != null ) setVisibility( myHearts, !myVisuals.disableFallingHearts );
        //#endif

        //#endif
        }


    //#if FULL_FX

    //#if ENABLE_HEARTS

    private FallingHearts myHearts;

    //#endif

    //#if !DISABLE_TILES

    private FallingTiles myTiles;

    //#endif

    private BubblesScreen myBubbles;

    //#endif

    private ClearScreen myClearScreen;

    private final GameContext myGameContext;

    private final VisualConfiguration myVisuals;
    }
