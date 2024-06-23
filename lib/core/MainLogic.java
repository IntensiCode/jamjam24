package net.intensicode.droidshock.game;

import net.intensicode.screens.ScreenBase;
import net.intensicode.screens.SoftkeysScreen;

import java.io.IOException;

public interface MainLogic
    {
    void postOnline( String aMessage );

    //#if TWITTER

    TwitterAPI twitter();

    void tweet( String aMessage );

    //#endif

    //#if FACEBOOK

    FacebookAPI facebook();

    void postToFacebook( String aMessage );

    //#endif

    Hiscore hiscore();

    Options options();

    Controls controls();

    GameContext visualContext();

    GameController gameController();

    VisualConfiguration visualConfig();

    SoftkeysScreen sharedSoftkeys() throws Exception;

    ScreenBase sharedBackground() throws Exception;

    //#if ACHIEVEMENTS

    net.intensicode.droidshock.screens.UnlockedAchievementScreen unlockedAchievementScreen() throws Exception;

    //#endif

    AchievementsVault achievementsVault() throws IOException;

    void showTitle() throws Exception;

    void showMainMenu() throws Exception;

    void showHelp() throws Exception;

    void showHiscoreWithoutUpdatingFirst() throws Exception;

    //#if ACHIEVEMENTS

    void showAchievements() throws Exception;

    void showAchievement( String aAchievementId ) throws Exception;

    //#endif

    //#if ONLINE

    void updateHiscore() throws Exception;

    void goOnline() throws Exception;

    void goOnlineShowingAchievements() throws Exception;

    //#endif

    //#if FEEDBACK

    void triggerFeedback();

    //#endif

    //#if UPDATE

    void triggerUpdate();

    boolean isUpdateAvailable();

    //#endif

    void loadOrStartGame() throws Exception;

    void startGame( final boolean aEraseOldState ) throws Exception;

    void enterHiscore() throws Exception;

    void saveHiscore() throws Exception;

    void saveGame();

    void loadGame() throws Exception;

    void exit();
    }
