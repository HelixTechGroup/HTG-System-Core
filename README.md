# HTG-System-Core
 This is the Core mod used by all HelixTechGroup projects. Its a set of tools common to all modules in the Regenesys Project and can be utilized by all modders.

 If you find a bug or have a question about the mod, please post it on the [Bug page at Nexus Mods](https://www.nexusmods.com/starfield/mods/12783?tab=bugs), or in the [GitHub issues page](https://github.com/HelixTechGroup/HTG-System-Core/issues). 

It includes the following:

Extended forms of base types to be used by scripts in other modules.
    Attempts to extend base types without sideloading to allow for compatibility with consoles
    Built-in event loop to help with a more thread-safe workflow
            Easily extend to include custom events utilitizing the OnTimer Event
            Supported Events
                Initialization
                Initial Run
                Startup
                Shutdown
                Main
    Extended Forms
        ActivatorExt
        ActiveMagicEffectExt
        ObjectReferenceExt
        PerkExt
        QuestExt
        RefCollectionAliasExt
        ReferenceAliasExt
        ScriptObjectExt
        TerminalMenuExt

Utility classes
    Armor         
    Float
    Form
    Int
    Timer
    Common type array helper functions
        Float
        Form
        Int

Addtional collection types
        Dynamic arrays (Lists)
            Easily extendable to add lists for custom types
        Dictionaries (Key-Value pairs)
            Var and Form types

Features
        System Utilities
            configured on a quest level via RefernceAlias
            Logger
            Utility classes                     
        A built-in system for creating centralized management via a Dataslate
            Utilizes the TerminalMenu type
            Menus can be dynamically added, removed, and configured
        Equipment tracking on a quest alias on a single reference or a collection.
            A Player Tracker is integrated into the module
        A suit of armor that can mimic the appearance of any registered armor
        Unity integration

This is a Work-In-Progress and many more features are planned.