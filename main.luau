if not game:IsLoaded() then game.Loaded:Wait(); end;

local cloneref = cloneref or function(i: Instance) return i; end;
local _ = cloneref(game:GetService("CoreGui"));
local hui = _:FindFirstChild("RobloxGui") or _;
if gethui then local s, r = pcall(gethui); if s then hui = cloneref(r); end; end;
local SG = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-notifications/refs/heads/main/main.luau"))();
local get_id = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-fov-lib/refs/heads/main/get_id.luau"))();
local info = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-fov-lib/refs/heads/main/info.luau"))();
local discord_link = info.discord_link;

if workspace:FindFirstChild("QueuePads") or workspace:FindFirstChild("QueueSystem") then
    SG["info"]("You can't execute the autofarm in the lobby! You can only execute it if you're in an actual game!");
    return;
end;

local Players: Players = cloneref(game:GetService("Players"));
local RS: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"));
local RunService: RunService = cloneref(game:GetService("RunService"));

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;
local class = plr:FindFirstChild("EquippedClass") or plr:FindFirstChildOfClass("StringValue");
local bp: Backpack = plr.Backpack;
local pg = plr.PlayerGui;

local Progress: TextLabel? = pg:FindFirstChild("MainFrame") and pg.MainFrame:FindFirstChild("SuspiciousFrame") and pg.MainFrame.SuspiciousFrame:FindFirstChild("BarFrame") and pg.MainFrame.SuspiciousFrame.BarFrame:FindFirstChild("Progress");

local Map: Folder = workspace:FindFirstChild("Map");
local Remotes: Folder = RS:FindFirstChild("Remotes");
local Utilities: Folder = Remotes and Remotes:FindFirstChild("Utilities");

local Start: RemoteFunction = Utilities and Utilities:FindFirstChild("StartATMGame");
local HC: RemoteEvent = Utilities and Utilities:FindFirstChild("HitCashier");
local Skip: RemoteEvent = Remotes and Remotes:FindFirstChild("SkipEvent");
local Replay: RemoteEvent = Remotes and Remotes:FindFirstChild("PlayAgain");
local End: RemoteEvent = Remotes and Remotes:FindFirstChild("FinishedStats");

local StealableItems: Folder = Map and Map:FindFirstChild("StealableItems");
local Others: Folder = Map and Map:FindFirstChild("Others");

local ATMs: Folder = Others and Others:FindFirstChild("ATM");
local Cashiers: Folder = Others and Others:FindFirstChild("Special") and Others.Special:FindFirstChild("Cashiers");
local Natural: Folder = StealableItems and StealableItems:FindFirstChild("Natural");
local Truck: Model = Map and Map:FindFirstChild("Truck");
local CollectTruck: Model = Map and Map:FindFirstChild("CollectTruck");

local TouchPart: BasePart = CollectTruck and CollectTruck:FindFirstChild("TouchPart");

if not (class and Progress and Map and Remotes and Utilities and Start and HC and Skip and Replay and End and StealableItems and Natural and Truck and CollectTruck and TouchPart) then
    local err = "Script needs updating";
    SG["error"](err);
    return warn(err);
end;

return function(rejoined: boolean)
    if rejoined then
        task.wait(10);
    end;

    local main = Instance.new("Frame", hui);
    main.AnchorPoint = Vector2.new(0.5, 0);
    main.Position = UDim2.new(0.5, 0, 0, 0);
    main.Size = UDim2.new(0.1, 0, 0.1, 0);
    main.BackgroundTransparency = 1;

    local logo = Instance.new("ImageButton", main);
    logo.AnchorPoint = Vector2.new(0, 0.5);
    logo.Position = UDim2.new(0, 0, 0.5, 0);
    logo.Size = UDim2.new(0.5, 0, 1, 0);
    logo.Image = get_id("logo");

    local ex = Instance.new("TextButton", main);
    ex.AnchorPoint = Vector2.new(1, 0.5);
    ex.Position = UDim2.new(1, 0, 0.5, 0);
    ex.Size = UDim2.new(0.5, 0, 1, 0);
    ex.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
    ex.TextScaled = true;
    ex.TextColor3 = Color3.new(1, 1, 1);
    ex.Text = "Exit";

    local link = function()
        if setclipboard then
            setclipboard(discord_link);
            SG["info"]("Discord server link copied to clipboard!");
        else
            SG["info"]("Discord server link: " .. discord_link);
        end;
    end;

    local _ex = function()
        if exit then
            exit();
        else
            plr:Kick("Exited");
        end;
    end;

    local timeout = 1;
    local c: RBXScriptConnection;

    local to = function(h: Humanoid, r: BasePart, cf: CFrame, isConst: boolean?)
        if c then c:Disconnect(); end;

        if isConst then
            cam.CameraType = Enum.CameraType.Scriptable;
            h.PlatformStand = true;
            c = RunService.RenderStepped:Connect(function()
                if r and r.Parent then
                    r.AssemblyLinearVelocity = Vector3.zero;
                    r.AssemblyAngularVelocity = Vector3.zero;
                    r.CFrame = cf;
                end;
            end);
            task.wait();
            cam.CFrame = CFrame.lookAt(r.Position + Vector3.new(0, 10, 0), r.Position);
        else
            cam.CameraType = Enum.CameraType.Custom;
            h.PlatformStand = false;
            r.CFrame = cf;
        end;
    end;

    local del = function()
        for _, v in next, getnilinstances() do
            if v.ClassName == "BindableEvent" and v.Name == "Event" then
                v:Destroy();
            end;
        end;
    end;

    local get = function(): BindableEvent?
        for _, v in next, getnilinstances() do
            if v.ClassName == "BindableEvent" and v.Name == "Event" then
                return v;
            end;
        end;
        return nil;
    end;

    local focus = function(prompt: ProximityPrompt)
        prompt.Enabled = true;
        for _, v: ProximityPrompt in next, workspace:QueryDescendants("ProximityPrompt") do
            if v == prompt then continue; end;
            v.Enabled = false;
        end;
    end;

    local finish = function(h: Humanoid, r: BasePart)
        print("Finished")
        local seat = Truck:QueryDescendants("Seat")[1];
        to(h, r, CFrame.new(TouchPart.Position));
        h:MoveTo(seat.Position, seat);
        h.MoveToFinished:Wait();
        seat:Sit(h);
    end;

    local earlyStop = false;

    Start.OnClientInvoke = function()
        local event;
        repeat
            event = select(2, pcall(get));
            task.wait();
        until event;
        event:Fire();
        return true;
    end;

    End.OnClientEvent:Once(function()
        queue_on_teleport("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/sneekygoober/Rob-It-Autofarm-Script/refs/heads/main/main.luau\"))()(true);");
        Replay:FireServer("Replay");
    end);

    Progress:GetPropertyChangedSignal("Text"):Connect(function()
        if Progress.Text == "VAN LEAVING IN: 00m 05s" then
            earlyStop = true;
        end;
    end);

    logo.MouseButton1Up:Connect(link);
    ex.MouseButton1Up:Connect(_ex);
    logo.TouchTap:Connect(link);
    ex.TouchTap:Connect(_ex);

    task.spawn(function()
        Skip:FireServer();
        task.wait(5);
        while task.wait() do
            local char = plr.Character;
            local h = char and char:FindFirstChildOfClass("Humanoid") or nil;
            local r: BasePart? = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootpart") or nil) or nil;
            if not (char and h and r) then
                timeout += 1;
                if timeout >= 2 then
                    SG["error"]("Timed out!");
                    warn("Timed out!");
                    break;
                end;
                continue;
            end;
            timeout = 1;

            if h.Health <= 15 then
                finish(h, r);
                break;
            end;

            if Cashiers then
                for _, v: Model in next, Cashiers:GetChildren() do
                    if earlyStop then break; end;

                    local SI: BasePart = v:FindFirstChild("ServiceIndicator");
                    if not SI or SI.Color ~= Color3.new(0, 1, 0) then continue; end;

                    repeat
                        HC:FireServer(v, "Crowbar");
                        task.wait();
                    until SI.Color == Color3.new(0, 0, 0);

                    print("Hit " .. v:GetFullName());
                end;
            end;

            if ATMs and class and class.Value == "Hacker" and not earlyStop then
                for _, v: Model in next, ATMs:GetChildren() do
                    if earlyStop then break; end;

                    local prompt = v:QueryDescendants("ProximityPrompt")[1];
                    local Screen: BasePart = v:FindFirstChild("Screen");
                    if not (prompt and Screen) or Screen.Color ~= Color3.fromRGB(190, 104, 98) then continue; end;
                    print(prompt:GetFullName());

                    local cf = CFrame.new(v.PrimaryPart.Position) + Vector3.new(0, prompt.MaxActivationDistance, 0);
                    if not cf then return; end;

                    to(h, r, cf, true);
                    task.wait(0.1);

                    local max = prompt.MaxActivationDistance;
                    prompt.RequiresLineOfSight = false;
                    prompt.MaxActivationDistance = math.huge;
                    focus(prompt);

                    local done = false;
                    local c; c = prompt.Triggered:Connect(function(player: Player)
                        if player == plr then
                            print("Prompted");
                            done = true;
                            c:Disconnect();
                            c = nil;
                        end;
                    end);

                    repeat
                        prompt:InputHoldBegin();
                        task.wait();
                    until done;

                    del();
                    task.wait(prompt.HoldDuration + 0.003);
                    prompt:InputHoldEnd();
                    prompt.MaxActivationDistance = max;
                end;
            end;

            local num = 1;
            local sorted = {};
            for _, v: Model | BasePart in next, StealableItems:QueryDescendants("Model, BasePart") do
                if earlyStop then break; end;

                local prompt = v:FindFirstChild("Prompt")
                if not prompt then continue; end;

                local part = v.ClassName == "Model" and v.PrimaryPart or v;
                if part then
                    sorted[#sorted+1] = {
                        ["Part"] = part,
                        ["Prompt"] = prompt
                    };
                end;
            end;

            table.sort(sorted, function(a, b)
                return a.Prompt.HoldDuration < b.Prompt.HoldDuration;
            end);

            for _, v: {string: BasePart, string: ProximityPrompt} in next, sorted do
                if earlyStop then break; end;

                local cf = CFrame.new(v.Part.Position) + Vector3.new(0, v.Prompt.MaxActivationDistance, 0);
                if not cf then return; end;

                print(v.Prompt:GetFullName());

                to(h, r, cf, true);
                task.wait(0.1);

                local max = v.Prompt.MaxActivationDistance;
                v.Prompt.RequiresLineOfSight = false;
                v.Prompt.MaxActivationDistance = math.huge;
                focus(v.Prompt);

                local done = false;
                local c; c = v.Prompt.Triggered:Connect(function(player: Player)
                    if player == plr then
                        print("Prompted");
                        done = true;
                        c:Disconnect();
                        c = nil;
                    end;
                end);

                repeat
                    v.Prompt:InputHoldBegin();
                    task.wait();
                until done;

                task.wait(v.Prompt.HoldDuration + 0.003);
                v.Prompt:InputHoldEnd();
                v.Prompt.MaxActivationDistance = max;

                num = (num % 12) + 1;
                if num == 12 then
                    print("Selling")
                    to(h, r, CFrame.new(TouchPart.Position), true);
                    task.wait(0.5);
                end;
            end;

            if (#StealableItems:GetChildren() <= 1 and #Natural:GetChildren() <= 0) or earlyStop then
                finish(h, r);
                break;
            end;
        end;
    end);

    SG["success"]("Autofarm successfully executed!\nIf you have any issues press F9 or type /console in chat and then send me a screenshot of the console.");
end;
