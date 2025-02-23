/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


class CR4GlossaryLocationsMenu extends CR4ListBaseMenu
{	
	private	var m_fxUpdateEntryInfo		: CScriptedFlashFunction;
	private var m_fxUpdateEntryImage	: CScriptedFlashFunction;

	event  OnConfigUI()
	{	
		var flashModule : CScriptedFlashSprite;
		super.OnConfigUI();
		flashModule = GetMenuFlash();
		m_fxUpdateEntryInfo = flashModule.GetMemberFlashFunction( "setEntryText" );
		m_fxUpdateEntryImage = flashModule.GetMemberFlashFunction( "setEntryImg" );
		ShowRenderToTexture("");
		PopulateData();
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
	}
	
	event  OnCloseMenu()
	{	
		super.OnCloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	private function PopulateData():void
	{
		var flashArray : CScriptedFlashArray;
		
		flashArray = m_flashValueStorage.CreateTempFlashArray();
		PopulateDataLocations(flashArray);
		
		m_flashValueStorage.SetFlashArray( "glossary.encyclopedia.list", flashArray );
		
		if( flashArray.GetLength() > 0 )
		{			
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
	}
	
	private function PopulateDataLocations(flashArray:CScriptedFlashArray):void
	{
		var i							: int;
		var tempEntries					: array<CJournalBase>;
		var entryTemp					: CJournalPlaceGroup;
		var status						: EJournalStatus;
		
		m_journalManager.GetActivatedOfType( 'CJournalPlaceGroup', tempEntries );
		
		for( i = 0; i < tempEntries.Size(); i += 1 )
		{
			entryTemp = (CJournalPlaceGroup)tempEntries[i];
			
			if (entryTemp)
			{
				status = m_journalManager.GetEntryStatus( tempEntries[i] );
				
				if (true)
				{
					AddLocationJournalEntryToArray(entryTemp, flashArray);
				}
			}
		}
	}
	
	private function AddLocationJournalEntryToArray(journalEntry:CJournalPlaceGroup, flashArray:CScriptedFlashArray):void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var j						: int;
		var l_entry					: CJournalPlace;
		var l_tempEntries			: array<CJournalBase>;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		
		l_GroupTitle = GetLocStringByKeyExt("panel_title_glossary_places");
		l_GroupTag = journalEntry.GetUniqueScriptTag();
		m_journalManager.GetActivatedChildren(journalEntry, l_tempEntries);
		
		for( j = 0; j < l_tempEntries.Size(); j += 1 )
		{
			l_entry = (CJournalPlace)l_tempEntries[j];
			if( m_journalManager.GetEntryStatus(l_entry) < JS_Active ) 
			{	
				continue;
			}
			l_Title = GetLocStringById( l_entry.GetNameStringId() );	
			
			l_IconPath = l_entry.GetImage();
			l_IsNew	= m_journalManager.IsEntryUnread( l_entry );
			l_Tag = l_entry.GetUniqueScriptTag();
			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", IsCategoryOpened(l_GroupTag) );
			//l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", journalEntry.GetImage() );
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			l_DataFlashObject.SetMemberFlashBool( "selected", (l_Tag == currentTag) );
			l_DataFlashObject.SetMemberFlashString(  "label", "<font size='" + LABEL_FONT_SIZE + "'>" + StrUpper( l_Title ) + "</font>" );
			//l_DataFlashObject.SetMemberFlashString(  "iconPath", "icons/tutorials/"+l_IconPath );
				
			flashArray.PushBackFlashObject(l_DataFlashObject);
		}
	}
	
	function GetPlaceDescription( currentEntry : CJournalPlace ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		var description : CJournalPlaceDescription;
		
		str = "";
		for( i = 0; i < currentEntry.GetNumChildren(); i += 1 )
		{
			description = (CJournalPlaceDescription)(currentEntry.GetChild(i));
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
				locStrId = description.GetDescriptionStringId();
				str += GetLocStringById(locStrId)+"<br>";
			}
		}

		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return "<textformat leading=\"" + DESC_TEXT_LEADING + "\"><font size='" + DESC_FONT_SIZE + "'>" + str + "</font></textformat>";
	}
	
	function getPlaceImage( place : CJournalPlace ) : string
	{
		return "img://textures/journal/locations/" + place.GetImage();
	}
	
	function UpdateDescription( entryName : name )
	{
		var journalEntry:CJournalBase;
		var characterEntry:CJournalCharacter;
		var placeEntry:CJournalPlace;
		var eventEntry:CJournalGlossary;
		var titleText:string;
		var descText:string;
		
		titleText = "";
		descText = "";
		
		journalEntry = m_journalManager.GetEntryByTag( entryName );
		
		placeEntry = (CJournalPlace)journalEntry;
		if (placeEntry)
		{
			descText = GetPlaceDescription(placeEntry);
			titleText = "<font color ='#FFFFFF' size='" + TITLE_FONT_SIZE + "' face=\"$BoldFont\">" + GetLocStringById( placeEntry.GetNameStringId() ) + "</font>";
		}
		
		m_fxUpdateEntryInfo.InvokeSelfTwoArgs(FlashArgString(titleText), FlashArgString(descText));
	}
	
	function UpdateImage( tag : name )
	{
		var placeEntry:CJournalPlace;
		var imgLoc:string;
		
		placeEntry = (CJournalPlace)m_journalManager.GetEntryByTag( tag );
		
		if (placeEntry)
		{
			imgLoc = getPlaceImage(placeEntry);
		}
		
		m_fxUpdateEntryImage.InvokeSelfOneArg(FlashArgString(imgLoc));
	}
}


exec function r4glossarylocations()
{
	theGame.RequestMenu( 'GlossaryLocationsMenu' );
}

exec function addplaces()
{
	var placeDirs	: array< string >;
	var i 			: int;
	
	placeDirs.PushBack("PlaceAbandonedDistilery");
	placeDirs.PushBack("PlaceAbandonedVillage");
	placeDirs.PushBack("PlaceAeramasManor");
	placeDirs.PushBack("PlaceAlchemyInn");
	placeDirs.PushBack("PlaceAmosShip");
	placeDirs.PushBack("PlaceAncientCrypt");
	placeDirs.PushBack("PlaceAncientOak");
	placeDirs.PushBack("PlaceArdSkellig");
	placeDirs.PushBack("PlaceArinbjorn");
	placeDirs.PushBack("PlaceArnskroneRuins");
	placeDirs.PushBack("PlaceArthachRuins");
	placeDirs.PushBack("PlaceBaldMountain");
	placeDirs.PushBack("PlaceBastion");
	placeDirs.PushBack("PlaceBathhouse");
	placeDirs.PushBack("PlaceBeauclairCemetary");
	placeDirs.PushBack("PlaceBeauclairPalace");
	placeDirs.PushBack("PlaceBeauclairPort");
	placeDirs.PushBack("PlaceBelgaard");
	placeDirs.PushBack("PlaceBlackbough");
	placeDirs.PushBack("PlaceBorderPost");
	placeDirs.PushBack("PlaceAuctionhouse");
	placeDirs.PushBack("PlaceBrunwich");
	placeDirs.PushBack("PlaceByways");
	placeDirs.PushBack("PlaceCaveofDreams");
	placeDirs.PushBack("PlaceCianfanelliBank");
	placeDirs.PushBack("PlaceCircleofElements");
	placeDirs.PushBack("PlaceCoatofWrecks");
	placeDirs.PushBack("PlaceCorvoBianco");
	placeDirs.PushBack("PlaceCrookbackBog");
	placeDirs.PushBack("PlaceCrowsPerch");
	placeDirs.PushBack("PlaceCunnyoftheGoose");
	placeDirs.PushBack("PlaceDeireadhPrison");
	placeDirs.PushBack("PlaceDestroyedBastion");
	placeDirs.PushBack("PlaceDevilsPit");
	placeDirs.PushBack("PlaceDragonsGrotto");
	placeDirs.PushBack("PlaceDunType");
	placeDirs.PushBack("PlaceEldbergLighthouse");
	placeDirs.PushBack("PlaceEternalFireTemple");
	placeDirs.PushBack("PlaceEverecEstate");
	placeDirs.PushBack("PlaceFaroe");
	placeDirs.PushBack("PlaceFisstechLab");
	placeDirs.PushBack("PlaceFortAmavet");
	placeDirs.PushBack("PlaceFreyaGarden");
	placeDirs.PushBack("PlaceFykeIsle");
	placeDirs.PushBack("PlaceGarinEstate");
	placeDirs.PushBack("PlaceGedyneith");
	placeDirs.PushBack("PlaceGiantsToes");
	placeDirs.PushBack("PlaceGildorf");
	placeDirs.PushBack("PlaceGoldenSturgeon");
	placeDirs.PushBack("PlaceGranPlace");
	placeDirs.PushBack("PlaceGregoryBridge");
	placeDirs.PushBack("PlaceGwenllech");
	placeDirs.PushBack("PlaceHangedmansTree");
	placeDirs.PushBack("PlaceHeatherton");
	placeDirs.PushBack("PlaceHerbalistsHut");
	placeDirs.PushBack("PlaceHierachSquare");
	placeDirs.PushBack("PlaceHidersfjall");
	placeDirs.PushBack("PlaceIronMine");
	placeDirs.PushBack("PlaceKaerGelen");
	placeDirs.PushBack("PlaceKaerMorhen");
	placeDirs.PushBack("PlaceKaerMuire");
	placeDirs.PushBack("PlaceKaerTrolde");
	placeDirs.PushBack("PlaceKingfisher");
	placeDirs.PushBack("PlaceLakesideHut");
	placeDirs.PushBack("PlaceLebiodaStatue");
	placeDirs.PushBack("PlaceLilvaniTemple");
	placeDirs.PushBack("PlaceLynxCrag");
	placeDirs.PushBack("PlaceMagicCataclysm");
	placeDirs.PushBack("PlaceMandragoraEstate");
	placeDirs.PushBack("PlaceMerelachaise");
	placeDirs.PushBack("PlaceMidcopse");
	placeDirs.PushBack("PlaceNilfCamp");
	placeDirs.PushBack("PlaceNilfGarrison");
	placeDirs.PushBack("PlaceNovigrad");
	placeDirs.PushBack("PlaceNovDocks");
	placeDirs.PushBack("PlaceNovLighthouse");
	placeDirs.PushBack("PlaceNovSewers");
	placeDirs.PushBack("PlaceODimmRealm");
	placeDirs.PushBack("PlaceOldChapel");
	placeDirs.PushBack("PlaceOxenfurt");
	placeDirs.PushBack("PlaceOxenHarbor");
	placeDirs.PushBack("PlaceOxenSewers");
	placeDirs.PushBack("PlacePaintedWorld");
	placeDirs.PushBack("PlacePartisanHideout");
	placeDirs.PushBack("PlacePassiflora");
	placeDirs.PushBack("PlacePutridGrove");
	placeDirs.PushBack("PlaceReadonManor");
	placeDirs.PushBack("PlaceReginaldStatue");
	placeDirs.PushBack("PlaceSawmill");
	placeDirs.PushBack("PlaceSpeartipCave");
	placeDirs.PushBack("PlaceSpikeroog");
	placeDirs.PushBack("PlaceStonecutters");
	placeDirs.PushBack("PlaceTeshamMutna");
	placeDirs.PushBack("PlaceTordarrochForge");
	placeDirs.PushBack("PlaceTorGvalchca");
	placeDirs.PushBack("PlaceTourneyGrounds");
	placeDirs.PushBack("PlaceToussintPrison");
	placeDirs.PushBack("PlaceUndvik");
	placeDirs.PushBack("PlaceUpperMill");
	placeDirs.PushBack("PlaceUskar");
	placeDirs.PushBack("PlaceValetteVilla");
	placeDirs.PushBack("PLaceVegelbud");
	placeDirs.PushBack("PlaceWyzima");
	placeDirs.PushBack("PlaceWatchtower");
	placeDirs.PushBack("PlaceWhaleGrave");
	placeDirs.PushBack("PlaceWhiteEagle");
	placeDirs.PushBack("PlaceWhiteOrchard");
	placeDirs.PushBack("PlaceWOInn");
	placeDirs.PushBack("PlaceWinespring");
	placeDirs.PushBack("PlaceHunterBarracks");
	placeDirs.PushBack("PlaceYantra");
	
	for( i = 0; i < placeDirs.Size(); i += 1 )
	{
		activateplace( placeDirs[i] );
	}
}

function activateplace( entryAlias : string )
{
	var i : int;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childEntries : array<CJournalBase>;
	var descriptionEntry : CJournalPlaceDescription;
	var journalManager : CWitcherJournalManager;
	
    journalManager = theGame.GetJournalManager();	
	resource = (CJournalResource)LoadResource( entryAlias );
	
	LogChannel('VHUD', entryAlias + ": activateplace" );
	if ( resource )
	{
		LogChannel('VHUD', entryAlias + ": resource = true" );
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			journalManager.ActivateEntry( entryBase, JS_Active );		
			journalManager.GetAllChildren( entryBase, childEntries );
					
			for ( i = 0; i < childEntries.Size(); i += 1 )
			{
				descriptionEntry = ( CJournalPlaceDescription )childEntries[ i ];
				if ( descriptionEntry )
				{
					journalManager.ActivateEntry( descriptionEntry, JS_Active );
				}
			}
		}
	}
}

