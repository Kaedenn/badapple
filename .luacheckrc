exclude_files = {
}

files["settings.lua"] = {
  read_globals = {
    -- "data/scripts/lib/mod_settings.lua"
    "MOD_SETTING_SCOPE_RUNTIME",
    "mod_setting_text",
    "mod_settings_get_version",
    "mod_settings_gui",
    "mod_settings_gui_count",
  }
}

files["files/timeline.lua"] = {
  read_globals = {
    -- "data/scripts/lib/utilities.lua"
    "get_players",
    -- "mods/badapple/files/utility.lua"
    "to_frames",
    "is_running",
    "get_stage",
    "get_trigger_frame",
    "get_image_size",
  }
}

files["init.lua"] = {
  read_globals = {
    -- "data/scripts/lib/utilities.lua"
    "get_players",
    -- "mods/badapple/files/timeline.lua"
    "IMAGE_WIDTH",
    "IMAGE_HEIGHT",
    "STAGES",
    "get_stage",
    "get_stage_named",
    "is_running",
    "get_trigger_frame",
    "init_timeline",
  }
}

read_globals = {
  "____cached_func",
  "print_error",
  "print",
  "Reflection_RegisterProjectile",
  "RegisterPerk",
  "GameRegisterStatusEffect",
  "RegisterStreamingEvent",
  "DEBUG_GameReset",
  "do_mod_appends",
  "_ConfigGunActionInfo_ReadToGame",
  "EntityLoad",
  "EntityLoadEndGameItem",
  "EntityLoadCameraBound",
  "EntityLoadToEntity",
  "EntitySave",
  "EntityCreateNew",
  "EntityKill",
  "EntityGetIsAlive",
  "EntityAddComponent",
  "EntityRemoveComponent",
  "EntityGetAllComponents",
  "EntityGetComponent",
  "EntityGetFirstComponent",
  "EntityGetComponentIncludingDisabled",
  "EntityGetFirstComponentIncludingDisabled",
  "EntitySetTransform",
  "EntityApplyTransform",
  "EntityGetTransform",
  "EntityAddChild",
  "EntityGetAllChildren",
  "EntityGetParent",
  "EntityGetRootEntity",
  "EntityRemoveFromParent",
  "EntitySetComponentsWithTagEnabled",
  "EntitySetComponentIsEnabled",
  "EntityGetName",
  "EntitySetName",
  "EntityGetTags",
  "EntityGetWithTag",
  "EntityGetInRadius",
  "EntityGetInRadiusWithTag",
  "EntityGetClosest",
  "EntityGetClosestWithTag",
  "EntityGetWithName",
  "EntityAddTag",
  "EntityRemoveTag",
  "EntityHasTag",
  "EntityGetFilename",
  "EntitiesGetMaxID",
  "ComponentGetValue",
  "ComponentGetValueBool",
  "ComponentGetValueInt",
  "ComponentGetValueFloat",
  "ComponentGetValueVector2",
  "ComponentSetValue",
  "ComponentSetValueVector2",
  "ComponentSetValueValueRange",
  "ComponentSetValueValueRangeInt",
  "ComponentSetMetaCustom",
  "ComponentGetMetaCustom",
  "ComponentObjectGetValue",
  "ComponentObjectSetValue",
  "ComponentAddTag",
  "ComponentRemoveTag",
  "ComponentGetTags",
  "ComponentHasTag",
  "ComponentGetValue2",
  "ComponentSetValue2",
  "ComponentObjectGetValue2",
  "ComponentObjectSetValue2",
  "EntityAddComponent2",
  "ComponentGetVectorSize",
  "ComponentGetVectorValue",
  "ComponentGetVector",
  "ComponentGetIsEnabled",
  "ComponentGetEntity",
  "ComponentGetMembers",
  "ComponentObjectGetMembers",
  "ComponentGetTypeName",
  "GetUpdatedEntityID",
  "GetUpdatedComponentID",
  "SetTimeOut",
  "RegisterSpawnFunction",
  "SpawnActionItem",
  "SpawnStash",
  "SpawnApparition",
  "LoadEntityToStash",
  "AddMaterialInventoryMaterial",
  "RemoveMaterialInventoryMaterial",
  "GetMaterialInventoryMainMaterial",
  "GameScreenshake",
  "GameOnCompleted",
  "GameGiveAchievement",
  "GameDoEnding2",
  "GetParallelWorldPosition",
  "BiomeMapLoad_KeepPlayer",
  "BiomeMapLoad",
  "BiomeSetValue",
  "BiomeGetValue",
  "BiomeObjectSetValue",
  "BiomeVegetationSetValue",
  "BiomeMaterialSetValue",
  "BiomeMaterialGetValue",
  "GameIsIntroPlaying",
  "GameGetIsGamepadConnected",
  "GameGetWorldStateEntity",
  "GameGetPlayerStatsEntity",
  "GameGetOrbCountAllTime",
  "GameGetOrbCountThisRun",
  "GameGetOrbCollectedThisRun",
  "GameGetOrbCollectedAllTime",
  "GameClearOrbsFoundThisRun",
  "GameGetOrbCountTotal",
  "CellFactory_GetName",
  "CellFactory_GetType",
  "CellFactory_GetUIName",
  "CellFactory_GetAllLiquids",
  "CellFactory_GetAllSands",
  "CellFactory_GetAllGases",
  "CellFactory_GetAllFires",
  "CellFactory_GetAllSolids",
  "CellFactory_GetTags",
  "CellFactory_HasTag",
  "GameGetCameraPos",
  "GameSetCameraPos",
  "GameSetCameraFree",
  "GameGetCameraBounds",
  "GameRegenItemAction",
  "GameRegenItemActionsInContainer",
  "GameRegenItemActionsInPlayer",
  "GameKillInventoryItem",
  "GamePickUpInventoryItem",
  "GameGetAllInventoryItems",
  "GameDropAllItems",
  "GameDropPlayerInventoryItems",
  "GameDestroyInventoryItems",
  "GameIsInventoryOpen",
  "GameTriggerGameOver",
  "LoadPixelScene",
  "LoadBackgroundSprite",
  "RemovePixelSceneBackgroundSprite",
  "RemovePixelSceneBackgroundSprites",
  "GameCreateCosmeticParticle",
  "GameCreateParticle",
  "GameCreateSpriteForXFrames",
  "GameShootProjectile",
  "EntityInflictDamage",
  "EntityIngestMaterial",
  "EntityRemoveIngestionStatusEffect",
  "EntityRemoveStainStatusEffect",
  "EntityAddRandomStains",
  "EntitySetDamageFromMaterial",
  "EntityRefreshSprite",
  "EntityGetWandCapacity",
  "EntityGetHotspot",
  "GamePlayAnimation",
  "GameGetVelocityCompVelocity",
  "GameGetGameEffect",
  "GameGetGameEffectCount",
  "LoadGameEffectEntityTo",
  "GetGameEffectLoadTo",
  "PolymorphTableAddEntity",
  "PolymorphTableRemoveEntity",
  "PolymorphTableGet",
  "PolymorphTableSet",
  "SetPlayerSpawnLocation",
  "UnlockItem",
  "GameGetPotionColorUint",
  "EntityGetFirstHitboxCenter",
  "Raytrace",
  "RaytraceSurfaces",
  "RaytraceSurfacesAndLiquiform",
  "RaytracePlatforms",
  "FindFreePositionForBody",
  "GetSurfaceNormal",
  "GameGetSkyVisibility",
  "GameGetFogOfWar",
  "GameGetFogOfWarBilinear",
  "GameSetFogOfWar",
  "DoesWorldExistAt",
  "StringToHerdId",
  "HerdIdToString",
  "GetHerdRelation",
  "EntityGetHerdRelation",
  "EntityGetHerdRelationSafe",
  "GenomeSetHerdId",
  "EntityGetClosestWormAttractor",
  "EntityGetClosestWormDetractor",
  "GamePrint",
  "GamePrintImportant",
  "DEBUG_GetMouseWorld",
  "DEBUG_MARK",
  "GameGetFrameNum",
  "GameGetRealWorldTimeSinceStarted",
  "InputIsKeyDown",
  "InputIsKeyJustDown",
  "InputIsKeyJustUp",
  "InputGetMousePosOnScreen",
  "InputIsMouseButtonDown",
  "InputIsMouseButtonJustDown",
  "InputIsMouseButtonJustUp",
  "InputIsJoystickButtonDown",
  "InputIsJoystickButtonJustDown",
  "InputGetJoystickAnalogButton",
  "InputIsJoystickConnected",
  "InputGetJoystickAnalogStick",
  "IsPlayer",
  "IsInvisible",
  "GameIsDailyRun",
  "GameIsDailyRunOrDailyPracticeRun",
  "GameIsModeFullyDeterministic",
  "GlobalsSetValue",
  "GlobalsGetValue",
  "MagicNumbersGetValue",
  "SetWorldSeed",
  "SessionNumbersGetValue",
  "SessionNumbersSetValue",
  "SessionNumbersSave",
  "AutosaveDisable",
  "StatsGetValue",
  "StatsGlobalGetValue",
  "StatsBiomeGetValue",
  "StatsBiomeReset",
  "StatsLogPlayerKill",
  "CreateItemActionEntity",
  "GetRandomActionWithType",
  "GetRandomAction",
  "GameGetDateAndTimeUTC",
  "GameGetDateAndTimeLocal",
  "GameEmitRainParticles",
  "GameCutThroughWorldVertical",
  "BiomeMapSetSize",
  "BiomeMapGetSize",
  "BiomeMapSetPixel",
  "BiomeMapGetPixel",
  "BiomeMapConvertPixelFromUintToInt",
  "BiomeMapLoadImage",
  "BiomeMapLoadImageCropped",
  "BiomeMapGetVerticalPositionInsideBiome",
  "BiomeMapGetName",
  "SetRandomSeed",
  "Random",
  "Randomf",
  "RandomDistribution",
  "RandomDistributionf",
  "ProceduralRandom",
  "ProceduralRandomf",
  "ProceduralRandomi",
  "PhysicsAddBodyImage",
  "PhysicsAddBodyCreateBox",
  "PhysicsAddJoint",
  "PhysicsApplyForce",
  "PhysicsApplyTorque",
  "PhysicsApplyTorqueToComponent",
  "PhysicsApplyForceOnArea",
  "PhysicsRemoveJoints",
  "PhysicsSetStatic",
  "PhysicsGetComponentVelocity",
  "PhysicsGetComponentAngularVelocity",
  "PhysicsComponentGetTransform",
  "PhysicsComponentSetTransform",
  "PhysicsBodyIDGetFromEntity",
  "PhysicsBodyIDQueryBodies",
  "PhysicsBodyIDGetTransform",
  "PhysicsBodyIDSetTransform",
  "PhysicsBodyIDApplyForce",
  "PhysicsBodyIDApplyLinearImpulse",
  "PhysicsBodyIDApplyTorque",
  "PhysicsBodyIDGetWorldCenter",
  "PhysicsBodyIDGetDamping",
  "PhysicsBodyIDSetDamping",
  "PhysicsBodyIDGetGravityScale",
  "PhysicsBodyIDSetGravityScale",
  "PhysicsBodyIDGetBodyAABB",
  "PhysicsBody2InitFromComponents",
  "PhysicsPosToGamePos",
  "GamePosToPhysicsPos",
  "PhysicsVecToGameVec",
  "GameVecToPhysicsVec",
  "LooseChunk",
  "VerletApplyCircularForce",
  "VerletApplyDirectionalForce",
  "AddFlagPersistent",
  "RemoveFlagPersistent",
  "HasFlagPersistent",
  "GameAddFlagRun",
  "GameRemoveFlagRun",
  "GameHasFlagRun",
  "GameTriggerMusicEvent",
  "GameTriggerMusicCue",
  "GameTriggerMusicFadeOutAndDequeueAll",
  "GamePlaySound",
  "GameEntityPlaySound",
  "GameEntityPlaySoundLoop",
  "GameSetPostFxParameter",
  "GameUnsetPostFxParameter",
  "GameSetPostFxTextureParameter",
  "GameUnsetPostFxTextureParameter",
  "GameTextGetTranslatedOrNot",
  "GameTextGet",
  "GuiCreate",
  "GuiDestroy",
  "GuiStartFrame",
  "GuiOptionsAdd",
  "GuiOptionsRemove",
  "GuiOptionsClear",
  "GuiOptionsAddForNextWidget",
  "GuiColorSetForNextWidget",
  "GuiZSet",
  "GuiZSetForNextWidget",
  "GuiIdPush",
  "GuiIdPushString",
  "GuiIdPop",
  "GuiAnimateBegin",
  "GuiAnimateEnd",
  "GuiAnimateAlphaFadeIn",
  "GuiAnimateScaleIn",
  "GuiText",
  "GuiTextCentered",
  "GuiImage",
  "GuiImageNinePiece",
  "GuiButton",
  "GuiImageButton",
  "GuiSlider",
  "GuiTextInput",
  "GuiBeginAutoBox",
  "GuiEndAutoBoxNinePiece",
  "GuiTooltip",
  "GuiBeginScrollContainer",
  "GuiEndScrollContainer",
  "GuiLayoutBeginHorizontal",
  "GuiLayoutBeginVertical",
  "GuiLayoutAddHorizontalSpacing",
  "GuiLayoutAddVerticalSpacing",
  "GuiLayoutEnd",
  "GuiLayoutBeginLayer",
  "GuiLayoutEndLayer",
  "GuiGetScreenDimensions",
  "GuiGetTextDimensions",
  "GuiGetImageDimensions",
  "GuiGetPreviousWidgetInfo",
  "GameIsBetaBuild",
  "DebugGetIsDevBuild",
  "DebugEnableTrailerMode",
  "GameGetIsTrailerModeEnabled",
  "Debug_SaveTestPlayer",
  "DebugBiomeMapGetFilename",
  "EntityConvertToMaterial",
  "ConvertEverythingToGold",
  "ConvertMaterialEverywhere",
  "ConvertMaterialOnAreaInstantly",
  "LoadRagdoll",
  "GetDailyPracticeRunSeed",
  "ModIsEnabled",
  "ModGetActiveModIDs",
  "ModGetAPIVersion",
  "ModDoesFileExist",
  "ModMaterialFilesGet",
  "ModSettingGet",
  "ModSettingSet",
  "ModSettingGetNextValue",
  "ModSettingSetNextValue",
  "ModSettingRemove",
  "ModSettingGetCount",
  "ModSettingGetAtIndex",
  "StreamingGetIsConnected",
  "StreamingGetConnectedChannelName",
  "StreamingGetVotingCycleDurationFrames",
  "StreamingGetRandomViewerName",
  "StreamingGetSettingsGhostsNamedAfterViewers",
  "StreamingSetCustomPhaseDurations",
  "StreamingForceNewVoting",
  "StreamingSetVotingEnabled",
  "ModLuaFileAppend",
  "ModLuaFileGetAppends",
  "ModLuaFileSetAppends",
  "ModTextFileGetContent",
  "ModTextFileSetContent",
  "ModTextFileWhoSetContent",
  "ModImageMakeEditable",
  "ModImageIdFromFilename",
  "ModImageGetPixel",
  "ModImageSetPixel",
  "ModImageWhoSetContent",
  "ModImageDoesExist",
  "ModMagicNumbersFileAdd",
  "ModMaterialsFileAdd",
  "ModRegisterAudioEventMappings",
  "ModRegisterMusicBank",
  "ModDevGenerateSpriteUVsForDirectory",
  "RegisterProjectile",
  "RegisterGunAction",
  "RegisterGunShotEffects",
  "BeginProjectile",
  "EndProjectile",
  "BeginTriggerTimer",
  "BeginTriggerHitWorld",
  "BeginTriggerDeath",
  "EndTrigger",
  "SetProjectileConfigs",
  "StartReload",
  "ActionUsesRemainingChanged",
  "ActionUsed",
  "LogAction",
  "OnActionPlayed",
  "OnNotEnoughManaForAction",
  "BaabInstruction",
  "SetValueNumber",
  "GetValueNumber",
  "SetValueInteger",
  "GetValueInteger",
  "SetValueBool",
  "GetValueBool",
  "dofile",
  "dofile_once",
}

-- vim: set filetype=lua:
