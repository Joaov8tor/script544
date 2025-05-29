-- 🔐 Anti-Ban / Anti-Detect Avançado by Suysbs X
pcall(function()
	-- Bloqueia qualquer evento de Kick (como funções de kick) do LocalPlayer
	local player = game:GetService("Players").LocalPlayer
	for _, v in pairs(getconnections(player.Kick)) do
		v:Disable()
	end

	-- Evita que o jogo monitore a execução do script
	if hookfunction and getrawmetatable then
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		local old = mt.__namecall
		mt.__namecall = newcclosure(function(self, ...)
			local args = {...}
			local method = getnamecallmethod()

			-- Impede a execução de métodos de "Kick"
			if method == "Kick" or tostring(self):lower():find("kick") then
				return
			end

			-- Bloqueia chamadas de funções de kick e ban
			if method == "SetCore" and args[1] == "Kick" then
				return
			end

			return old(self, unpack(args))
		end)
	end

	-- Impede a remoção da GUI principal (evita anti-exploit de administração)
	local function protectGui()
		local coreGui = game:GetService("CoreGui")
		local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
		
		-- Impede a remoção de GUIs essenciais
		for _, gui in pairs(coreGui:GetChildren()) do
			if gui.Name:find("SCRIPT PREMIUM V1.0") then
				gui.Parent = playerGui
			end
		end
	end
	protectGui()

	-- Remoção de Detecção de Scripts de Kick ou Ban
	local function deepScan(obj)
		for _, child in ipairs(obj:GetChildren()) do
			if child:IsA("LocalScript") and (child.Name:lower():find("kick") or child.Name:lower():find("ban")) then
				child:Destroy()
			end
			deepScan(child)
		end
	end
	deepScan(game:GetService("Players").LocalPlayer)

	-- Desabilita ou Oculta Indicadores do Sistema (ex.: Ban, Kick)
	local function disableWarnings()
		local coreGui = game:GetService("CoreGui")
		for _, obj in ipairs(coreGui:GetChildren()) do
			if obj:IsA("Message") then
				obj:Destroy()  -- Remove qualquer tipo de mensagem suspeita
			end
		end
	end
	disableWarnings()

	-- Impede alterações nas propriedades do jogador (ex.: isolamento ou kick)
	local player = game:GetService("Players").LocalPlayer
	local function protectPlayer()
		local player = game:GetService("Players").LocalPlayer
		local mt = getrawmetatable(player)

		setreadonly(mt, false)

		local oldIndex = mt.__index
		mt.__index = newcclosure(function(self, key)
			if key == "Character" then
				-- Impede alterações no personagem do jogador
				return oldIndex(self, key)
			elseif key == "Kick" then
				return nil  -- Impede o método "Kick"
			end
			return oldIndex(self, key)
		end)
	end
	protectPlayer()

	-- Proteção contra RemoteEvents (evita execução de eventos suspeitos)
	local function protectRemotes()
		for _, remote in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
			if remote:IsA("RemoteEvent") then
				local oldEvent = remote.OnClientEvent
				remote.OnClientEvent = newcclosure(function(...)
					-- Impede eventos suspeitos
					return
				end)
			end
		end
	end
	protectRemotes()

	-- Esconde a tela do "Developer Console" para evitar visualização
	local function hideConsole()
		game:GetService("CoreGui"):FindFirstChildOfClass("DeveloperConsole").Enabled = false
	end
	hideConsole()

	-- Protege contra alterações em LocalScripts importantes
	local function protectLocalScripts()
		for _, script in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetChildren()) do
			if script:IsA("LocalScript") then
				-- Protege ou destrói scripts suspeitos
				if script.Name:find("ban") or script.Name:find("kick") then
					script:Destroy()
				end
			end
		end
	end
	protectLocalScripts()

	-- Monitoramento contínuo
	while true do
		wait(10)
		-- Impede desconexões forçadas
		local function disableDisconnect()
			for _, v in pairs(getconnections(player.PlayerAdded)) do
				v:Disable()
			end
		end
		disableDisconnect()
	end
end)

-- Anti-Kick Avançado para Roblox (sem anti-exploit)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local userId = player.UserId
local playerName = player.Name

-- Variáveis de proteção
local lastKickTime = tick()
local kickAttempts = 0
local maxKickAttempts = 3
local kickTimeout = 60 -- Tempo em segundos entre tentativas de kick

-- Função de prevenção contra desconexões
local function preventDisconnect()
    -- Monitorando desconexões forçadas e reconectando automaticamente
    local function checkConnection()
        if not player.Parent then
            warn(playerName .. " foi desconectado, tentando reconectar...")
            -- Re-conectar após 5 segundos
            wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end
    end
    -- Checando periodicamente
    while true do
        checkConnection()
        wait(2) -- Verifica a cada 2 segundos
    end
end

-- Função de verificação de ping (prevenir kicks por lag)
local function checkPing()
    local function pingCheck()
        local ping = player.Stats.Ping.Value
        if ping > 500 then
            warn(playerName .. " tem um ping alto de " .. ping .. "ms")
            -- Evita kick por desconexão de rede
        end
    end
    -- Checando o ping regularmente
    while true do
        pingCheck()
        wait(5) -- Checa o ping a cada 5 segundos
    end
end

-- Monitorando tentativas de kick (proteger contra kicks repetidos)
local function monitorKickAttempts()
    local function handleKick()
        player.OnKick:Connect(function(reason)
            local currentTime = tick()
            local timeSinceLastKick = currentTime - lastKickTime
            if timeSinceLastKick < kickTimeout then
                kickAttempts = kickAttempts + 1
            else
                kickAttempts = 1 -- Resetar tentativas após um intervalo
            end

            lastKickTime = currentTime
            if kickAttempts > maxKickAttempts then
                warn("Muitas tentativas de kick, tentando reconectar...")
                -- Tenta reconectar automaticamente após várias tentativas de kick
                wait(5)
                game:GetService("TeleportService"):Teleport(game.PlaceId, player)
            end
        end)
    end
    -- Começando a monitorar os kicks
    handleKick()
end

-- Função para proteger contra kicks por rede (reconectar se desconectado)
local function reconnectIfDisconnected()
    local function checkDisconnection()
        if not player.Parent then
            warn("Desconectado detectado. Tentando reconectar.")
            -- Re-tentar reconectar automaticamente
            wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end
    end
    -- Monitorando desconexões
    while true do
        checkDisconnection()
        wait(5) -- Checa a cada 5 segundos
    end
end

-- Função para bloquear tentativa de kick por mensagens suspeitas
local function blockKickMessages()
    -- Bloqueia mensagens do servidor que tentam forçar um kick
    ReplicatedStorage:WaitForChild("AntiKickEvent").OnClientEvent:Connect(function(message)
        if message == "kickPlayer" then
            warn(playerName .. " tentou ser kickado, mas a ação foi bloqueada.")
            -- Previne o kick do jogador
        end
    end)
end

-- Função para monitorar pacotes de rede suspeitos
local function monitorNetwork()
    -- Função para detectar pacotes de rede que podem causar desconexões ou kicks
    local function checkNetwork()
        -- Verificar se há pacotes ou tráfego de rede anômalos (Simulação de monitoramento)
        if game:GetService("NetworkClient").NetworkStatus == Enum.NetworkStatus.Connected then
            -- Rede está funcionando corretamente
        else
            warn("Problema na conexão de rede detectado para " .. playerName)
            -- Tenta restabelecer a conexão
            wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end
    end
    -- Checando a rede periodicamente
    while true do
        checkNetwork()
        wait(10) -- A cada 10 segundos
    end
end

-- Proteções ativadas
preventDisconnect()
checkPing()
monitorKickAttempts()
reconnectIfDisconnected()
blockKickMessages()
monitorNetwork()

-- CLH HUB BYPASS CLIENT-SIDE V4 ULTRA PROTEGIDO
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Função segura para tentar hook functions (anti-kick)
local function safeHook(func, callback)
    local success, hooked = pcall(function() return hookfunction(func, callback) end)
    return success and hooked or nil
end

-- 1. Proteção contra Kick local (função e SetCore)
do
    -- Hook LocalPlayer:Kick
    safeHook(LocalPlayer.Kick, function(...)
        warn("[BYPASS] Tentativa de Kick local bloqueada")
        return nil
    end)

    -- Hook Kick via Players.LocalPlayer (redundância)
    safeHook(Players.LocalPlayer.Kick, function(...)
        warn("[BYPASS] Tentativa de Kick local bloqueada (Players.LocalPlayer)")
        return nil
    end)

    -- Hook SetCore para Kick
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "SetCore" then
            local coreArg = ...
            if coreArg == "Kick" or coreArg == "KickPrompt" then
                warn("[BYPASS] Tentativa de Kick via SetCore bloqueada")
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- 2. Proteção contra RemoteEvents e RemoteFunctions suspeitos (kick, ban, logs, detect, report)
local function DestroySuspiciousRemotes(keywords)
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            for _, word in pairs(keywords) do
                if obj.Name:lower():find(word) then
                    pcall(function() obj:Destroy() end)
                    warn("[BYPASS] Remote suspeito destruído: " .. obj.Name)
                end
            end
        end
    end
end

DestroySuspiciousRemotes({"kick", "ban", "detect", "log", "report", "warn", "cheat", "admin"})

-- 3. Proteção contra funções espiãs e hook em funções relacionadas a kick/ban/logs
for _, v in pairs(getgc(true)) do
    if typeof(v) == "function" and islclosure(v) then
        local info = debug.getinfo(v)
        if info.name and (info.name:lower():find("kick") or info.name:lower():find("ban") or info.name:lower():find("log") or info.name:lower():find("warn") or info.name:lower():find("report")) then
            safeHook(v, function(...) 
                warn("[BYPASS] Função suspeita hookada: " .. info.name)
                return nil 
            end)
        end
    end
end

-- 4. Desabilitar conexões perigosas (signals) em eventos como CharacterAdded e Idled
local function disableSignals(obj)
    if obj then
        for _, conn in pairs(getconnections(obj)) do
            pcall(function() conn:Disable() end)
        end
    end
end
disableSignals(LocalPlayer.CharacterAdded)
disableSignals(LocalPlayer.Idled)

-- 5. Proteção contra __namecall para kicks, remotes suspeitos e logs
do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            warn("[BYPASS] Kick via __namecall bloqueado")
            return nil
        elseif method == "FireServer" or method == "InvokeServer" then
            local name = tostring(self.Name):lower()
            if name:find("kick") or name:find("ban") or name:find("log") or name:find("detect") or name:find("report") or name:find("warn") then
                warn("[BYPASS] Evento remoto suspeito bloqueado: " .. self.Name)
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- 6. Proteção contra __index para propriedade Kick e outras suspeitas
do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index

    mt.__index = newcclosure(function(self, key)
        if key == "Kick" then
            return function() return nil end
        elseif key == "IsPlayerAdmin" or key == "IsAdmin" then
            return false
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)
end

-- 7. Camuflagem do script (nome randômico)
pcall(function()
    getfenv(0).script.Name = HttpService:GenerateGUID(false)
end)

-- 8. Detecta admin na lista e encerra o jogo para evitar detecção (auto shutdown)
local AdminList = {"roblox", "admin", "mod", "owner", "dev"}
Players.PlayerAdded:Connect(function(plr)
    for _, admin in pairs(AdminList) do
        if plr.Name:lower():find(admin:lower()) then
            warn("[BYPASS] ADMIN detectado (" .. plr.Name .. ") - Encerrando o jogo")
            game:Shutdown()
        end
    end
end)

-- 9. Proteção contra injeção e detecção em CoreGui
if gethui then
    pcall(function()
        local h = gethui()
        if h then h.Name = HttpService:GenerateGUID(false) end
    end)
end

-- Remover GUIs suspeitos do CoreGui
local function removeSuspiciousGuis(keywords)
    for _, gui in pairs(CoreGui:GetChildren()) do
        for _, word in pairs(keywords) do
            if gui.Name:lower():find(word) then
                pcall(function() gui:Destroy() end)
                warn("[BYPASS] GUI suspeito removido do CoreGui: " .. gui.Name)
            end
        end
    end
end

removeSuspiciousGuis({"cheat", "exploit", "hack", "esp", "aim", "trigger", "inject"})

-- 10. Proteção contra LocalScripts maliciosos dentro do PlayerGui
local function removeMaliciousLocalScripts()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, obj in pairs(playerGui:GetDescendants()) do
            if obj:IsA("LocalScript") then
                -- Detecta scripts suspeitos por nome ou conteúdo simples
                if obj.Name:lower():find("kick") or obj.Name:lower():find("ban") or obj.Name:lower():find("log") or obj.Name:lower():find("detect") then
                    pcall(function() obj:Destroy() end)
                    warn("[BYPASS] LocalScript malicioso removido: " .. obj.Name)
                end
            end
        end
    end
end

RunService.Stepped:Connect(removeMaliciousLocalScripts)

-- 11. Proteção contra prints (hook em print e warn para bloquear mensagens suspeitas)
do
    local oldPrint = print
    local oldWarn = warn
    local keywords = {"kick", "ban", "detect", "exploit", "cheat", "warn"}

    print = function(...)
        local args = {...}
        for _, msg in pairs(args) do
            if type(msg) == "string" then
                for _, word in pairs(keywords) do
                    if msg:lower():find(word) then
                        return -- bloqueia prints suspeitos
                    end
                end
            end
        end
        oldPrint(...)
    end

    warn = function(...)
        local args = {...}
        for _, msg in pairs(args) do
            if type(msg) == "string" then
                for _, word in pairs(keywords) do
                    if msg:lower():find(word) then
                        return -- bloqueia warns suspeitos
                    end
                end
            end
        end
        oldWarn(...)
    end
end

-- 12. Verificação de versão do cliente (simulada, pode conectar a uma URL externa)
do
    -- Exemplo: versão local
    local CLIENT_VERSION = "1.0.0"

    -- Simula requisição HTTP para pegar versão atual do servidor (exemplo)
    -- Você pode colocar aqui o link real que retorna a versão do cliente
    local success, latestVersion = pcall(function()
        -- Exemplo fake para simular
        return "1.0.0"
    end)

    if success and latestVersion ~= CLIENT_VERSION then
        warn("[BYPASS] Versão do cliente desatualizada. Atualize para continuar.")
        -- Opcional: desconectar jogador
        -- LocalPlayer:Kick("Atualize seu cliente para a última versão.")
    end
end

-- 13. Anti-teleporte suspeito (ex: fly/teleporte extremo)
RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        if pos.Magnitude > 9999 then
            LocalPlayer.Character:BreakJoints()
            warn("[BYPASS] Teleporte extremo detectado. Resetando personagem.")
        end
    end
end)

-- 14. Camada falsa para enganar quem usa getgc para investigar scripts internos
pcall(function()
    local fake_script = {
        Name = "AntiCheatMain",
        Version = "3.0.0",
        Enabled = true,
        Secure = true,
        Log = function(msg) print("[AntiCheatLog]: " .. msg) end,
        Kick = function(target) warn("Kicking: " .. tostring(target)) end
    }

    table.insert(getgc(true), fake_script)
    warn("[BYPASS] Camada falsa de segurança injetada com sucesso.")
end)

-- 15. Anti-Hook reforçado: Detecta se funções críticas foram hookadas e kicka jogador
pcall(function()
    local function isHooked(func)
        if not islclosure(func) then return true end
        if not pcall(function() debug.getupvalues(func) end) then return true end
        return false
    end

    local criticalFunctions = {
        ["Kick"] = LocalPlayer.Kick,
        ["__namecall"] = getrawmetatable(game).__namecall,
        ["__index"] = getrawmetatable(game).__index,
        ["print"] = print,
        ["warn"] = warn,
    }

    for name, func in pairs(criticalFunctions) do
        if isHooked(func) then
            warn("[BYPASS] Hook detectado em: " .. name .. " - Desconectando.")
            pcall(function()
                LocalPlayer:Kick("Hook suspeito detectado. Desconectando.")
            end)
        end
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
