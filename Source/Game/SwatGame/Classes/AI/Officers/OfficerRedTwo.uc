///////////////////////////////////////////////////////////////////////////////
//
// OfficerRedTwo.uc - the OfficerRedTwo class

class OfficerRedTwo extends SwatOfficer;
///////////////////////////////////////////////////////////////////////////////

function PreBeginPlay()
{
    Super.PreBeginPlay();

    Label = 'OfficerRedTwo';
}

///////////////////////////////////////////////////////////////////////////////
//
// Initialization

simulated protected function AddToSquads()
{
	local SwatAIRepository SwatAIRepo;
	SwatAIRepo = SwatAIRepository(Level.AIRepo);

	SwatAIRepo.GetRedSquad().addToSquad(self);
	SwatAIRepo.GetElementSquad().addToSquad(self);
}

simulated protected function RemoveFromSquads()
{
	local SwatAIRepository SwatAIRepo;
	SwatAIRepo = SwatAIRepository(Level.AIRepo);

	SwatAIRepo.GetRedSquad().removeFromSquad(self);
	SwatAIRepo.GetElementSquad().removeFromSquad(self);

	SwatAIRepo.GetRedSquad().memberDied(self);
	SwatAIRepo.GetElementSquad().memberDied(self);
}

///////////////////////////////////////

// Provides the effect event name to use when this ai is being reported to
// TOC. Overridden from SwatAI
simulated function name GetEffectEventForReportingToTOCWhenIncapacitated()  { return 'ReportedR2DownToTOC'; }

///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	OfficerLoadOutType="OfficerRedTwoLoadOut"
	OfficerFriendlyName="Officer Red Two"
}
