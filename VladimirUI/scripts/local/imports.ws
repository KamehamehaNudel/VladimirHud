



//enum EMenuPauseType
//{
//	MPT_NoPause
//	MPT_ActivePause
//	MPT_FullPause
//};

import class ISerializable extends IReferencable
{

}

import struct IReferencable
{
	
}

import class CGuiConfigResource extends CResource
{
	import var huds 	: array< SHudDescription >;
	import var menus 	: array< SMenuDescription >;
	import var popups 	: array< SPopupDescription >;
}

import class CMenuResource extends IGuiResource
{
	import var menuClass		: CName;
	//import var menuFlashSwf	: soft:CSwfResource;
	import var layer			: Uint32;
	//import var menuDef		: ptr:CMenuDef;
}

import class CHudResource extends IGuiResource
{
	//import var resourceBlocks : array:2,0,ptr:CGraphBlock
	import var hudClass 		: CName;
	//import var hudFlashSwf 	: soft:CSwfResource;
}

import class CHudModuleResourceBlock extends IGuiResourceBlock
{
	import var moduleName   : string;
	import var moduleClass	: CName;
}

import class CPopupResource extends IGuiResource
{
	import var popupClass		: CName;
	//import var popupFlashSwf	: soft;CSwfResource;
	import var layer			: Uint32;
	//import var popupDef		: ptr:CPopupDef;
}

import class CSwfResource extends CResource
{
	import var linkageName	: string;
	import var fonts		: array< SSwfFontDesc >;
	import var textures		: array< CSwfTexture >;
}

import class CMenuPauseParam extends IMenuTimeParam
{
	import var pauseType : EMenuPauseType;
}

import class CMenuBackgroundVideoFileParam extends IMenuBackgroundVideoParam
{
	import var videoFile : string;
}

import class CMenuRenderBackgroundParam extends IMenuDisplayParam
{
	import var renderGameWorld : bool;
}

import struct SSwfFontDesc
{
	import var fontName		: string;
	import var numGlyphs 	: Uint32;
	import var bold			: bool;
	import var italic		: bool;
}

import struct SHudDescription
{
	import var hudName 			: CName;
	//import var hudResource 	: soft:CHudResource;
}

import struct SMenuDescription
{
	import var menuName			: CName;
	//import var menuResource 	: soft:CMenuResource;
}

import struct SPopupDescription
{
	import var popupName		: CName;
	//import var popupResource	: soft:CPopupResource
}

import class IGuiResource extends CResource
{

}

import class CMenuResourceFactory extends IFactory
{

}

import class CHudResourceFactory extends IFactory 
{

}

import class CPopupResourceFactory extends IFactory
{

}

import class IFactory extends CObject
{

}

import class CGuiObject extends CObject
{

}

import class CSwfTexture extends CBitmapTexture
{

}

import class CMenuDef extends CObject
{

}

import class CMenuInheritBackgroundVideoParam extends IMenuBackgroundVideoParam
{

}

import class CMenuClearBackgroundVideoParam extends IMenuBackgroundVideoParam
{

}