

/***********************************************************************/
/**		Campfire manager originally made by Erx
/***********************************************************************/


statemachine class CWitcherCampfireManager
{
	protected var alternateFireSource						: CGameplayLightComponent;
	protected var witcherCampfire 							: W3Campfire;
	private var playerWitcher								: W3PlayerWitcher;
	private var fireMode									: int;
	protected var wasAlternateFireLit						: bool;
	
	protected const var CAMPFIRE_SPAWN_DELAY				: float;
	protected const var KINDLE_DELAY						: float;
	protected const var KINDLE_DELAY_EXISTING				: float;
	protected const var EXTINGUISH_DELAY					: float;
	protected const var CAMPFIRE_DESTRUCTION_DELAY			: float;
	
	default KINDLE_DELAY = 5.0;
	default KINDLE_DELAY_EXISTING = 5.f;
	default CAMPFIRE_SPAWN_DELAY = 3.57f;
	default EXTINGUISH_DELAY = 1.5f;
	default CAMPFIRE_DESTRUCTION_DELAY = 1.9f;
	
	/*
	-2 		- stand up
	-1 		- stand up and put out
	0		- meditate no lighting
	1		- meditate lighting and campfire
	2		- meditate lighting
	*/
	public function ManageFire( spawn : bool ) : int
	{
		if(spawn)
		{
			fireMode = GetFireMode();
			if( fireMode == 1 )
			{
				RotateToFire();
				GotoState('Spawned');
			}
			else
			{
				if(alternateFireSource)
				{
					RotateToFire();
					GotoState('Idle');
				}
			}
		}
		else
		{
			fireMode = GetParentFireMode();
			GotoState('Extinguished');				
		}
		
		return fireMode;
	}
	
	protected function RotateToFire()
	{
		GetPlayer().SetCustomRotation('LookAtFire', VecHeading(GetFirePosition() - GetPlayerPosition()), 360.f, 1.f, false);
	}
	
	public function SetWasFireLit(set : bool)
	{
		this.wasAlternateFireLit = set;
	}
	
	public function Init( player : W3PlayerWitcher )
	{
		playerWitcher = player;
	}
	
	
	public function GetPlayerCampfire() : W3Campfire
	{
		return witcherCampfire;
	}
	
	protected function GetParentFireMode() : int
	{
		return fireMode;
	}
	
	protected function GetCampfireZPosition( position : Vector ) : float
	{
		var position_z : float;			
		
		if( theGame.GetWorld().GetWaterLevel(position, true) >= position.Z )
			return 9999;
		else
		if( theGame.GetWorld().NavigationLineTest(GetPlayer().GetWorldPosition(), position, 0.2f) )
		{
			theGame.GetWorld().PhysicsCorrectZ(position, position_z);
			return position_z;
		}
		
		return 9999;
	}
	
	protected function GetSafeCampfirePosition() : Vector
	{
		return (GetPlayer().GetWorldPosition() + VecFromHeading(GetPlayer().GetHeading() ) * (Vector)(0.83f, 0.83f, 1.f, 1.f) );
	}
	
	protected function GetFirePosition() : Vector
	{
		if( alternateFireSource )
			return alternateFireSource.GetWorldPosition();
		else
			return witcherCampfire.GetWorldPosition();
	}
	
	protected function GetPlayerPosition() : Vector
	{
		return playerWitcher.GetWorldPosition();
	}
	
	protected function GetPlayer() : W3PlayerWitcher
	{
		return playerWitcher;
	}
	
	private function GetFireMode() : int
	{
		if(playerWitcher.IsInInterior())
		{
			return 0;
		}		
		else if( GetIsFireSourceNear() )
		{
			if( alternateFireSource.IsLightOn() )
			{
				wasAlternateFireLit = true;
				return 0;
			}
			else
				return 1;
		}
		else
		{
			if( SpawnFire(GetSafeCampfirePosition()) == 1 )
			{				
				return 1;
			}
			else
			{
				return 0;
			}
		}
	}
	
	private function SpawnFire( position : Vector ) : int
	{
		var entityTemplate : CEntityTemplate;
		var pos : Vector;
		
		pos = position;
		pos.Z = GetCampfireZPosition(position);
		
		if(pos.Z == 9999)
		{
			return 0;
		}
		else
		{
			entityTemplate = (CEntityTemplate)LoadResource("MeditationCampfire");
			witcherCampfire = (W3Campfire)theGame.CreateEntity(entityTemplate, pos);
			return 1;
		}
	}
	
	
	private function GetIsFireSourceNear() : bool
	{
		return ( FindFireSource('W3Campfire') || FindFireSource('W3FireSource') );
	}
	
	
	private function FindFireSource( fireEntity : name, optional range : float ) : bool
	{
		var entities : array<CGameplayEntity>;
		var lightComponent : CGameplayLightComponent;
		var i : int;		
		
		alternateFireSource = NULL;
		
		if( !range )
			range = 1.4;
		
		FindGameplayEntitiesInRange(entities, playerWitcher, range, 5,, FLAG_ExcludePlayer,, fireEntity);
		for(i=entities.Size() - 1; i >= 0; i -= 1 )
		{
			lightComponent = (CGameplayLightComponent)entities[i].GetComponentByClassName('CGameplayLightComponent');
			if( lightComponent )
			{
				alternateFireSource = lightComponent;
				return true;
			}
		}		
		return false;		
	}
}

state Idle in CWitcherCampfireManager 
{

}

state Lit in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if(parent.alternateFireSource)
			parent.RotateToFire();
		LightFire();
	}
	
	private entry function LightFire()
	{
		Sleep(parent.KINDLE_DELAY);
		if(parent.alternateFireSource)					
			parent.alternateFireSource.SetLight(true);
		else
			parent.witcherCampfire.ToggleFire(true);
	}
}

state Extinguished in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		ExtinguishFire();
	}
	
	private entry function ExtinguishFire()
	{
		theGame.GetGuiManager().RequestMouseCursor(false);		
		Sleep(parent.EXTINGUISH_DELAY);
		if( parent.alternateFireSource )
		{
			if(!parent.wasAlternateFireLit)
				parent.alternateFireSource.SetLight(false);					
		}
		else		
			parent.witcherCampfire.ToggleFire(false);
			
		parent.SetWasFireLit(false);
		parent.PushState('Destroyed');
	}
}

state Spawned in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		BuildCampfire();
	}

	private entry function BuildCampfire()
	{
		parent.GotoState('Lit');
	}
}

state Destroyed in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		DestroyCampfire();
	}
	
	private entry function DestroyCampfire()
	{
		Sleep(parent.CAMPFIRE_DESTRUCTION_DELAY);
		parent.witcherCampfire.Destroy();
		parent.witcherCampfire = NULL;
		parent.alternateFireSource = NULL;
		parent.PushState('Idle');
	}
}
