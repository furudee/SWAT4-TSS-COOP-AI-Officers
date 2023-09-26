class DynamicLoadOutSpec extends LoadOutValidationBase
    perObjectConfig
    Config(DynamicLoadout);

import enum EEntryType from SwatStartPointBase;

var(DEBUG) config string Editor;
var(DEBUG) config bool bSpawn;
var(DEBUG) config EEntryType Entrypoint;

defaultproperties
{
    bStasis=true
	bDisableTick=true
    Physics=PHYS_None
    bHidden=true
    RemoteRole=ROLE_None
}