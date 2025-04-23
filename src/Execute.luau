--!strict
--!optimize 2
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local InstanceBuilder = require(script:WaitForChild("InstanceBuilder"))

local plugin:Plugin = plugin
local _settings:any = settings()
local Studio = _settings.Studio::Studio
local loadstring: (string,string?)->((...any)->...any)? = loadstring
local warn:(...any)->() = function(...:any)
	warn("PluginPermsExecute: ",...)
end
local Dock_Pointer:DockWidgetPluginGui? = nil
type ScriptType_custom = Script|ModuleScript|LocalScript
local TargetToExecute:ScriptType_custom? = nil
local topbar:PluginToolbar = plugin:CreateToolbar("ExecutePluginPerms")
local button = topbar:CreateButton("OpenPluginPermsMeny","Open UI","rbxassetid://6709885837")

local function ConnectChanger(self:Instance,H:number,S:number,V:number)
	local theme:any = Studio.Theme
	local Theme = theme::StudioTheme
	local s_H,s_S,s_V = Theme:GetColor(Enum.StudioStyleGuideColor.Tab):ToHSV()
	local bg = Color3.fromHSV(s_H+H,s_S+S,s_V+V)
	if self:IsA("TextBox") or self:IsA("TextLabel") or self:IsA("TextButton") then
		local h, s, v = bg:ToHSV()
		local inverted = Color3.fromHSV((h + 0.5) % 1, s, 1-v)
		if self:IsA("TextBox") then
			self.TextColor3=inverted
			self.BackgroundColor3=bg
		elseif self:IsA("TextLabel") then
			self.TextColor3=inverted
			self.BackgroundColor3=bg
		elseif self:IsA("TextButton") then
			self.TextColor3=inverted
			self.BackgroundColor3=bg
		end
--------------------------------------------
	elseif self:IsA("Frame") or self:IsA("ImageLabel") or self:IsA("ImageButton") then
		if self:IsA("Frame") then
			self.BackgroundColor3=bg
		elseif self:IsA("ImageLabel") then
			self.BackgroundColor3=bg
		elseif self:IsA("ImageButton") then
			self.BackgroundColor3=bg
		end
	end
end
local function ThemeColorSet(self:GuiObject,H:number?,S:number?,V:number?)
	local H=(tonumber(H) or 0)::number
	local S=(tonumber(S) or 0)::number
	local V=(tonumber(V) or 0)::number
	Studio.ThemeChanged:Connect(function()
		ConnectChanger(self,H,S,V)
	end)
	ConnectChanger(self,H,S,V)
end

local function hsvChangeEffect(Grab:GuiButton,Set:Frame):()
	local h,s,v = Grab.BackgroundColor3:ToHSV()
	Set.BackgroundColor3=Color3.fromHSV(h,s,1-v)
end
local UI_Zero = UDim2.new(0,0,0,0)
local UI_One = UDim2.new(1,0,1,0)
--For enter
local infoTW_Enter = TweenInfo.new(0.5,Enum.EasingStyle.Back)
local infoTW_Leave = TweenInfo.new(0.35,Enum.EasingStyle.Quart)
--Prop
local prop_Enter = {Size=UI_One}
local prop_Leave = {Size=UI_Zero}
local function PlayClickSFX():()
	local sound = Instance.new("Sound")
	sound.Volume=0.5
	sound.SoundId="rbxassetid://17208396156"
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound.Parent=Dock_Pointer
	sound:Play()
end
local function PlayEnterSFX():()
	local sound = Instance.new("Sound")
	sound.Volume=0.5
	sound.SoundId="rbxassetid://10066931761"
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound.Parent=Dock_Pointer
	sound:Play()
end
local function PlayLeaveSFX():()
	local sound = Instance.new("Sound")
	sound.Volume=0.5
	sound.SoundId="rbxassetid://17208343514"
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound.Parent=Dock_Pointer
	sound:Play()
end
local function HowerEffect(self:GuiButton):()
	self.MouseButton1Click:Connect(PlayClickSFX)
	local Effect:Frame = Instance.new("Frame")
	Effect.ZIndex=self.ZIndex-1
	Effect.BackgroundTransparency=0.35
	Effect.AnchorPoint=Vector2.new(0.5,0.5)
	Effect.Position=UDim2.new(0.5,0,0.5,0)
	Effect.BorderSizePixel=0
	Effect.Size=UI_Zero
	--tw Enter
	--tw2 leave
	local tw = TweenService:Create(Effect,infoTW_Enter,prop_Enter)
	local tw2 = TweenService:Create(Effect,infoTW_Leave,prop_Leave)
	self.MouseEnter:Connect(function()
		tw:Play()
		PlayEnterSFX()
	end)
	self.MouseLeave:Connect(function()
		tw2:Play()
		PlayLeaveSFX()
	end)
	self:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		hsvChangeEffect(self,Effect)
	end)
	hsvChangeEffect(self,Effect)
	self.Destroying:Connect(function()
		Effect:Destroy()
		tw:Destroy()
		tw2:Destroy()
	end)	
	Effect.Parent=self
end

local function CreatePathToFile(obj:Instance):string
	local parent:Instance? = obj
	local path = ""
	while parent~=nil and parent~=game do
		path=`["{parent}"]{path}`
		parent=parent.Parent
	end
	path=`game{path}`
	if obj.Parent==nil then path="nil" end
	return path
end

local Frame = InstanceBuilder({
	Type="Frame";
	AnchorPoint=Vector2.new(0.5,0.5);
	BackgroundColor3=Color3.fromRGB(59,59,59);
	BackgroundTransparency=0;
	Name="Frame";
	_init=function(self:Instance)
		local self=self::Frame
		ThemeColorSet(self,0.4,0,0)	
	end;
	Size=UDim2.new(1,0,1,0);
	Position=UDim2.new(0.5,0,0.5,0);
	BorderSizePixel=0;
	ZIndex=1;
		{--Run
			Type="ImageButton";
			AnchorPoint=Vector2.new(0.5,0.5);
			BackgroundColor3=Color3.new(1,1,1);
			BackgroundTransparency=1;
			Image="rbxassetid://4998267428";
			ImageTransparency=0.3;
			Name="Run";
			Size=UDim2.new(0.5,0,0.5,0);
			Position=UDim2.new(0.25,0,0.25,0);
			BorderSizePixel=0;
			ZIndex=2;
			{
				Type="UIAspectRatioConstraint";
			};
			_init=function(self:ImageButton)
				ThemeColorSet(self)
				HowerEffect(self)
				self.MouseButton1Click:Connect(function()
				local source = TargetToExecute
					if source==nil then warn("Please select target first!") return end
					if typeof(source)~="Instance" then return end
					source=source::ScriptType_custom
					local str:string = `local script = {CreatePathToFile(source)}\n{source.Source}`
					local code = loadstring(str,"PluginPerms:")
					if code~=nil then
						code()
					end
				end)
			end,
		};
		{--SetTarget
			Type="ImageButton";
			AnchorPoint=Vector2.new(0.5,0.5);
			BackgroundColor3=Color3.new(1,1,1);
			BackgroundTransparency=1;
			Image="rbxassetid://997927536";
			ImageTransparency=0.3;
			Name="SetTarget";
			Size=UDim2.new(0.5,0,0.5,0);
			Position=UDim2.new(0.75,0,0.25,0);
			BorderSizePixel=0;
			ZIndex=2;
			{
				Type="UIAspectRatioConstraint";
			};
			_init=function(self:ImageButton)
				ThemeColorSet(self)
				HowerEffect(self)
				self.MouseButton1Click:Connect(function()
					local get = Selection:Get()[1]
					if get==nil then warn("Please select something!") return end
					if not get:IsA("LuaSourceContainer") then warn("You must select a Script!") return end
					TargetToExecute=get	
					warn(`<<{get:GetFullName()}>> is now our Target to execute!`)
				end)
			end,
	};
	{--T_Left
		Type="TextLabel";
		AnchorPoint=Vector2.new(0.5,0.5);
		BackgroundColor3=Color3.new(1,1,1);
		BackgroundTransparency=1;
		Name="T_Left";
		Size=UDim2.new(0.5,0,0.45,0);
		Position=UDim2.new(0.25,0,0.75,0);
		BorderSizePixel=0;
		ZIndex=2;
		TextColor3=Color3.new(1,1,1);
		TextScaled=true;
		RichText=true;
		TextStrokeTransparency=1;
		Text="Run";
		_init=function(self:TextLabel)
			ThemeColorSet(self)
		end;
		{
			Type="UIAspectRatioConstraint";
			AspectRatio=2;
		};
	};
	{--T_Right
		Type="TextLabel";
		AnchorPoint=Vector2.new(0.5,0.5);
		BackgroundColor3=Color3.new(1,1,1);
		BackgroundTransparency=1;
		Name="T_Left";
		Size=UDim2.new(0.5,0,0.45,0);
		Position=UDim2.new(0.75,0,0.75,0);
		BorderSizePixel=0;
		ZIndex=2;
		TextColor3=Color3.new(1,1,1);
		TextScaled=true;
		RichText=true;
		TextStrokeTransparency=1;
		Text="Set Target";
		_init=function(self:TextLabel)
			ThemeColorSet(self)
		end;
		{
			Type="UIAspectRatioConstraint";
			AspectRatio=2;
		};

	};

})::Frame

local Dock = plugin:CreateDockWidgetPluginGui("Execute PluginPerms",DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	300,--StartingX
	300,--StartingY
	50,--MinW
	50--MinH
	))
Dock.Title="Plugin Perms Menu"
Dock_Pointer=Dock
Frame.Visible=true
Frame.Parent=Dock





button.Click:Connect(function()
	Dock.Enabled=not Dock.Enabled
end)

plugin.Unloading:Connect(function()
	button:Destroy()
	topbar:Destroy()
	Frame:Destroy()
	Dock:Destroy()
end)
