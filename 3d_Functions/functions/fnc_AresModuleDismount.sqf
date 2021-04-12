// Get all the passed parameters
params [["_position", [0,0,0], [[]], 3], ["_objectUnderCursor", objNull, [objNull]]];

// We check if there is a object under the cursor or not,
// If the object under cursor is null (nothing was selected), then prompt the user to select object(s) by calling Achilles_fnc_SelectUnits.
// But if the module had been placed upon an object, then return that object surounded by brackets (add it to an array). 
private _selectedObjects = if (isNull _objectUnderCursor) then
{
	["Objects"] call Achilles_fnc_SelectUnits;
}
else
{
	[_objectUnderCursor];
};

// If the selection was canceled, exit the script to prevent any issues and errors.
if (isNil "_selectedObjects") exitWith {};

// If the selection is empty, also exit, but with a message.
// Side note: using isEqualTo [] is faster than count _selectedObjects == 0. So always try to improve performance when ever possible.
if (_selectedObjects isEqualTo []) exitWith 
{
	// This is only from 0.1.0 update and higher! Use old Ares_fnc_ShowZeusMessage and playSound "FD_Start_F" if below that version! Syntax is the same.
	// Show the message to the Curator.
	["No object was selected!"] call Achilles_fnc_showZeusErrorMessage;
};

// If everything went good, then log the variables.
systemChat format ["Position: %1 and Selected objects: %2", _position, _selectedObjects];

// Start script
// Check if selected object(s) have any units in them and message zeus operator if no object has units
_count = {!((crew _x) isEqualTo [])} count _selectedObjects;
if (_count < 1) exitWith 
{
	["Selection has no units"] call Achilles_fnc_showZeusErrorMessage;
};

// Remove any none crew objects from selection
_selectedVehs = [];
{
	if (!((crew _x) isEqualTo [])) then {_selectedVehs pushBack _x};
} forEach _selectedObjects;

// Open selection dialog
private _dialogResult = 
[
	"Dismount",
	[
		["Selection:", ["All", "Driver", "Commander", "Gunner", "Cargo"]]
	]
] call Ares_fnc_ShowChooseDialog;

// If the dialog was closed.
if (_dialogResult isEqualTo []) exitWith{};

// Get the selected data
_dialogResult params ["_Selection"];

// Check if any of selected object(s) doesnt meet parameter criteria
_selectedVehicles = [];
{
	if (_Selection != 4) then
	{
		if !(([crew _x, [driver _x], [commander _x], [gunner _x]] select _Selection) isEqualTo [objNull]) then
		{_selectedVehicles pushBack _x};
	};
	if (_Selection == 4) then
	{
		if !(((crew _x) - [driver _x, commander _x, gunner _x]) isEqualTo []) then
		{_selectedVehicles pushBack _x};
	};
} forEach _selectedVehs;

//Change selected data to text for systemChat
_SelectionText = ["All", "Driver", "Commander", "Gunner", "Cargo"] select _Selection;

// Output the data to the chat.
systemChat format ["Dismount: %1", _SelectionText];

//Dismount selected units from selected object(s)
{
	_units = 
	[
		crew _x,
		[driver _x],
		[commander _x],
		[gunner _x],
		(crew _x) - [driver _x, commander _x, gunner _x]
	] select _Selection;
	_units orderGetIn false;
} forEach _selectedVehicles;

//Message zeus operator with changed objects
["Selected objects: %1, Dismounted %2 unit(s)", _selectedVehicles, _SelectionText] call Achilles_fnc_showZeusErrorMessage;

//End script