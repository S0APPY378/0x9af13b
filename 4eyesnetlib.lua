
local Player=game.Players.LocalPlayer
local RunService=game:GetService("RunService")

-- Start the chaos!

if not getgenv().Network then
	warn([[

	username's net library

	based off of 4eye's net library released on v3rmillion.

	reworked for project mint's reanimation

	]])
	
	warn("[NETWORK]: Loading...")
	
	getgenv().Network = {
		Enabled = false;
		Instances = {};
	}
	
	Network.RetainPart = function(Part) -- Retain part just configures ONE property. I just dumbed it down.
		assert(typeof(Part) and (Part:IsA("BasePart") or Part:IsA("MeshPart")),warn("[NETWORK]: Retain error: Unable to proceed due to Arg1 isn't a BasePart/MeshPart. Are you sure you put in the right instance?"))
		if not table.find(Network["Instances"],Part) then
			Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			table.insert(Network["Instances"],Part)
		else
			warn("[NETWORK]: Instance '"..Part.Name.."' is already being retained!")
		end
	end
	
	-- 4Eyes made this. what a really powerful thing! edited a small bit.
	Network["SuperStepper"] = Instance.new("BindableEvent")
	for i,Event in pairs({RunService.Stepped,RunService.Heartbeat,RunService.RenderStepped}) do
		Event:Connect(function()
			return Network["SuperStepper"]:Fire(Network["SuperStepper"],tick())
		end)
	end
	for i,Event in pairs({RunService.Stepped,RunService.Heartbeat,RunService.RenderStepped}) do
		Event:Connect(function()
			return Network["SuperStepper"]:Fire(Network["SuperStepper"],tick())
		end)
	end
	
	-- EDITED A TAD BIT TO WORK FLAWLESSLY
	Network["PartOwnership"] = {};
	Network["PartOwnership"]["PreMethodSettings"] = {};
	Network["PartOwnership"]["Enabled"] = false;
	Network["PartOwnership"]["Enable"] = coroutine.create(function() --creating a thread for network stuff
		if Network["PartOwnership"]["Enabled"] == false then
			Network["PartOwnership"]["Enabled"] = true --do cool network stuff before doing more cool network stuff
			Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus = Player.ReplicationFocus
			Player.ReplicationFocus = workspace
			Network["PartOwnership"]["PreMethodSettings"].SimulationRadius = gethiddenproperty(Player,"SimulationRadius")
			Network["PartOwnership"]["Connection"] = Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
				sethiddenproperty(Player,"SimulationRadius",1/0)
			end)
			warn("[NETWORK] PartOwnership Output : PartOwnership enabled.")
		else
			warn("[NETWORK] PartOwnership Output : PartOwnership already enabled.")
		end
	end)
	Network["PartOwnership"]["Disable"] = coroutine.create(function()
		if Network["PartOwnership"]["Connection"] then
			Network["PartOwnership"]["Connection"]:Disconnect()
			Player.ReplicationFocus = Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus
			sethiddenproperty(Player,"SimulationRadius",Network["PartOwnership"]["PreMethodSettings"].SimulationRadius)
			Network["PartOwnership"]["PreMethodSettings"] = {}
			Network["PartOwnership"]["Enabled"] = false
			warn("[NETWORK] PartOwnership Output : PartOwnership disabled.")
		else
			warn("[NETWORK] PartOwnership Output : PartOwnership already disabled.")
		end
	end)
	
	warn("[NETWORK]: Successfully loaded.")
else
	warn("[NETWORK]: Already loaded!")
end
