package net.intensicode.core;

import net.intensicode.io.StorageIO;

import java.io.IOException;

public interface StorageManager
    {
    boolean hasData( StorageIO aStorageIO );

    void erase( StorageIO aStorageIO );

    void load( StorageIO aStorageIO ) throws IOException;

    void save( StorageIO aStorageIO ) throws IOException;
    }
