///////////////////////////////////////////////////////////////////////////////
//
// OfficerRedOne.uc - the OfficerRedOne class

class OfficerRedOne extends SwatOfficer;
///////////////////////////////////////////////////////////////////////////////

function PreBeginPlay()
{
    Super.PreBeginPlay();

    Label = 'OfficerRedOne';
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
simulated function name GetEffectEventForReportingToTOCWhenIncapacitated()  { return 'ReportedR1DownToTOC'; }

///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	OfficerLoadOutType="OfficerRedOneLoadOut"
	OfficerFriendlyName="Officer Red One"
}
