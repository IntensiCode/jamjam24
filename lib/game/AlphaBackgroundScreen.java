package net.intensicode.droidshock.screens;

import net.intensicode.core.DirectGraphics;
import net.intensicode.screens.ScreenBase;

public final class AlphaBackgroundScreen extends ScreenBase
    {
    public AlphaBackgroundScreen()
        {
        }

    // From ScreenBase

    public final void onControlTick()
        {
        myAlphaSteps += 12 * 255 / timing().ticksPerSecond;
        if ( myAlphaSteps > 255 ) myAlphaSteps = 255;
        }

    public final void onDrawFrame()
        {
        if ( myAlphaSteps == 0 ) return;

        final DirectGraphics gc = graphics();
        gc.setColorARGB32( myAlphaSteps << 24 );
        gc.fillRect( 0, 0, screen().width(), screen().height() );

        myAlphaSteps = 0;
        }

    private int myAlphaSteps = 0;
    }
