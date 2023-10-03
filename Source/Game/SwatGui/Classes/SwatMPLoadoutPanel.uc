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

import enum EEntryType from SwatGame.SwatStartPointBase;

var(SWATGui) private EditInline Config GUIButton 				MyNextOfficerButton;
var(SWATGui) private EditInline Config GUIButton 				MyPreviousOfficerButton;
var(SWATGui) private EditInline Config GUIButton 				MySaveLoadoutButton;
var(SWATGui) private EditInline Config GUILabel 				MyLoadoutLabel;
var(SWATGui) private EditInline Config GUILabel 				MySpawnLabel;
var(SWATGui) private EditInline Config GUILabel 				MyEntrypointLabel;
var(SWATGui) private EditInline Config GUICheckBoxButton		MySpawnButton;
var(SWATGui) private EditInline Config GUIComboBox 				MyEntrypointBox;

var(SWATGui) private EditInline EditConst DynamicLoadOutSpec	MyCurrentLoadOuts[LoadOutOwner.EnumCount] "holds all current loadout info";
var private bool bHasReceivedLoadouts; // only need to retrieve loadouts from server once

///////////////////////////
// Initialization & Page Delegates
///////////////////////////
function InitComponent(GUIComponent MyOwner)
{
	local int i;
	Super.InitComponent(MyOwner);
	SwatGuiController(Controller).SetMPLoadoutPanel(self);
	
	for(i = 0; i < EEntryType.EnumCount; i++)
	{
		MyEntrypointBox.AddItem( Mid( String( GetEnum(EEntryType, i) ), 3 ) );
	}
	MyEntrypointBox.SetIndex(0);
	
	MyNextOfficerButton.OnClick=OnOfficerButtonClick;
	MyPreviousOfficerButton.OnClick=OnOfficerButtonClick;
	MySpawnButton.OnClick=OnSpawnButtonClick;
	MyEntrypointBox.OnChange=OnEntrypointChange;
	MySaveLoadoutButton.OnClick=OnSaveLoadoutButtonClick;
	
	if( !PlayerOwner().Level.IsPlayingCOOP )
	{
		MyNextOfficerButton.DisableComponent();
		MyPreviousOfficerButton.DisableComponent();
		MySpawnButton.DisableComponent();
		MyEntrypointBox.DisableComponent();
	}
}

function LoadMultiPlayerLoadout()
{
    //create the loadout & send to the server, then destroy it
	log(self$"::LoadMultiPlayerLoadout");
	/*
    SpawnLoadouts();
    DestroyLoadouts();
	*/
}

protected function SpawnLoadouts() 
{
    local int i;
	log(self$" :: SpawnLoadouts");
    for( i = 0; i < LoadOutOwner.EnumCount; i++ )
    {
        if( MyCurrentLoadOuts[ i ] != None )
            continue;
        
        ActiveLoadOutOwner=LoadOutOwner(i);
        LoadLoadOut( GetConfigName(ActiveLoadOutOwner), true );
    	MyCurrentLoadOuts[ i ] = MyCurrentLoadOut;
    	MyCurrentLoadOut = None;
    }
    
    ActiveLoadOutOwner = LoadOutOwner_Player;
    MyCurrentLoadOut = MyCurrentLoadOuts[ ActiveLoadOutOwner ];
	MyLoadoutLabel.SetCaption( "Current loadout: "$GetHumanReadableLoadout(GetConfigName(ActiveLoadOutOwner)) );
	SetSpawnAndEntryButton();
	bHasReceivedLoadouts = true;
}

protected function DestroyLoadouts() 
{
	local int i;
	log(self$" :: DestroyLoadouts");

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
	// will retrieve AI loadout from server, otherwise load from config
	if(!bHasReceivedLoadouts)
		Super.LoadLoadOut( loadOutName, bForceSpawn );
	else Super.LoadLoadOut( loadOutName, false );

//    MyCurrentLoadOut.ValidateLoadOutSpec();
	if(loadOutName == "CurrentMultiplayerLoadOut")
		SwatGUIController(Controller).SetMPLoadOut( MyCurrentLoadOut );
}

function ChangeLoadOut( Pocket thePocket )
{
    local class<actor> theItem;
	log("[dkaplan] changing loadout for pocket "$GetEnum(Pocket,thePocket) );
    Super.ChangeLoadOut( thePocket );

	/*
	if(ActiveLoadOutOwner == LoadOutOwner_Player)
	{
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
	*/
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
            ret="CurrentMultiplayerLoadOut";
            break;
        case LoadOutOwner_RedOne:
            ret="CurrentMultiplayerOfficerRedOneLoadOut";
            break;
        case LoadOutOwner_RedTwo:
            ret="CurrentMultiplayerOfficerRedTwoLoadOut";
            break;
        case LoadOutOwner_BlueOne:
            ret="CurrentMultiplayerOfficerBlueOneLoadOut";
            break;
        case LoadOutOwner_BlueTwo:
            ret="CurrentMultiplayerOfficerBlueTwoLoadOut";
            break;
    }
    return ret;
}

function CheckUpdatedLoadout( String updatedLoadout )
{
	local String currentLoadout;
	local DynamicLoadOutSpec newLoadout;
	local int i;
	
	log(self$"::CheckUpdatedLoadout updatedLoadout "$updatedLoadout);
	for(i = 0; i < LoadOutOwner.EnumCount; i++)
	{		
		currentLoadout = GetConfigName(LoadOutOwner(i));
		if( updatedLoadout == currentLoadout )
		{
			newLoadout = PlayerOwner().Spawn( class'DynamicLoadOutSpec', None, name( updatedLoadout ) );
			PlayerOwner().ClientMessage(
				"Received loadout for: "$GetHumanReadableLoadout(updatedLoadout)$
				" | Spawn: "$newLoadout.bSpawn$
				" | Entrypoint: "$Mid( GetEnum( EEntryType, newLoadout.Entrypoint ), 3)$
				" | Edited by: "$newLoadout.Editor, 'Say');
			
			log(
				"Received loadout for: "$GetHumanReadableLoadout(updatedLoadout)$
				" | Spawn: "$newLoadout.bSpawn$
				" | Entrypoint: "$Mid( GetEnum( EEntryType, newLoadout.Entrypoint ), 3)$
				" | Edited by: "$newLoadout.Editor);
			
			// has not returned from first SpawnLoadouts() so its handled there
			if(MyCurrentLoadOuts[i] == None)
			{
				newLoadout.destroy();
				continue;
			}
				
			MyCurrentLoadOuts[i].destroy();
			MyCurrentLoadOuts[i] = newLoadout;
			
			currentLoadout = GetConfigName(ActiveLoadOutOwner);
			if(currentLoadout == updatedLoadout)
			{
				MyCurrentLoadOut = MyCurrentLoadOuts[i];
				SetSpawnAndEntryButton();
			}
			InitialDisplay();
			break;
		}
	}
}

private function OnOfficerButtonClick(GuiComponent Sender)
{
	switch(Sender)
	{
		case MyNextOfficerButton:
			if( ActiveLoadOutOwner == LoadOutOwner_BlueTwo )
				ActiveLoadOutOwner = LoadOutOwner_Player;
			else ActiveLoadOutOwner = LoadOutOwner(ActiveLoadOutOwner + 1); // epic random compiler error Type mismatch in '=': expected Byte, got Byte
			break;
		case MyPreviousOfficerButton:
			if( ActiveLoadOutOwner == LoadOutOwner_Player )
				ActiveLoadOutOwner = LoadOutOwner_BlueTwo;
			else ActiveLoadOutOwner = LoadOutOwner(ActiveLoadOutOwner - 1);
	}
	
	MyLoadoutLabel.SetCaption( "Current loadout: "$GetHumanReadableLoadout(GetConfigName(ActiveLoadOutOwner)) );
	LoadLoadOut( GetConfigName(ActiveLoadOutOwner), false );
	SetSpawnAndEntryButton();
	InitialDisplay();
	log(self$"::OnOfficerButtonClick | ActiveLoadOutOwner: "$ActiveLoadOutOwner);
}

private function OnSpawnButtonClick(GuiComponent Sender)
{
	MyCurrentLoadOut.bSpawn = MySpawnButton.bChecked;
}

private function OnEntrypointChange(GuiComponent Sender)
{
	MyCurrentLoadOut.Entrypoint = EEntryType( MyEntrypointBox.GetIndex() );
}

private function SetSpawnAndEntryButton()
{
	local DynamicLoadOutSpec Loadout;
	
	if(ActiveLoadOutOwner == LoadOutOwner_Player || MyCurrentLoadOut == None)
	{
		MySpawnButton.SetChecked( true );
		MySpawnButton.DisableComponent();
		MyEntrypointBox.DisableComponent();
	}
	else
	{
		MySpawnButton.SetChecked( MyCurrentLoadOut.bSpawn );
		MyEntrypointBox.SetIndex( MyCurrentLoadOut.Entrypoint );
		MySpawnButton.EnableComponent();
		MyEntrypointBox.EnableComponent();
	}
}


private function OnSaveLoadoutButtonClick(GuiComponent Sender)
{
	SaveLoadOut( GetConfigName(ActiveLoadOutOwner) );
	PlayerOwner().ClientMessage(
		"Saving loadout for: "$GetHumanReadableLoadout( GetConfigName(ActiveLoadOutOwner) )$
		" | Spawn: "$MySpawnButton.bChecked$
		" | Entrypoint: "$Mid( GetEnum( EEntryType, MyEntrypointBox.GetIndex() ), 3 ), 'Say');

	if(ActiveLoadOutOwner != LoadOutOwner_Player)
	{
		SwatGamePlayerController(PlayerOwner()).SetAIOfficerLoadout( GetConfigName(ActiveLoadOutOwner) );
	}
	else
	{
		SwatGUIController(Controller).SetMPLoadOut( MyCurrentLoadOut );
	}
}

defaultproperties
{
}
