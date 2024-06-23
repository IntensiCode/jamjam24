package net.intensicode.droidshock.screens;

import net.intensicode.core.*;
import net.intensicode.droidshock.game.*;
import net.intensicode.screens.*;
import net.intensicode.util.Log;

public final class BackgroundScreen extends MultiScreen
    {
    public BackgroundScreen( final GameContext aContext )
        {
        myVisuals = aContext.visualConfiguration();
        }

    // From ScreenBase

    public final void onInitOnce() throws Exception
        {
        //#if !LOW_MEM
        try
            {
            final ImageResource backgroundImage = myVisuals.skin.image( "background" );
            if ( backgroundImage == null || backgroundImage == myVisuals.skin.imageNotFound ) return;

            myBackgroundScreen = new ImageScreen( backgroundImage );
            myBackgroundScreen.positionMode = ImageScreen.MODE_ABSOLUTE;
            addScreen( myBackgroundScreen );
            }
        catch ( final Exception e )
            {
            //#if DEBUG
            Log.debug( "Failed loading background" );
            //#endif
            }
        //#endif
        }

    public void onInitEverytime() throws Exception
        {
        super.onInitEverytime();
        if ( myBackgroundScreen == null ) return;
        myBackgroundScreen.position.setTo( myVisuals.backgroundPosition );
        }

    public final void onDrawFrame()
        {
        //#if !ANDROID
        if ( myVisuals.bufferedContainer ) return;
        //#endif

        int colorARGB32 = DO_NOT_DRAW;

        //#if J2ME
        if ( myVisuals.darkBackground ) colorARGB32 = myVisuals.sharedBackgroundColorDark;
        else if ( myBackgroundScreen == null ) colorARGB32 = myVisuals.sharedBackgroundColor;
        else super.onDrawFrame();
        //#else
        //# super.onDrawFrame();
        //# if ( myVisuals.darkBackground ) colorARGB32 = myVisuals.sharedBackgroundColorDark;
        //# else if ( myBackgroundScreen == null ) colorARGB32 = myVisuals.sharedBackgroundColor;
        //#endif

        if ( colorARGB32 == DO_NOT_DRAW ) return;

        final DirectGraphics graphics = graphics();
        graphics.setColorARGB32( colorARGB32 );
        graphics.fillRect( 0, 0, screen().width(), screen().height() );
        }


    private ImageScreen myBackgroundScreen;

    private final VisualConfiguration myVisuals;

    private static final int DO_NOT_DRAW = 0;
    }
