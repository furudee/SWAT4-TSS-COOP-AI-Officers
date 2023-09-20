class DynamicLoadOutSpec extends LoadOutValidationBase
    perObjectConfig
    Config(DynamicLoadout);

var(DEBUG) config string Editor;

defaultproperties
{
    bStasis=true
	bDisableTick=true
    Physics=PHYS_None
    bHidden=true
    RemoteRole=ROLE_None
}