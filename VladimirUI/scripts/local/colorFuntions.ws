


function RGBToDecimal( value : Color ) : int
{
	return (int)(value.Red*PowF(2,16)) + (int)(value.Green*PowF(2,8)) + value.Blue;
}

function DecimalToRGB( value : int ) : Color
{
	var col : Color;
	var r,g,b : int;
	r = FloorF(value/65536);
	g = FloorF((value-(r*65536))/256);
	b = value - (r*65536) - (g*256);
	col.Red = r; col.Green = g; col.Blue = b;
	return col;
}

function RGBToHex( value : Color ) : string
{
	var result : string = "";
	
	result += FourBitToHex( FloorF( value.Red/16 ) ); 
	result += FourBitToHex( value.Red - (FloorF( value.Red/16 )*16) );
	result += FourBitToHex( FloorF( value.Green/16 ) ); 
	result += FourBitToHex( value.Green - (FloorF( value.Green/16 )*16) );
	result += FourBitToHex( FloorF( value.Blue/16 ) );
	result += FourBitToHex( value.Blue - (FloorF( value.Blue/16 )*16) );
	
	return result;
}

function HexToRGB( hex : string ) : Color
{
	var col : Color;
	if(StrBeginsWith(hex,"#")){ hex = StrReplace(hex,"#",""); }
	col.Red = (HexToFourBit( StrMid(hex, 0, 1) )*16) + HexToFourBit( StrMid(hex, 1, 1) );
	col.Green = (HexToFourBit( StrMid(hex, 2, 1) )*16) + HexToFourBit( StrMid(hex, 3, 1) );
	col.Blue = (HexToFourBit( StrMid(hex, 4, 1) )*16) + HexToFourBit( StrMid(hex, 5, 1) );
	return col;
}

function HexToDecimal( hex : string ) : int
{
	return RGBToDecimal( HexToRGB( hex ) );
}
function DecimalToHex( value : int ) : string
{
	return RGBToHex( DecimalToRGB( value ) );
}

function FourBitToHex( value : int ) : string
{
	if( value > 15 || value < 0 ){ return ""; }
	switch( value )
	{
		case 10: return "A";
		case 11: return "B";
		case 12: return "C";
		case 13: return "D";
		case 14: return "E";
		case 15: return "F";
		default: return (string)value;
	}
}

function HexToFourBit( value : string ) : int
{
	switch( value )
	{
		case "A": return 10;
		case "B": return 11;
		case "C": return 12;
		case "D": return 13;
		case "E": return 14;
		case "F": return 15;
		default: return (int)value;
	}
}