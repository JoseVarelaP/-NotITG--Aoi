-- Grab Judgment, Combo and Hold NG/OK.
function ComboCommand(self) ComboTween(self) end
function JudgmentCommand(self,n) JudgmentTween(self) end
function HoldCommand(self,n) HoldTween(self) end

-- Animation for Judgment.
function JudgmentTween(self) 
	self:shadowlength(0); 
	self:diffusealpha(0.1); 
	self:zoom(0.75); 
	self:linear(0.15); 
	self:diffusealpha(1); 
	self:zoom(1.1); 
	self:linear(0.05) 
	self:zoom(1) 
	self:sleep(1); 
	self:diffusealpha(0);
end

-- Animation for Combo.
function ComboTween(self) 
	local combo=self:GetZoom(); 
	local newZoom=scale(combo,50,3000,0.7,0.9); 
	
	self:zoom(0.75*newZoom); 
	self:y(30) 
	self:diffusealpha(0.1) 
	self:linear(0.15); 
	self:zoom(newZoom*1.1); 
	self:y(40) 
	self:diffusealpha(1) 
	self:linear(0.05) 
	self:y(40) 
	self:zoom(newZoom);
end

-- Animation for Hold NG/OK.
function HoldTween(self) 
	self:shadowlength(0) 
	self:diffusealpha(1) 
	self:y(-64) 
	self:zoom(1) 
	self:linear(1.5) 
	self:addy(-32) 
	self:sleep(0.5) 
	self:diffusealpha(0)
end

-- Shorcuts
function ThemeFile( file ) return THEME:GetPath( EC_GRAPHICS, '' , file ) end

-- This will play a file that is available on the SOUNDS folder.
function AudioPlay( file ) return SOUND:PlayOnce( THEME:GetPath( EC_SOUNDS, '', file ) ) end
-- This will play a file that is available on the specified location.
function AudioPlayFree( file ) return SOUND:PlayOnce( file ) end

function FindMod( n, name ) return string.find(SCREENMAN:GetTopScreen():GetChild('PlayerOptionsP'..n):GetText(), name ) end

-- Get Possible Dance Points
function ScorePossible( pn ) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetPossibleDancePoints() end
-- Get Actual/Current Dance Points.
function ScoreActual( pn ) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetActualDancePoints() end

-- Get Player Score
function GetScore( pn ) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetScore() end

-- Determines if Max Combo number glows
function MaxComboGlow(pn)
	local bMaxComboObtained = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):FullCombo()
	if not bMaxComboObtained then return
	else return "glowshift"
	end
end

-- Checks if the player is available to access the extra stage.
-- Current System works like this:
-- To obtain the Extra Stage, you must get higher than 93% as a Full Combo.
-- Failing to obtain these will result just sending you back to the final evaluation screen.
function AbleToEnterExtraStage()

	local ValueToPass = 0.93
	local function PEnabled(pn)
		return GAMESTATE:IsPlayerEnabled(pn)
	end

	local function StatsCombined(pn, n1, n2, n3)
		return GetPSStageStats(pn):GetTapNoteScores(n1) + GetPSStageStats(pn):GetTapNoteScores(n2) + GetPSStageStats(pn):GetTapNoteScores(n3)
	end

	if IsFinalStage() then
		
		if PEnabled(PLAYER_1) and not PEnabled(PLAYER_2) then
			if ( ScoreActual(PLAYER_1) / ScorePossible(PLAYER_1) ) >= ValueToPass and StatsCombined(PLAYER_1, 5, 4, 3) == 0 then
				return true
			else
				return false
			end
		end

		if PEnabled(PLAYER_2) and not PEnabled(PLAYER_1) then
			if ( ScoreActual(PLAYER_2) / ScorePossible(PLAYER_2) ) >= ValueToPass and StatsCombined(PLAYER_2, 5, 4, 3) == 0 then
				return true
			else
				return false
			end
		end

		if PEnabled(PLAYER_1) and PEnabled(PLAYER_2) then
			return false
		end

	end

end

-- Checks if the game is being run at Widescreen.
-- Thanks to MadkaT for the suggestion.
-- I had to rewrite the code however as GetScreenAspectRatio() doesn't actually exist in OITG.
-- However, we have GetPreference, so we can track the number and apply it to that.

-- Initially it was " if math.floor at PREFSMAN:GetPreference( 'DisplayAspectRatio' ) multiplied by 100000 and divided by 100000 was higher than 1.333333. "
-- BrotherMojo noticed this, and provided with a result that was really self-explanatory. There was no need for a floor.
-- Instead just make it check that the value is higher than 1.34.
-- since PREFSMAN:GetPreference( 'DisplayAspectRatio' ) gives you 12 decimals.
-- In 4:3 is 1.333333700492, and 16:9 is 1.777777982301 so, making it check for a value higher than 1.34 was pretty logical.
function IsUsingWideScreen()
    return PREFSMAN:GetPreference( 'DisplayAspectRatio' ) > 1.34
end

-- Checks if the Characters are Enabled.
-- 1 and 2 are going to enable the characters, no matter what.
-- This is used for the 3D note overlaping Fix.
function HasCharactersEnabled()
    return PREFSMAN:GetPreference( 'ShowDancingCharacters' ) > 1
end

-- Checks if both players are enabled to activate the option to start Battle mode.
function SongWheelOrderList()
	local Version = 'Group,'
	local Difficulty = 'EasyMeter,MediumMeter,HardMeter,ExpertMeter,'
	local NormalStuff = 'Title,Artist,Bpm,Popularity,'

	if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		return Version .. Difficulty .. NormalStuff ..'Dance,Battle'
	else
		return Version .. Difficulty .. NormalStuff
	end
end

-- For Battle mode's combined lifebar.
function BattleModeLifeBarLength()
	if IsUsingWideScreen() then
		return 800
	else
		return 630
	end
end

-- Data needed for the Summary screen and also for the Perfect percentage in the ProfileCheck Screen.
-- Also this is added for compatibility, and stability, just in case you delete these strings from default
-- and you don't know how they were written.
function GetActual( stepsType )
	return 
		PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_EASY)+
		PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_MEDIUM)+
		PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_HARD)+
		PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_CHALLENGE)+
		PROFILEMAN:GetMachineProfile():GetCoursesActual(stepsType,COURSE_DIFFICULTY_REGULAR)+
		PROFILEMAN:GetMachineProfile():GetCoursesActual(stepsType,COURSE_DIFFICULTY_DIFFICULT)
end

function GetPossible( stepsType )
	return 
		PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_EASY)+
		PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_MEDIUM)+
		PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_HARD)+
		PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_CHALLENGE)+
		PROFILEMAN:GetMachineProfile():GetCoursesPossible(stepsType,COURSE_DIFFICULTY_REGULAR)+
		PROFILEMAN:GetMachineProfile():GetCoursesPossible(stepsType,COURSE_DIFFICULTY_DIFFICULT)
end

function GetTotalPercentComplete( stepsType )
	return GetActual(stepsType) / (0.96*GetPossible(stepsType))
end

function GetSongsPercentComplete( stepsType, difficulty )
	return PROFILEMAN:GetMachineProfile():GetSongsPercentComplete(stepsType,difficulty)/0.96
end

function GetCoursesPercentComplete( stepsType, difficulty )
	return PROFILEMAN:GetMachineProfile():GetCoursesPercentComplete(stepsType,difficulty)/0.96
end

function GetExtraCredit( stepsType )
	return GetActual(stepsType) - (0.96*GetPossible(stepsType))
end

function GetMaxPercentCompelte( stepsType )
	return 1/0.96;
end

-- Stage Number for Gameplay, Select Music and Evaluation
function StageNumberAdded()
	if GAMESTATE:StageIndex()+1 == 1 or GAMESTATE:StageIndex()+1 == 21 or GAMESTATE:StageIndex()+1 == 31 then 
		return GAMESTATE:StageIndex()+1 ..'st'
	elseif GAMESTATE:StageIndex()+1 == 2 or GAMESTATE:StageIndex()+1 == 22 or GAMESTATE:StageIndex()+1 == 32 then 
		return GAMESTATE:StageIndex()+1 ..'nd'
	elseif GAMESTATE:StageIndex()+1 == 3 or GAMESTATE:StageIndex()+1 == 23 or GAMESTATE:StageIndex()+1 == 33 then 
		return GAMESTATE:StageIndex()+1 ..'rd'
	elseif GAMESTATE:StageIndex()+1 > 99 then 
		return GAMESTATE:StageIndex()+1
	else
		return GAMESTATE:StageIndex()+1 ..'th'
	end
end

-- Stage Number for Normal occasions
function StageNumber()
	if GAMESTATE:StageIndex() == 1 or GAMESTATE:StageIndex() == 21 or GAMESTATE:StageIndex() == 31 then 
		return GAMESTATE:StageIndex() ..'st'
	elseif GAMESTATE:StageIndex() == 2 or GAMESTATE:StageIndex() == 22 or GAMESTATE:StageIndex() == 32 then 
		return GAMESTATE:StageIndex() ..'nd'
	elseif GAMESTATE:StageIndex() == 3 or GAMESTATE:StageIndex() == 23 or GAMESTATE:StageIndex() == 33 then 
		return GAMESTATE:StageIndex() ..'rd'
	elseif GAMESTATE:StageIndex() > 99 then 
		return GAMESTATE:StageIndex()
	else
		return GAMESTATE:StageIndex() ..'th'
	end
end

-- Character stuff
function CharacterTransferCheckEnd()
	local s = "ScreenSelect"

	-- Check for Dance
	if GAMESTATE:GetPlayMode() == 0 then s = s..'Music' end

	-- Check for Nonstop
	if GAMESTATE:GetPlayMode() == 1 then s = s..'Course' end

	return s
end

function CharacterTransferCheckStart()
	local s = "ScreenSelect";
	
	-- Dancing Characters are on "SELECT"? Send them to this screen.
	if string.find(string.lower(PREFSMAN:GetPreference('ShowDancingCharacters')), '2') then
		s = s.."Character"
	end

	-- Dancing Characters are on "DEFAULT TO OFF" or "DEFAULT TO RANDOM"? Send them to their respective next screens.
	if GAMESTATE:GetPlayMode() == 0 and not string.find(string.lower(PREFSMAN:GetPreference('ShowDancingCharacters')), '2') then
		s = s..'Music'
	end
	if GAMESTATE:GetPlayMode() == 1 and not string.find(string.lower(PREFSMAN:GetPreference('ShowDancingCharacters')), '2') then
		s = s..'Course'
	end

	return s
end

-- THE HUGE ANNOUNCER DATA VALUE TREE.

function AnnouncerAudio()

	local Grade = STATSMAN:GetBestGrade()
	local Extra = AbleToEnterExtraStage()

	-- AAAA
	for i=0,2 do
    	if Grade == i and not Extra then
        	return 'Internal/eval/AAA/sss-00'
    	end
    end
    
    -- AAA and AAAA
    --[[
    if Grade >= 1 and Grade < 2 and not Extra then
		return 'Internal/eval/AAA/sss-00'
    end
    ]]

    -- AA
    if Grade >= 2 or Grade <= 3  and not Extra then
    	return 'Internal/eval/AA/s-0'.. RandomNumber
    end

    -- A
    if Grade >= 3 or Grade <= 4 and not Extra then
    	return 'Internal/eval/A/a-0'.. RandomNumber
    end
                        
    -- B
    if Grade >= 4 and Grade < 5 and not Extra then
    	return 'Internal/eval/B/b-0'.. RandomNumber
    end
     
    -- C
    if Grade >= 5 and Grade < 6 and not Extra then
    	return 'Internal/eval/C/c-0'.. RandomNumber
   end
   
   -- D
   if Grade >= 7 and Grade < 8 and not Extra then
    	return 'Internal/eval/D/d-0'.. RandomNumber
    end
    
    -- E
   if Grade >= 6 and Grade < 7 and not Extra then
       return 'Internal/eval/E/e-0'.. RandomNumber
    end
                        
	-- F
    if Grade > 7 and not Extra then
		return 'Internal/eval/E/e-0'.. RandomNumber
    end

    if Extra == true then
    	return 'Internal/Extra/extra-'.. RandomNumber
    end

end

function RadarValue(pn,n)
	-- 0 - Stream
	-- 1 - Voltage
	-- 2 - Air
	-- 3 - Freeze
	-- 4 - Chaos
	return GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue(n)
end

function RadarValueNonstop(pn,n)
	-- 0 - Stream
	-- 1 - Voltage
	-- 2 - Air
	-- 3 - Freeze
	-- 4 - Chaos
	return GAMESTATE:GetCurrentTrail(pn):GetRadarValues(pn):GetValue(n)
end

-- get a formatted max combo text, sine Lua's string.format
function GetFormattedMaxCombo(pn) return string.format("% 4d",STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):MaxCombo()) end

-- If the player(s) have passed AT LEAST one song, take them to the Summary screen if they back out.
-- Otherwise, return them to the main menu.
function TitleMusicRedirect()
	if GAMESTATE:StageIndex() >= 1 then 
		return "ScreenEvaluationSummaryTitle"
	else
		return "ScreenTitleMenu"
	end
end

function SongSelectionScreen()
	local s = "ScreenSelectMusic";
	if GAMESTATE:IsCourseMode() then s = s.."Course" end
	return s
end

-- Set the next screen for Evaluation.
function SetEvaluationNextScreen()
	Trace( "GetGameplayNextScreen: " )
	-- If all failed the song
	Trace( " AllFailed = "..tostring(AllFailed()) )
	-- If the game is in Event Mode.
	Trace( " IsEventMode = "..tostring(GAMESTATE:IsEventMode()) )
	-- If it's the Final Stage.
	Trace( " IsFinalStage = "..tostring(IsFinalStage()) )

	if GAMESTATE:IsEventMode() then return SongSelectionScreen() end
	if AllFailed() or IsFinalStage() and not AbleToEnterExtraStage() then return "ScreenEvaluationSummary" end
	if IsFinalStage() and AbleToEnterExtraStage() then return SongSelectionScreen() end
	return SongSelectionScreen();
end

function GetGameplayNextScreen()
	Trace( "GetGameplayNextScreen: " )
	Trace( " AllFailed = "..tostring(AllFailed()) )
	Trace( " IsEventMode = "..tostring(GAMESTATE:IsEventMode()) )
	Trace( " IsSyncDataChanged = "..tostring(GAMESTATE:IsSyncDataChanged()) )

	if GAMESTATE:IsSyncDataChanged() then 
		return "ScreenSaveSync"
	end
		
	-- Never show evaluation for training.
	-- Since it's not really neccesary.
	if GAMESTATE:GetCurrentSong():GetSongDir() == "Songs/In The Groove/Training1/" then 
		if GAMESTATE:IsEventMode() then 
			return SongSelectionScreen()
		else
			return EvaluationNextScreen()
		end
	elseif AllFailed() and not GAMESTATE:IsCourseMode() then 
		if GAMESTATE:IsEventMode() then 
			return SelectEvaluationScreen()
		else
			return "ScreenEvaluationStage"
		end
	else
		return SelectEvaluationScreen() 
	end
	
	return "GetGameplayNextScreen: YOU SHOULD NEVER GET HERE"
end

function DangerSize()
	if IsUsingWideScreen() then 
		return 0.75
	else
		return 0.5
	end 
end


function ScrollBarPos()
	function AsRatio(n)
		return string.find(string.lower(PREFSMAN:GetPreference('DisplayAspectRatio')), n)
	end
	if AsRatio(1.7777) then
		return 260
	elseif AsRatio(1.600) then
		return 220
	else
		return 152
	end 
end

-- Lifebar Stuff
function LifeBarLength()
	if IsUsingWideScreen() then 
		return 388
	else
		return 289
	end 
end

function StripsNumber()
	if IsUsingWideScreen() then 
		return 66
	else
		return 33
	end 
end

function LifeBarP1PosX()
	if IsUsingWideScreen() then
		return SCREEN_CENTER_X-232
	else
		return SCREEN_CENTER_X-176
	end
end

function LifeBarP2PosX()
	if IsUsingWideScreen() then 
		return SCREEN_CENTER_X+232
	else
		return SCREEN_CENTER_X+176
	end
end

-- Get Final Grade for Player
function FinalGrade( pn ) return STATSMAN:GetFinalGrade(pn) end
-- Get Player Difficulty Meter
function PMeter( pn ) return GAMESTATE:GetCurrentSteps(pn):GetMeter() end
-- Get Player Difficulty
function PDiff( pn ) return GAMESTATE:GetCurrentSteps(pn):GetDifficulty() end
-- Get Player Stage Number
function PStage( pn ) return PROFILEMAN:GetProfile(pn):GetTotalNumSongsPlayed() end
-- Get Current Sort Order
function SortOrder( n ) return GAMESTATE:GetSortOrder(n) end
-- Get Player Trail Difficulty
function TDiff( pn ) return GAMESTATE:GetCurrentTrail(pn):GetDifficulty() end
-- Get Total Score for Summary Screen And Normal EventMode Results
function GetTotalScore( pn ) return STATSMAN:GetAccumStageStats():GetPlayerStageStats(pn):GetScore() end
-- Get Specific Tap Note Score for Summary Screen
function GetPSStats( pn ) return STATSMAN:GetAccumStageStats():GetPlayerStageStats(pn) end
-- Get Specific Tap Note Score for Normal Evaluation
function GetPSStageStats( pn ) return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn) end

-- Position For Players
function PlayerPositionP1()
	if CurStyleName() == 'solo' then
		return SCREEN_CENTER_X
	else
		return SCREEN_CENTER_X-(SCREEN_WIDTH*160/640)
	end
end

function PlayerPositionP2()
	if CurStyleName() == 'solo' then
		return SCREEN_CENTER_X
	else
		return SCREEN_CENTER_X+(SCREEN_WIDTH*160/640)
	end
end

-- You probably saw this in SL and SLGJUVM's Code.
-- I just love how this makes it simple to do stuff.
function OptionRowBase(name,modList)
	local t = {
		Name = name or 'Unnamed Options',
		LayoutType = (ShowAllInRow and 'ShowAllInRow') or 'ShowOneInRow',
		SelectType = 'SelectOne',
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = modList or {'Off','On'},
		LoadSelections = function(self, list, pn) list[1] = true end,
		SaveSelections = function(self, list, pn)	 end
	}
	return t
end