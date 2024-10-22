/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
enum EMutationFeedbackType
{
	MFT_PlayHide,
	MFT_PlayOnce,
	MFT_PlayRepeat
	
}
	
class CR4HudModuleWolfHead extends CR4HudModuleBase
{
	
	private	var m_fxSetVitality						: CScriptedFlashFunction;
	private	var m_fxSetStamina						: CScriptedFlashFunction;
	private	var m_fxSetToxicity						: CScriptedFlashFunction;
	private	var m_fxSetExperience					: CScriptedFlashFunction;
	private	var m_fxSetLockedToxicity				: CScriptedFlashFunction;
	private	var m_fxSetDeadlyToxicity				: CScriptedFlashFunction;
	private	var m_fxShowStaminaNeeded				: CScriptedFlashFunction;
	private	var m_fxSwitchWolfActivation			: CScriptedFlashFunction;
	private var m_fxSetSignIconSFF					: CScriptedFlashFunction;
	private var m_fxSetSignTextSFF					: CScriptedFlashFunction;
	private var m_fxSetFocusPointsSFF				: CScriptedFlashFunction;
	private var	m_fxSetFocusProgressSFF				: CScriptedFlashFunction;
	private var m_fxLockFocusPointsSFF				: CScriptedFlashFunction;	
	private var m_fxSetCiriAsMainCharacter			: CScriptedFlashFunction;
	private var m_fxSetCoatOfArms					: CScriptedFlashFunction;
	private var m_fxSetShowNewLevelIndicator		: CScriptedFlashFunction;
	private var m_fxSetAlwaysDisplayed				: CScriptedFlashFunction;
	private var m_fxshowMutationFeedback			: CScriptedFlashFunction;
	
	private	var	m_LastVitality				: float;
	private	var	m_LastMaxVitality			: float;
	private	var	m_LastStamina				: float;	
	private	var	m_LastMaxStamina			: float;	
	private	var	m_LastExperience			: float;	
	private	var	m_LastMaxExperience			: float;
	private	var	m_LastToxicity				: float;
	private	var	m_LastLockedToxicity		: float;
	private	var	m_LastMaxToxicity			: float;
	private	var	m_bLastDeadlyToxicity		: bool;
	private	var	m_medallionActivated		: bool;
	private var m_oveloadedIconVisible		: bool;
	private var m_focusPoints				: int;
	private var m_focusProgress				: float;
	private var m_iCurrentPositiveEffectsSize : int;
	private var m_iCurrentNegativeEffectsSize : int;
	private var m_signIconName 				: string;
	private var m_CurrentSelectedSign 		: ESignType;
	private var m_IsPlayerCiri				: bool;
	
	private var m_curToxicity				: float;
	private var m_lockedToxicity			: float;
	private var m_curVitality				: float;
	private var m_maxVitality				: float;
	
	// ---=== VladimirHUD ===---
	private var VladTox, VladCiriStamina, VladSkullGliph, VladSwordsCiri, VladStam, VladSwords, VladAdr, VladHealth, VladExp, VladCiriExp, VladCombat : CScriptedFlashSprite;
	// ---=== VladimirHUD ===---
		
	default m_iCurrentPositiveEffectsSize = 0;
	default m_iCurrentNegativeEffectsSize = 0;
	default m_IsPlayerCiri				  = false;

	 event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorWolfHead";
		
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();	
		
		m_fxSetVitality						= flashModule.GetMemberFlashFunction( "setVitality" );
		m_fxSetStamina						= flashModule.GetMemberFlashFunction( "setStamina" );
		m_fxSetToxicity						= flashModule.GetMemberFlashFunction( "setToxicity" );
		m_fxSetExperience					= flashModule.GetMemberFlashFunction( "setExperience" );
		m_fxSetLockedToxicity				= flashModule.GetMemberFlashFunction( "setLockedToxicity" );
		m_fxSetDeadlyToxicity				= flashModule.GetMemberFlashFunction( "setDeadlyToxicity" );
		m_fxShowStaminaNeeded				= flashModule.GetMemberFlashFunction( "showStaminaNeeded" );
		m_fxSwitchWolfActivation			= flashModule.GetMemberFlashFunction( "switchWolfActivation" );
		m_fxSetSignIconSFF 					= flashModule.GetMemberFlashFunction( "setSignIcon" );
		m_fxSetSignTextSFF 					= flashModule.GetMemberFlashFunction( "setSignText" );
		m_fxSetFocusPointsSFF				= flashModule.GetMemberFlashFunction( "setFocusPoints" );
		m_fxSetFocusProgressSFF				= flashModule.GetMemberFlashFunction( "UpdateFocusPointsBar" );
		m_fxLockFocusPointsSFF				= flashModule.GetMemberFlashFunction( "lockFocusPoints" );
		m_fxSetCiriAsMainCharacter			= flashModule.GetMemberFlashFunction( "setCiriAsMainCharacter" );
		m_fxSetCoatOfArms					= flashModule.GetMemberFlashFunction( "setCoatOfArms" );
		m_fxSetShowNewLevelIndicator		= flashModule.GetMemberFlashFunction( "setShowNewLevelIndicator" );
		m_fxSetAlwaysDisplayed				= flashModule.GetMemberFlashFunction( "setAlwaysDisplayed" );
		m_fxshowMutationFeedback			= flashModule.GetMemberFlashFunction( "showMutationFeedback" );
		
		// ---=== VladimirHUD ===---
		VladTox = GetModuleFlash().GetChildFlashSprite("VladToxicity").GetChildFlashSprite("greenBar");
		VladCiriStamina = GetModuleFlash().GetChildFlashSprite("VladToxicity").GetChildFlashSprite("yellowBar");
		VladStam = GetModuleFlash().GetChildFlashSprite("VladStamina");
		VladSwords = GetModuleFlash().GetChildFlashSprite("VladSwordIcons").GetChildFlashSprite("Swords");
		VladSwordsCiri = GetModuleFlash().GetChildFlashSprite("VladSwordIcons");
		VladAdr = GetModuleFlash().GetChildFlashSprite("VladAdrenaline").GetChildFlashSprite("whiteBar");
		VladHealth = GetModuleFlash().GetChildFlashSprite("VladHealthBar").GetChildFlashSprite("redMasked");
		VladSkullGliph = GetModuleFlash().GetChildFlashSprite("VladToxicity").GetChildFlashSprite("VladToxIcons").GetChildFlashSprite("toxicityIcons");
		VladExp = GetModuleFlash().GetChildFlashSprite("VladExperience").GetChildFlashSprite("expBarMasked");
		VladCiriExp = GetModuleFlash().GetChildFlashSprite("VladExperience");
		//VladCombat = GetModuleFlash().GetChildFlashSprite( "VladCombat" ).GetChildFlashSprite( "mcCombatGlow" );
		VladCombat = GetModuleFlash().GetChildFlashSprite( "VladCombat" );
		// ---=== VladimirHUD ===---
		
		m_CurrentSelectedSign = thePlayer.GetEquippedSign();
		m_fxSetSignIconSFF.InvokeSelfOneArg(FlashArgString(GetSignIcon()));
		
		SetTickInterval( 0.5 );
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('WolfMedalion', true);
		}
		DisplayNewLevelIndicator();
		
		UpdateCoatOfArms();
	}
	
	public function DisplayMutationFeedback( value : EMutationFeedbackType )
	{
		m_fxshowMutationFeedback.InvokeSelfOneArg(FlashArgInt( value ));
	}
	
	function DisplayNewLevelIndicator()
	{
		var levelManager : W3LevelManager;
		levelManager = GetWitcherPlayer().levelManager;
		if( levelManager.GetPointsFree(ESkillPoint) > 0)
		{
			if( !thePlayer.IsCiri() )
			{
				m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(true));
			}
			else
			{
				m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(false));
			}
		}
		else
		{
			m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(false));
		}
	}

	event OnTick( timeDelta : float )
	{
		UpdateVitality();
		UpdateStamina();
		UpdateToxicity();
		UpdateSignData();
		// ---=== VladimirHUD ===---
		VladToxicity();
		VladStamina();
		VladSwordIcon();
		VladAdrenalineBar();
		VladHealthBar();
		VladExperienceBar();
		UpdatemcVladCombat();
		// ---=== VladimirHUD ===---
		if ( !CanTick( timeDelta ) )
		{
			return true;
		}
		
		UpdateExperience();
		UpdateMedallion();
		UpdateFocusPoints();
		UpdateStateByPlayer();
		
		
		if ( thePlayer.IsCombatMusicEnabled() || (m_curToxicity > 0.f || m_lockedToxicity > 0.f) || (m_curVitality < m_maxVitality) )
			SetAlwaysDisplayed( true );
		else
			SetAlwaysDisplayed( false );	
	}

	public function UpdateVitality() : void
	{
		var l_currentVitality 		: float;
		var l_currentMaxVitality 	: float;
		
		thePlayer.GetStats( BCS_Vitality, l_currentVitality, l_currentMaxVitality );

		m_curVitality = l_currentVitality;
		m_maxVitality = l_currentMaxVitality;

		if( l_currentVitality != m_LastVitality ||  l_currentMaxVitality != m_LastMaxVitality )
		{
			
			m_fxSetVitality.InvokeSelfOneArg( FlashArgNumber(  l_currentVitality / l_currentMaxVitality ) );
			m_LastVitality = l_currentVitality;
			m_LastMaxVitality = l_currentMaxVitality;
		}
	}
	
	private var playStaminaSoundCue : bool;
	
	// ---=== VladimirHUD ===--- Paulscott
	private function UpdatemcVladCombat()
	{
	    if( !thePlayer.IsCiri() &&  thePlayer.IsInCombat() )
	    {
	        VladCombat.GotoAndStopFrameNumber( 1 );
	    }
	    else if( thePlayer.IsCiri() &&  thePlayer.IsInCombat() )
	    {
		    VladCombat.GotoAndStopFrameNumber( 2 );
	    }
		else
	    {
		    VladCombat.GotoAndStopFrameNumber( 3 );
	    }
	}
	
	private function VladToxicity()
	{
		var curTox, curLockTox, VladToxValue, frameTox : float;
		var CiriStamina, CiriFrameStamina : float;
		curTox = thePlayer.GetStat(BCS_Toxicity);
		curLockTox = thePlayer.GetStat(BCS_Toxicity) - curTox;
		VladToxValue = curTox + curLockTox;
		frameTox = VladToxValue * 36 / 100;
		
		if( !thePlayer.IsCiri() )
		{
			VladTox.SetVisible( true );
			VladCiriStamina.SetVisible( false );
			VladSkullGliph.GotoAndStopFrameNumber( 1 );
			if( curTox == 0 && curLockTox == 0 )
			{
				VladTox.SetVisible( false );
			}
			else if( curTox != 0 || curLockTox != 0 )
			{
				VladTox.SetVisible( true );
				VladTox.GotoAndStopFrameNumber( Clamp(RoundF(frameTox),0,36)); 
				//theGame.GetGuiManager().ShowNotification(VladToxValue);
			}
		}
		else
		{
			VladTox.SetVisible( false );
			VladCiriStamina.SetVisible( true );
			CiriStamina = thePlayer.GetStatPercents(BCS_Stamina);
			CiriFrameStamina = CiriStamina * 36 / 1;
			VladSkullGliph.GotoAndStopFrameNumber( 2 );
			if((W3ReplacerCiri)thePlayer)
			{
				//theGame.GetGuiManager().ShowNotification("You are currently playing as Ciri!");
				if( CiriStamina == 0 )
				{
					VladCiriStamina.SetVisible( false );
				}
				else
				{
					VladCiriStamina.GotoAndStopFrameNumber( Clamp(RoundF(CiriFrameStamina),0,36));
				}
			}
		}
	}
	
	private function VladStamina()
	{
		var curStamina, frameStamina : float;
		
		curStamina = thePlayer.GetStatPercents(BCS_Stamina);
		
		if( !thePlayer.IsCiri() )
		{
			VladStam.SetVisible( true );
			if( curStamina == 0 )
			{
				VladStam.GotoAndStopFrameNumber( 1 );
			}
			else if( curStamina >= 0.33  && curStamina <= 0.667 )
			{
				VladStam.GotoAndStopFrameNumber( 2 );
			}
			else if( curStamina >= 0.667 && curStamina < 1 )
			{
				VladStam.GotoAndStopFrameNumber( 3 );
			}
			else if( curStamina == 1 )
			{
				VladStam.GotoAndStopFrameNumber( 4 );
			}
		}
		else
		{
			VladStam.SetVisible( false );
		}
	}
	
	private function VladSwordIcon()
	{
		if( !thePlayer.IsCiri() )
		{
			VladSwords.SetVisible( true );
			VladSwordsCiri.SetVisible( true );
			VladSwords.GotoAndStopFrameNumber( 1 );
			if( thePlayer.IsWeaponHeld('steelsword') )
			{
				VladSwords.GotoAndStopFrameNumber( 1 );
				//theGame.GetGuiManager().ShowNotification("acciaio");
			}
			else if( thePlayer.IsWeaponHeld('silversword') )
			{
				VladSwords.GotoAndStopFrameNumber( 2 );
				//theGame.GetGuiManager().ShowNotification("argento");
			}
		}
		else
		{
			VladSwords.SetVisible( false );
			VladSwordsCiri.SetVisible(false);
		}
	}
	
	
	private function VladAdrenalineBar()
	{
		var curAdr, frameAdr : float;
	
		curAdr = thePlayer.GetStatPercents(BCS_Focus);
		frameAdr = curAdr * 30 / 1;
		if( !thePlayer.IsCiri() )
		{
			VladAdr.SetVisible( true );
			if( curAdr == 0 )
			{
				VladAdr.SetVisible( false );
			}
			else if( curAdr > 0 )
			{
				VladAdr.SetVisible( true );
				VladAdr.GotoAndStopFrameNumber(Clamp(RoundF(frameAdr),1,30));
				//theGame.GetGuiManager().ShowNotification(curAdr);
			}
		}
		else if( thePlayer.IsCiri() || ((W3ReplacerCiri)thePlayer) )
		{
			VladAdr.SetVisible( true );
			//VladAdr.GotoAndStopFrameNumber( 30 );
			if( !thePlayer.HasAbility('CiriCharge') && !thePlayer.HasAbility('CiriBlink') && !thePlayer.HasAbility('Ciri_Rage') )
			{
				VladAdr.SetVisible( false );
			}
			else if( thePlayer.HasAbility('CiriBlink') && !thePlayer.HasAbility('CiriCharge') && !thePlayer.HasAbility('Ciri_Rage') )
			{
				VladAdr.GotoAndStopFrameNumber( 10 );
			}
			else if( thePlayer.HasAbility('CiriBlink') && thePlayer.HasAbility('CiriCharge') && !thePlayer.HasAbility('Ciri_Rage') )
			{
				VladAdr.GotoAndStopFrameNumber( 20 );
			}
			else if( thePlayer.HasAbility('CiriBlink') && thePlayer.HasAbility('CiriCharge') && thePlayer.HasAbility('Ciri_Rage') )
			{
				VladAdr.GotoAndStopFrameNumber( 30 );
			}
		}
	}
	
	private function VladHealthBar()
	{
		var curHealth, frameHealth : float;
		
		curHealth = thePlayer.GetStatPercents(BCS_Vitality);
		frameHealth = curHealth * 60 / 1;
		VladHealth.SetVisible( true );
		VladHealth.GotoAndStopFrameNumber(Clamp(RoundF(frameHealth),0,60));
	}

	private function VladExperienceBar()
	{
		var curExp, maxExp, frameExp : float;
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;	
		curExp = levelManager.GetPointsTotal(EExperiencePoint) - levelManager.GetTotalExpForCurrLevel();
		maxExp = levelManager.GetTotalExpForNextLevel() - levelManager.GetTotalExpForCurrLevel();
		frameExp = (( curExp / maxExp ) * 100); 
		frameExp = frameExp * 42 / 100;
		
		if( !thePlayer.IsCiri() )
		{
			VladCiriExp.SetVisible( true );
			VladExp.SetVisible( true );
			VladExp.GotoAndStopFrameNumber(Clamp(RoundF(frameExp),1,42));
		}
		else
		{
			VladCiriExp.SetVisible( false );
			VladExp.SetVisible( false );
		}
	}
		
		
	// ---=== VladimirHUD ===---
	
	public function UpdateStamina() : void
	{
		var l_curStamina 				: float;
		var l_curMaxStamina 			: float;
		var l_tooLowStaminaIndication 	: float = thePlayer.GetShowToLowStaminaIndication();

		thePlayer.GetStats( BCS_Stamina, l_curStamina, l_curMaxStamina );
		
		if ( m_LastStamina != l_curStamina || m_LastMaxStamina != l_curMaxStamina )
		{			
			m_fxSetStamina.InvokeSelfOneArg( FlashArgNumber ( l_curStamina / l_curMaxStamina ) );
			
			m_LastStamina 	 = l_curStamina;
			m_LastMaxStamina = l_curMaxStamina;
			
			if ( l_curStamina <= l_curMaxStamina*0.60 ) 
				playStaminaSoundCue = true;
				
			if ( l_curStamina <= 0 )
			{
				thePlayer.SoundEvent("gui_no_stamina");
				theGame.VibrateControllerVeryLight(); 
			}
			else if ( l_curStamina >= l_curMaxStamina && playStaminaSoundCue )
			{
				thePlayer.SoundEvent("gui_stamina_recharged");
				theGame.VibrateControllerVeryLight(); 
				playStaminaSoundCue = false;
			}
		}
		
		if( l_tooLowStaminaIndication > 0 )
		{
			m_fxShowStaminaNeeded.InvokeSelfOneArg( FlashArgNumber ( l_tooLowStaminaIndication / l_curMaxStamina ) );
			thePlayer.SetShowToLowStaminaIndication( 0 );
		}
	}

	public function UpdateToxicity() : void
	{
		var curToxicity 	: float;	
		var curMaxToxicity 	: float;
		var curLockedToxicity: float;
		var damageThreshold	: float;
		var curDeadlyToxicity : bool;
		
		thePlayer.GetStats( BCS_Toxicity, curToxicity, curMaxToxicity );
		
		curLockedToxicity = thePlayer.GetStat(BCS_Toxicity) - curToxicity;
		
		
		m_curToxicity = curToxicity;
		m_lockedToxicity = curLockedToxicity;
		
		if ( m_LastToxicity != curToxicity || m_LastMaxToxicity != curMaxToxicity || m_LastLockedToxicity != curLockedToxicity )
		{
			
			if( m_LastLockedToxicity != curLockedToxicity || m_LastMaxToxicity != curMaxToxicity)
			{
				m_fxSetLockedToxicity.InvokeSelfOneArg( FlashArgNumber( ( curLockedToxicity )/ curMaxToxicity ) );
				m_LastLockedToxicity = curLockedToxicity;
			}
			m_fxSetToxicity.InvokeSelfOneArg( FlashArgNumber( ( curToxicity + m_LastLockedToxicity )/ curMaxToxicity ) );
			m_LastToxicity 	= curToxicity;
			m_LastMaxToxicity = curMaxToxicity;
			
			damageThreshold = GetWitcherPlayer().GetToxicityDamageThreshold();
			curDeadlyToxicity = ( curToxicity >= damageThreshold * curMaxToxicity );
			if( m_bLastDeadlyToxicity != curDeadlyToxicity ) 
			{
				m_fxSetDeadlyToxicity.InvokeSelfOneArg( FlashArgBool( curDeadlyToxicity ) );
				m_bLastDeadlyToxicity = curDeadlyToxicity;
			}
			
			
		}
	}

	public function UpdateExperience() : void
	{
		var curExperience 	: float;
		var curMaxExperience 	: float;
		
		curExperience = GetCurrentExperience() - GetLevelExperience();
		curMaxExperience = GetTargetExperience() - GetLevelExperience();
		
		if ( m_LastExperience != curExperience || m_LastMaxExperience != curMaxExperience )
		{			
			m_fxSetExperience.InvokeSelfOneArg( FlashArgNumber(curExperience / curMaxExperience));
			
			m_LastExperience 	 = curExperience;
			m_LastMaxExperience = curMaxExperience;
		}
	}
	
	private function GetCurrentExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetPointsTotal(EExperiencePoint);;
	}
	
	private function GetLevelExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		return levelManager.GetTotalExpForCurrLevel();
	}

	private function GetTargetExperience() : float
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		return levelManager.GetTotalExpForNextLevel();
	}
	
	public function UpdateMedallion() : void
	{
		var l_curMedallionActivated : bool = GetWitcherPlayer().GetMedallion().IsActive();
		
		if( m_medallionActivated != l_curMedallionActivated )
		{
			m_medallionActivated = l_curMedallionActivated;
			m_fxSwitchWolfActivation.InvokeSelfOneArg( FlashArgBool( m_medallionActivated ) );
		}
	}
	
	private function UpdateFocusPoints()
	{
		var curFocusPoints : int = FloorF( GetWitcherPlayer().GetStat( BCS_Focus ) );
		var focusProgress : float = GetWitcherPlayer().GetStat( BCS_Focus );
		
		if ( m_focusPoints != curFocusPoints )
		{
			m_focusPoints = curFocusPoints;
			
			m_fxSetFocusPointsSFF.InvokeSelfOneArg( FlashArgInt( m_focusPoints) );
		}
		if ( m_focusProgress != focusProgress )
		{
			m_focusProgress = focusProgress;
			m_fxSetFocusProgressSFF.InvokeSelfOneArg( FlashArgNumber( focusProgress ) );
		}
	}

	public function ResetFocusPoints()
	{
		var curFocusPoints : int = FloorF( GetWitcherPlayer().GetStat( BCS_Focus ) );
		m_fxSetFocusPointsSFF.InvokeSelfOneArg( FlashArgInt(curFocusPoints) );
	}
	
	public function LockFocusPoints( value : int )
	{
		
		if ( value <= 3 )
			m_fxLockFocusPointsSFF.InvokeSelfOneArg( FlashArgInt( value) );
	}
	
	public function UpdateSignData()
	{
		if( thePlayer.GetEquippedSign() != m_CurrentSelectedSign )
		{
			m_CurrentSelectedSign = thePlayer.GetEquippedSign();
			m_fxSetSignIconSFF.InvokeSelfOneArg(FlashArgString(GetSignIcon()));
			m_fxSetSignTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt(SignEnumToString(m_CurrentSelectedSign))));
		}
	}
	
	public function UpdateStateByPlayer()
	{
		if( thePlayer.IsCiri() != m_IsPlayerCiri )
		{
			m_IsPlayerCiri = thePlayer.IsCiri();
			m_fxSetCiriAsMainCharacter.InvokeSelfOneArg(FlashArgBool(m_IsPlayerCiri));
			DisplayNewLevelIndicator();
		}
	}
	
	public function SetCoatOfArms( val : bool )
	{
		thePlayer.SetUsingCoatOfArms( val );
		
		UpdateCoatOfArms();
	}
	
	private function UpdateCoatOfArms()
	{
		m_fxSetCoatOfArms.InvokeSelfOneArg( FlashArgBool( thePlayer.IsUsingCoatOfArms() ) );
	}
	
	private function GetSignIcon() : string
	{
		if((W3ReplacerCiri)thePlayer)
		{
			return "";//"hud/radialmenu/mcCiriPower.png";  //takes off Ciri ! sign icon.
		}
		return GetSignIconByType(m_CurrentSelectedSign); 
	}
	
	private function GetSignIconByType( signType : ESignType ) : string
	{
		switch( signType )
		{
			case ST_Aard:		return "hud/radialmenu/mcAard.png";
			case ST_Yrden:		return "hud/radialmenu/mcYrden.png";
			case ST_Igni:		return "hud/radialmenu/mcIgni.png";
			case ST_Quen:		return "hud/radialmenu/mcQuen.png";
			case ST_Axii:		return "hud/radialmenu/mcAxii.png";
			default : return "";
		}
	}
	
	public function ShowLevelUpIndicator( value : bool )
	{
		m_fxSetShowNewLevelIndicator.InvokeSelfOneArg(FlashArgBool(value));
	}

	public function SetAlwaysDisplayed( value : bool )
	{
		m_fxSetAlwaysDisplayed.InvokeSelfOneArg(FlashArgBool(value));
	}
}

exec function AlwaysDisplayHUD( value : bool )
{
	var hudWolfHeadModule : CR4HudModuleWolfHead;		
	var hud : CR4ScriptedHud;
	hud = (CR4ScriptedHud)theGame.GetHud();
	
	hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
	if ( hudWolfHeadModule )
	{
		hudWolfHeadModule.SetAlwaysDisplayed(value);
	}
}

exec function coa( val : bool )
{
	var hud : CR4ScriptedHud;
	var hudWolfHeadModule : CR4HudModuleWolfHead;		

	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
		if ( hudWolfHeadModule )
		{
			hudWolfHeadModule.SetCoatOfArms( val );
		}
	}
}



