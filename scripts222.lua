-- Anti-Ban / Anti-Detect Avançado by Suysbs X
pcall(function()
	local player = game:GetService("Players").LocalPlayer
	for _, v in pairs(getconnections(player.Kick)) do v:Disable() end

	if hookfunction and getrawmetatable then
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		local old = mt.__namecall
		mt.__namecall = newcclosure(function(self, ...)
			local args = {...}
			local method = getnamecallmethod()
			if method == "Kick" or tostring(self):lower():find("kick") then return end
			if method == "SetCore" and args[1] == "Kick" then return end
			return old(self, unpack(args))
		end)
	end

	local function protectGui()
		local coreGui = game:GetService("CoreGui")
		local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
		for _, gui in pairs(coreGui:GetChildren()) do
			if gui.Name:find("PainelSuysbsX") then
				gui.Parent = playerGui
			end
		end
	end
	protectGui()

	local function deepScan(obj)
		for _, child in ipairs(obj:GetChildren()) do
			if child:IsA("LocalScript") and (child.Name:lower():find("kick") or child.Name:lower():find("ban")) then
				child:Destroy()
			end
			deepScan(child)
		end
	end
	deepScan(game:GetService("Players").LocalPlayer)

	local function disableWarnings()
		for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
			if obj:IsA("Message") then obj:Destroy() end
		end
	end
	disableWarnings()

	local function protectPlayer()
		local mt = getrawmetatable(player)
		setreadonly(mt, false)
		local oldIndex = mt.__index
		mt.__index = newcclosure(function(self, key)
			if key == "Kick" then return nil end
			return oldIndex(self, key)
		end)
	end
	protectPlayer()

	local function protectRemotes()
		for _, remote in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
			if remote:IsA("RemoteEvent") then
				remote.OnClientEvent:Connect(function() return end)
			end
		end
	end
	protectRemotes()

	local function hideConsole()
		local devConsole = game:GetService("CoreGui"):FindFirstChildOfClass("DeveloperConsole")
		if devConsole then devConsole.Enabled = false end
	end
	hideConsole()

	local function protectLocalScripts()
		for _, script in pairs(player.PlayerScripts:GetChildren()) do
			if script:IsA("LocalScript") and (script.Name:find("ban") or script.Name:find("kick")) then
				script:Destroy()
			end
		end
	end
	protectLocalScripts()

	while true do
		wait(10)
		for _, v in pairs(getconnections(player.PlayerAdded)) do v:Disable() end
	end
end)

-- UI CLH_Hub_UI Estilizada
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CLH_Hub_UI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 360, 0, 505)
Frame.Position = UDim2.new(0, 20, 0, 80)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 127)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🌟 Painel Tutuzaoprime/cortuis"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local y = 50
local function createButton(text, callback)
	local btn = Instance.new("TextButton", Frame)
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.Position = UDim2.new(0.05, 0, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)
	btn.MouseButton1Click:Connect(function() callback(btn) end)
	y += 35
end

local playerBox = Instance.new("TextBox", Frame)
playerBox.Size = UDim2.new(0.9, 0, 0, 30)
playerBox.Position = UDim2.new(0.05, 0, 0, y)
playerBox.PlaceholderText = "Digite nome do jogador"
playerBox.Text = ""
playerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
playerBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerBox.Font = Enum.Font.Gotham
playerBox.TextSize = 14
Instance.new("UICorner", playerBox).CornerRadius = UDim.new(0, 6)
y += 40

-- Funções
createButton("Definir Velocidade", function()
	local speed = tonumber(playerBox.Text)
	if speed then LocalPlayer.Character.Humanoid.WalkSpeed = speed end
end)

createButton("Teleportar para Jogador", function()
	local target = Players:FindFirstChild(playerBox.Text)
	if target and target.Character then
		LocalPlayer.Character:MoveTo(target.Character:GetPivot().Position + Vector3.new(0, 3, 0))
	end
end)

createButton("Trazer Jogador até Você", function()
	local target = Players:FindFirstChild(playerBox.Text)
	if target and target.Character then
		local myPos = LocalPlayer.Character:GetPivot().Position
		target.Character:SetPrimaryPartCFrame(CFrame.new(myPos + Vector3.new(2, 1, 0)))
	end
end)

createButton("👁 Ver Tela do Jogador", function()
	local target = Players:FindFirstChild(playerBox.Text)
	if target and target.Character and target.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = target.Character.Humanoid
	end
end)

createButton("↩️ Voltar à Sua Tela", function()
	Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
end)

createButton("Pulo Power!", function()
	LocalPlayer.Character.Humanoid.JumpPower = 120
	LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

createButton("Ativar Voo", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

createButton("👻 Invisibilidade", function()
	for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
		end
	end
end)
createButton("🚀 Ativar Fly Car", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Joaov8tor/fly-car/refs/heads/main/fly.lua'))()
end)

local noclipEnabled = false
createButton("🚪 Atravessar Paredes: ", function(btn)
	noclipEnabled = not noclipEnabled
	btn.Text = noclipEnabled and "🚪 Atravessar Paredes: ON" or "🚪 Atravessar Paredes: OFF"
end)

game:GetService("RunService").Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ESP
createButton("🔍 Ativar ESP", function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "ESPBox"
			box.Adornee = plr.Character
			box.Size = Vector3.new(4, 6, 2)
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Transparency = 0.5
			box.Color3 = plr.Team and plr.Team.TeamColor.Color or Color3.new(1, 0, 0)
			box.Parent = plr.Character
		end
	end
end)
-- Função para Ativar ESP nos carros
createButton("🚗 Ativar ESP Carro OFF", function()
    for _, vehicle in pairs(workspace:GetChildren()) do
        if vehicle:IsA("Model") and vehicle:FindFirstChild("PrimaryPart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPCarBox"
            box.Adornee = vehicle.PrimaryPart
            box.Size = vehicle:GetExtentsSize() -- Define o tamanho da caixa conforme o tamanho do veículo
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Transparency = 0.5
            box.Color3 = Color3.new(0, 0, 1) -- Defina a cor do ESP para azul (pode mudar conforme a necessidade)
            box.Parent = vehicle
        end
    end
end)

-- Botão flutuante para abrir/fechar
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Painel "
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.TextColor3 = Color3.fromRGB(0, 255, 127)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = ScreenGui

Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Color = Color3.fromRGB(0, 255, 127)
toggleStroke.Thickness = 1.5

local painelVisivel = true
toggleButton.MouseButton1Click:Connect(function()
	painelVisivel = not painelVisivel
	Frame.Visible = painelVisivel
end)
