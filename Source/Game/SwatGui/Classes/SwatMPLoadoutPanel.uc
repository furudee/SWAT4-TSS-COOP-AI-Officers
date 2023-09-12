// ====================================================================
//  Class:  SwatGui.SwatMPLoadoutPanel
//  Parent: SwatGUIPanel
//
//  Menu to load map from entry screen.
// ====================================================================

class SwatMPLoadoutPanel extends SwatLoadoutPanel
    ;

var enum LoadOutOwner
{
    LoadOutOwner_Player,
    LoadOutOwner_RedOne,
    LoadOutOwner_RedTwo,
    LoadOutOwner_BlueOne,
    LoadOutOwner_BlueTwo
} ActiveLoadOutOwner;

var(SWATGui) private EditInline Config GUIButton MyNextOfficerButton;
var(SWATGui) private EditInline Config GUIButton MyPreviousOfficerButton;
var(SWATGui) private EditInline EditConst DynamicLoadOutSpec MyCurrentLoadOuts[LoadOutOwner.EnumCount] "holds all current loadout info";

///////////////////////////
// Initialization & Page Delegates
///////////////////////////
function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	SwatGuiController(Controller).SetMPLoadoutPanel(self);
	MyNextOfficerButton.OnClick=OnOfficerButtonClick;
	MyPreviousOfficerButton.OnClick=OnOfficerButtonClick;
}

function LoadMultiPlayerLoadout()
{
    //create the loadout & send to the server, then destroy it
    SpawnLoadouts();
    DestroyLoadouts();
}

protected function SpawnLoadouts() 
{
    local int i;
    for( i = 0; i < LoadOutOwner.EnumCount; i++ )
    {
        if( MyCurrentLoadOuts[ i ] != None )
            continue;
        
        ActiveLoadOutOwner=LoadOutOwner(i);
        LoadLoadOut( "Current"$GetConfigName(ActiveLoadOutOwner), true );
    	MyCurrentLoadOuts[ i ] = MyCurrentLoadOut;
    	MyCurrentLoadOut = None;
    }
    
    ActiveLoadOutOwner = LoadOutOwner_Player;
    MyCurrentLoadOut = MyCurrentLoadOuts[ ActiveLoadOutOwner ];

    //LoadLoadOut( "CurrentMultiplayerLoadOut", true );
}

protected function DestroyLoadouts() 
{
    local int i;

    //destroy the actual loadouts here?
    for( i = 0; i < LoadOutOwner.EnumCount; i++ )
    {
        if( MyCurrentLoadOuts[i] != None )
            MyCurrentLoadOuts[i].destroy();
        MyCurrentLoadOuts[i] = None;
    }
	
    if( MyCurrentLoadOut != None )
        MyCurrentLoadOut.destroy();
    MyCurrentLoadOut = None;
}

///////////////////////////
//Utility functions used for managing loadouts
///////////////////////////
function LoadLoadOut( String loadOutName, optional bool bForceSpawn )
{
    Super.LoadLoadOut( loadOutName, bForceSpawn );

//    MyCurrentLoadOut.ValidateLoadOutSpec();
    //SwatGUIController(Controller).SetMPLoadOut( MyCurrentLoadOut );
}

function ChangeLoadOut( Pocket thePocket )
{
    local class<actor> theItem;
	log("[dkaplan] changing loadout for pocket "$GetEnum(Pocket,thePocket) );
    Super.ChangeLoadOut( thePocket );
    //SaveLoadOut( "CurrentMultiPlayerLoadout" ); //save to current loadout

    switch (thePocket)
    {
        case Pocket_PrimaryWeapon:
        case Pocket_PrimaryAmmo:
            SwatGUIController(Controller).SetMPLoadOutPocketWeapon( Pocket_PrimaryWeapon, MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_PrimaryWeapon], MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_PrimaryAmmo] );
            break;
        case Pocket_SecondaryWeapon:
        case Pocket_SecondaryAmmo:
            SwatGUIController(Controller).SetMPLoadOutPocketWeapon( Pocket_SecondaryWeapon, MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_SecondaryWeapon], MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_SecondaryAmmo] );
            break;
        case Pocket_Breaching:
            SwatGUIController(Controller).SetMPLoadOutPocketItem( Pocket.Pocket_Breaching, MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_Breaching] );
            SwatGUIController(Controller).SetMPLoadOutPocketItem( Pocket.Pocket_HiddenC2Charge1, MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_HiddenC2Charge1] );
            SwatGUIController(Controller).SetMPLoadOutPocketItem( Pocket.Pocket_HiddenC2Charge2, MyCurrentLoadOut.LoadOutSpec[Pocket.Pocket_HiddenC2Charge2] );
            break;
		case Pocket_CustomSkin:
			SwatGUIController(Controller).SetMPLoadOutPocketCustomSkin( Pocket_CustomSkin, String(EquipmentList[thePocket].GetObject()) );
			break;
        default:
            theItem = class<actor>(EquipmentList[thePocket].GetObject());
            SwatGUIController(Controller).SetMPLoadOutPocketItem( thePocket, theItem );
            break;
    }
}

function bool CheckValidity( eNetworkValidity type )
{
    return (type == NETVALID_MPOnly) || (Super.CheckValidity( type ));
}

function bool CheckTeamValidity( eTeamValidity type )
{
	local bool IsSuspect;

	if (PlayerOwner().Level.IsPlayingCOOP)
	{
		IsSuspect = false; // In coop the player is never a suspect
	}
	else
	{
		assert(PlayerOwner() != None);

		// If we don't have access to a team object assume the item is valid for the players future team
		// This case should only be true right after a level change when the player has no control over their team or loadout anyway
		// but we don't want the client to reset the loadout based on team without knowing the team. The server will never allow
		// an illegal loadout anyway so this is just a lax client side check.
		if (PlayerOwner().PlayerReplicationInfo == None || NetTeam(PlayerOwner().PlayerReplicationInfo.Team) == None)
			return true;

		// The suspect team always has a team number of 1
		IsSuspect = (NetTeam(PlayerOwner().PlayerReplicationInfo.Team).GetTeamNumber() == 1);
	}

	       // Item is usable by any team   or // Suspect only item and player is suspect    or // SWAT only item and player is not a suspect
	return Super.CheckTeamValidity( type ) || (type == TEAMVALID_SuspectsOnly && IsSuspect) || (type == TEAMVALID_SWATOnly && !IsSuspect);
}

function String GetConfigName( LoadOutOwner theOfficer )
{
    local String ret;
    switch (theOfficer)
    {
        case LoadOutOwner_Player:
            ret="MultiplayerLoadOut";
            break;
        case LoadOutOwner_RedOne:
            ret="OfficerRedOneLoadOut";
            break;
        case LoadOutOwner_RedTwo:
            ret="OfficerRedTwoLoadOut";
            break;
        case LoadOutOwner_BlueOne:
            ret="OfficerBlueOneLoadOut";
            break;
        case LoadOutOwner_BlueTwo:
            ret="OfficerBlueTwoLoadOut";
            break;
    }
    return ret;
}

private function OnOfficerButtonClick(GuiComponent Sender)
{
	switch(Sender)
	{
		case MyNextOfficerButton:
			if( ActiveLoadOutOwner == LoadOutOwner_BlueTwo )
				ActiveLoadOutOwner = LoadOutOwner_Player;
			else ActiveLoadOutOwner = LoadOutOwner(ActiveLoadOutOwner + 1);
			break;
		case MyPreviousOfficerButton:
			if( ActiveLoadOutOwner == LoadOutOwner_Player )
				ActiveLoadOutOwner = LoadOutOwner_BlueTwo;
			else ActiveLoadOutOwner = LoadOutOwner(ActiveLoadOutOwner - 1);
	}
	
	MyCurrentLoadOut = MyCurrentLoadOuts[ActiveLoadOutOwner];
	InitialDisplay();
	log("ActiveLoadOutOwner: "$ActiveLoadOutOwner$" - "$GetConfigName(ActiveLoadOutOwner));
}

defaultproperties
{
}
