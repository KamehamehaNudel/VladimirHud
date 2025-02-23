/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3HorseManager extends CPeristentEntity
{
	private autobind inv : CInventoryComponent = single;		
	private saved var horseAbilities : array<name>;				
	private saved var itemSlots : array<SItemUniqueId>;			
	private saved var wasSpawned : bool;						
	private saved var horseMode : EHorseMode;					
	
	default wasSpawned = false;
	
	public function OnCreated()
	{
		itemSlots.Grow(EnumGetMax('EEquipmentSlots')+1);
		
		Debug_TraceInventories( "OnCreated" );
	}
	
	public function GetInventoryComponent() : CInventoryComponent
	{
		return inv;
	}
	
	// ---=== VladimirHUD ===--- Lim3zer0
	public function RequestGUIHorseAppearance() : name
	{
		return GetAppearanceName();
	}
	
	public function GetHorseMode() : EHorseMode
	{
		return horseMode;
	}
	// ---=== VladimirHUD ===---
	
	public final function GetShouldHideAllItems() : bool
	{
		return horseMode == EHM_Unicorn;
	}
	
	private final function GetAppearanceName() : name
	{
		var worldName : String;
		var isOnBobLevel : bool;
		
		worldName =  theGame.GetWorld().GetDepotPath();
		if( StrFindFirst( worldName, "bob" ) < 0 )
			isOnBobLevel = false;
		else
			isOnBobLevel = true; 
	
		if( horseMode == EHM_Unicorn )
		{
			return 'unicorn_wild_01';
		}
		else if( horseMode == EHM_Devil )
		{
			if( isOnBobLevel )
				return 'player_horse_with_devil_saddle_mimics';
			else
				return 'player_horse_with_devil_saddle';
		}		
		else if( FactsQuerySum( "q110_geralt_refused_pay" ) > 0 ) 
		{
			if( isOnBobLevel )
				return 'player_horse_after_q110_mimics';
			else
				return 'player_horse_after_q110';
		}	
		else
		{
			if( isOnBobLevel )
				return 'player_horse_mimics';
			else
				return 'player_horse';
		}
	}	
	
	public function SetHorseMode( m : EHorseMode )
	{
		var horse : CNewNPC;
				
		
		
		if( horseMode == EHM_Unicorn && m == EHM_Devil )
		{
			return;
		}
		
		horse = thePlayer.GetHorseWithInventory();
		
		
		if( horse && horseMode == EHM_Devil && m != horseMode )
		{
			horse.RemoveBuff( EET_WeakeningAura, true );
			horse.StopEffect( 'demon_horse' );
		}
		
		horseMode = m;
		
		
		if( horse )
		{
			if( horseMode == EHM_Devil )
			{
				horse.PlayEffectSingle( 'demon_horse' );
				if( !horse.HasBuff( EET_WeakeningAura ) )
					horse.AddEffectDefault( EET_WeakeningAura, horse, 'horse saddle', false );
			}
			
			horse.AddTimer( 'SetShowAllHorseItems', 0.3f );
			
			
			horse.ApplyAppearance( GetAppearanceName() );
		}
	}
		
	
	public function ApplyHorseUpdateOnSpawn() : bool
	{
		var ids, items 		: array<SItemUniqueId>;
		var eqId  			: SItemUniqueId;
		var i 				: int;
		var horseInv 		: CInventoryComponent;
		var horse			: CNewNPC;
		var itemName		: name;
		
		horse = thePlayer.GetHorseWithInventory();
		if( !horse )
		{
			return false;
		}
		
		horseInv = horse.GetInventory();
		
		if( !horseInv )
		{
			return false;
		}
		
		horseInv.GetAllItems(items);
		
		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] BEFORE" );
		
		
		if (!wasSpawned)
		{
			for(i=items.Size()-1; i>=0; i-=1)
			{
				if ( horseInv.ItemHasTag(items[i], 'HorseTail') || horseInv.ItemHasTag(items[i], 'HorseReins') || horseInv.GetItemCategory( items[i] ) == 'horse_hair' )
				{
					continue;
				}
				eqId = horseInv.GiveItemTo(inv, items[i], 1, false);
				theGame.GetGuiManager().ShowNotification("ApplyHorseUpdateOnSpawn"); // --------------------------------
				EquipItem(eqId);
			}
			wasSpawned = true;
		}
		
		
		for(i=items.Size()-1; i>=0; i-=1)
		{
			if ( horseInv.ItemHasTag(items[i], 'HorseTail') || horseInv.ItemHasTag(items[i], 'HorseReins') || horseInv.GetItemCategory( items[i] ) == 'horse_hair' )
			{
				if( !horseInv.IsItemMounted( items[i] ) )
				{
					horseInv.MountItem( items[i] );
				}
				continue;
			}
			horseInv.RemoveItem(items[i]);
		}
		
		
		for( i = 0; i < itemSlots.Size(); i += 1 )
		{
			if( inv.IsIdValid( itemSlots[i] ) )
			{
				itemName = inv.GetItemName( itemSlots[i] );
				ids = horseInv.AddAnItem( itemName );
				horseInv.MountItem( ids[0] );
			}
		}
	
		
		horseAbilities.Clear();
		horse.GetCharacterStats().GetAbilities(horseAbilities, true);
		
		
		if( GetWitcherPlayer().HasBuff( EET_HorseStableBuff ) && !horse.HasAbility( 'HorseStableBuff', false ) )
		{
			horse.AddAbility( 'HorseStableBuff' );
		}
		else if( !GetWitcherPlayer().HasBuff( EET_HorseStableBuff ) && horse.HasAbility( 'HorseStableBuff', false ) )
		{
			horse.RemoveAbility( 'HorseStableBuff' );
		}
		
		ReenableMountHorseInteraction( horse );
		
		
		if( horseMode == EHM_NotSet )
		{
			if( horseInv.HasItem( 'Devil Saddle' ) )
			{
				horseMode = EHM_Devil;
			}
			else
			{
				horseMode = EHM_Normal;
			}
		}
		
		
		SetHorseMode( horseMode );

		Debug_TraceInventories( "ApplyHorseUpdateOnSpawn ] AFTER" );
				
		return true;
	}
	
	public function ReenableMountHorseInteraction( horse : CNewNPC )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var hc : W3HorseComponent;
		var i : int;

		if ( horse )
		{
			hc = horse.GetHorseComponent();
			if ( hc && !hc.GetUser() ) 
			{
				components = horse.GetComponentsByClassName( 'CInteractionComponent' );
				for ( i = 0; i < components.Size(); i += 1 )
				{
					ic = ( CInteractionComponent )components[ i ];
					if ( ic && ic.GetActionName() == "MountHorse" )
					{
						if ( !ic.IsEnabled() )
						{
							ic.SetEnabled( true );
						}
						return;
					}
				}
			}
		}
	}
	
	public function IsItemEquipped(id : SItemUniqueId) : bool
	{
		return itemSlots.Contains(id);
	}
	
	public function IsItemEquippedByName( itemName : name ) : bool
	{
		var i : int;
		
		for( i=0; i<itemSlots.Size(); i+=1 )
		{
			if( inv.GetItemName( itemSlots[i] ) == itemName )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function GetItemInSlot( slot : EEquipmentSlots ) : SItemUniqueId
	{
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		else
			return itemSlots[slot];
	}
	
	public function GetHorseAttributeValue(attributeName : name, excludeItems : bool) : SAbilityAttributeValue
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var min, max, val : SAbilityAttributeValue;
	
		
		if(horseAbilities.Size() == 0)
		{
			if(thePlayer.GetHorseWithInventory())
			{
				thePlayer.GetHorseWithInventory().GetCharacterStats().GetAbilities(horseAbilities,true);
			}
			else if(!excludeItems)
			{
				
				for(i=0; i<itemSlots.Size(); i+=1)
				{
					if(itemSlots[i] != GetInvalidUniqueId())
					{
						val += inv.GetItemAttributeValue(itemSlots[i], attributeName);
					}
				}
				
				return val;
			}
		}
		
		dm = theGame.GetDefinitionsManager();
		
		for(i=0; i<horseAbilities.Size(); i+=1)
		{
			dm.GetAbilityAttributeValue(horseAbilities[i], attributeName, min, max);
			val += GetAttributeRandomizedValue(min, max);
		}
		
		
		if(excludeItems)
		{
			for(i=0; i<itemSlots.Size(); i+=1)
			{
				if(itemSlots[i] != GetInvalidUniqueId())
				{
					val -= inv.GetItemAttributeValue(itemSlots[i], attributeName);
				}
			}
		}
		
		return val;
	}
	
	public function EquipItem(id : SItemUniqueId) : SItemUniqueId
	{
		var horse    : CActor;
		var ids      : array<SItemUniqueId>;
		var slot     : EEquipmentSlots;
		var itemName : name;
		var resMount, usePerk : bool;
		var abls	 : array<name>;
		var i		 : int;
		var unequippedItem : SItemUniqueId;
		var itemNameUnequip : name;
	
		
		if(!inv.IsIdValid(id))
			return GetInvalidUniqueId();
			
		
		slot = GetHorseSlotForItem(id);
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - BEFORE" );
		
		
		if(inv.IsIdValid(itemSlots[slot]))
		{
			itemNameUnequip = inv.GetItemName(itemSlots[slot]);
			unequippedItem = UnequipItem(slot);
		}
			
		
		itemSlots[slot] = id;
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			itemName = inv.GetItemName(id);
			ids = horse.GetInventory().AddAnItem(itemName);
			resMount = horse.GetInventory().MountItem(ids[0]);
			if (resMount)
			{
				horse.GetInventory().GetItemAbilities(ids[0], abls);
				for (i=0; i < abls.Size(); i+=1)
					horseAbilities.PushBack(abls[i]);
			}
			
			if ( itemNameUnequip == 'Devil Saddle' && horseMode != EHM_Unicorn)
			{
				SetHorseMode( EHM_Normal );				
			}
			
			if ( itemName == 'Devil Saddle' ) 
			{
				SetHorseMode( EHM_Devil );			
			}
		}
		else
		{
			inv.GetItemAbilities(id, abls);
			for (i=0; i < abls.Size(); i+=1)
				horseAbilities.PushBack(abls[i]);
			SetHorseMode( EHM_NotSet );
		}
		
		
		if ( slot == EES_HorseTrophy )
		{
			abls.Clear();
			inv.GetItemAbilities(id, abls);
			for (i=0; i < abls.Size(); i += 1)
			{
				if ( abls[i] == 'base_trophy_stats' )
					continue;

				thePlayer.AddAbility(abls[i]);
			}
		}
		
		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		if(inv.IsItemHorseBag(id))
			GetWitcherPlayer().UpdateEncumbrance();
		
		Debug_TraceInventories( "EquipItem ] " + inv.GetItemName( id ) + " - AFTER" );
		
		
		
		if( horse )
		{
			horse.AddTimer( 'SetShowAllHorseItems', 0.0f );
		}
		
		return unequippedItem;
	}
	
	public function AddAbility(abilityName : name)
	{
		var horse : CNewNPC;
		
		horse = thePlayer.GetHorseWithInventory();
		if(horse)
		{
			horse.AddAbility(abilityName, true);
		}
		
		horseAbilities.PushBack(abilityName);
	}
	
	public function UnequipItem(slot : EEquipmentSlots) : SItemUniqueId
	{
		var itemName : name;
		var horse : CActor;
		var ids : array<SItemUniqueId>;
		var abls : array<name>;
		var i : int;
		var usePerk : bool;
		var oldItem : SItemUniqueId;
		var newId : SItemUniqueId;
	
		if(slot == EES_InvalidSlot)
			return GetInvalidUniqueId();
			
		
		if(!inv.IsIdValid(itemSlots[slot]))
			return GetInvalidUniqueId();
			
		oldItem = itemSlots[slot];
			
		
		if ( slot == EES_HorseTrophy )
		{
			inv.GetItemAbilities(oldItem, abls);
			for (i=0; i < abls.Size(); i += 1)
			{
				if ( abls[i] == 'base_trophy_stats' )
					continue;
				
				thePlayer.RemoveAbility(abls[i]);
			}
		}
			
		
		if(inv.IsItemHorseBag( itemSlots[slot] ))
			GetWitcherPlayer().UpdateEncumbrance();
		
		itemName = inv.GetItemName(itemSlots[slot]);
		itemSlots[slot] = GetInvalidUniqueId();
		horse = thePlayer.GetHorseWithInventory();
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - BEFORE" );
		
		if ( itemName == 'Devil Saddle' && horseMode == EHM_Devil) 
		{
			SetHorseMode( EHM_Normal );			
		}
		
		
		if( horse )
		{
			ids = horse.GetInventory().GetItemsByName( itemName );
			horse.GetInventory().UnmountItem( ids[ 0 ] );
			horse.GetInventory().RemoveItem( ids[ 0 ] );
		}
		
		
		abls.Clear();
		ids = inv.GetItemsByName( itemName );
		inv.GetItemAbilities( ids[ 0 ], abls );
		for( i = 0; i < abls.Size(); i += 1 )
		{
			horseAbilities.Remove( abls[ i ] );
		}
		
		FactsAdd("vladimir_unequip_horse_item",1); // ---=== VladimirHUD ===--- Erx - new stuff
		newId = inv.GiveItemTo(thePlayer.inv, oldItem, 1, false, true, false);

		
		theGame.GetGlobalEventsManager().OnScriptedEvent( SEC_OnItemEquipped );
		
		Debug_TraceInventories( "UnequipItem ] " + itemName + " - AFTER" );

		return newId;
	}
	
	public function Debug_TraceInventory( inventory : CInventoryComponent, optional categoryName : name )
	{
		var i : int;
		var itemsNames : array< name >;
		var items : array< SItemUniqueId >;
		if( categoryName == '' )
		{
			itemsNames = inventory.GetItemsNames();
			for( i = 0; i < itemsNames.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', itemsNames[ i ] );
			}
		}
		else
		{
			items = inventory.GetItemsByCategory( categoryName );
			for( i = 0; i < items.Size(); i+=1 )
			{
				LogChannel( 'Dbg_HorseInv', inventory.GetItemName( items[ i ] ) );
			}
		}
	}
	
	public function Debug_TraceInventories( optional heading : string )
	{
		
		return; 
		
	
		if( heading != "" )
		{
			LogChannel( 'Dbg_HorseInv', "----------------------------------] " + heading );
		}
	
		if( thePlayer && thePlayer.GetHorseWithInventory() )
		{
			LogChannel( 'Dbg_HorseInv', "] Entity Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( thePlayer.GetHorseWithInventory().GetInventory() );
			
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
		
		if( inv )
		{
			LogChannel( 'Dbg_HorseInv', "] Manager Inventory" );
			LogChannel( 'Dbg_HorseInv', "----------------------------------" );
			
			Debug_TraceInventory( inv );
			
			
			LogChannel( 'Dbg_HorseInv', "" );
		}
	}
	
	public function MoveItemToHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return thePlayer.inv.GiveItemTo(inv, id, quantity, false, true, false);
	}
	
	public function MoveItemFromHorse(id : SItemUniqueId, optional quantity : int) : SItemUniqueId
	{
		return inv.GiveItemTo(thePlayer.inv, id, quantity, false, true, false);
	}
	
	public function GetHorseSlotForItem(id : SItemUniqueId) : EEquipmentSlots
	{
		return inv.GetHorseSlotForItem(id);
	}
	
		
	public final function HorseRemoveItemByName(itemName : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		ids = inv.GetItemsIds(itemName);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByName(itemName, quantity);
	}
	
	
	public final function HorseRemoveItemByCategory(itemCategory : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - BEFORE" );
		
		ids = inv.GetItemsByCategory(itemCategory);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByCategory(itemCategory, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByCategory ] " + itemCategory + " - AFTER" );
	}
	
	
	public final function HorseRemoveItemByTag(itemTag : name, quantity : int)
	{
		var ids : array<SItemUniqueId>;
		var slot : EEquipmentSlots;
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - BEFORE" );
		
		ids = inv.GetItemsByTag(itemTag);
		slot = GetHorseSlotForItem(ids[0]);
		UnequipItem(slot);
		
		inv.RemoveItemByTag(itemTag, quantity);
		
		Debug_TraceInventories( "HorseRemoveItemByTag ] " + itemTag + " - AFTER" );
	}
	
	public function RemoveAllItems()
	{
		var playerInvId : SItemUniqueId;
		
		playerInvId = UnequipItem(EES_HorseBlinders);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseSaddle);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseBag);
		thePlayer.inv.RemoveItem(playerInvId);
		playerInvId = UnequipItem(EES_HorseTrophy);
		thePlayer.inv.RemoveItem(playerInvId);
	}
	
	public function GetAssociatedInventory() : CInventoryComponent
	{
		return GetWitcherPlayer().GetInventory();
	}
}
