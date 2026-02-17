local library = {count = 0, queue = {}, callbacks = {}, toggled = true, binds = {}};

local defaults = {
	topcolor = Color3.fromRGB(18, 18, 18);
	bgcolor = Color3.fromRGB(25, 25, 25);
	boxcolor = Color3.fromRGB(32, 32, 32);
	btncolor = Color3.fromRGB(35, 35, 35);
	dropcolor = Color3.fromRGB(28, 28, 28);
	sectncolor = Color3.fromRGB(22, 22, 22);
	bordercolor = Color3.fromRGB(48, 48, 48);
	font = Enum.Font.Gotham;
	titlefont = Enum.Font.GothamSemibold;
	fontsize = 15;
	titlesize = 17;
	textstroke = 0.4;
	titlestroke = 0.4;
	strokecolor = Color3.fromRGB(0, 0, 0);
	textcolor = Color3.fromRGB(235, 235, 235);
	titletextcolor = Color3.fromRGB(255, 255, 255);
	placeholdercolor = Color3.fromRGB(130, 130, 130);
	titlestrokecolor = Color3.fromRGB(0, 0, 0);
	underlinecolor = Color3.fromRGB(255, 255, 255);
};

local dragger = {};
do
	local players = game:GetService("Players");
	local player = players.LocalPlayer;
	local mouse = player:GetMouse();
	local run = game:GetService("RunService");
	local stepped = run.Stepped;
	dragger.new = function(obj)
		task.spawn(function()
			local minitial;
			local initial;
			local isdragging;
			obj.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					isdragging = true;
					minitial = input.Position;
					initial = obj.Position;
					local con;
					con = stepped:Connect(function()
						if isdragging then
							local delta = Vector3.new(mouse.X, mouse.Y, 0) - minitial;
							obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y);
						else
							con:Disconnect();
						end;
					end);
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							isdragging = false;
						end;
					end);
				end;
			end);
		end);
	end;
end;

local types = {};
types.__index = types;

function types:window(name, options)
	library.count = library.count + 1;
	local newWindow = library:Create("Frame", {
		Name = name;
		Size = UDim2.new(0, 210, 0, 38);
		BackgroundColor3 = options.topcolor;
		BorderSizePixel = 0;
		Parent = library.container;
		Position = UDim2.new(0, (25 + (220 * library.count) - 220), 0, 25);
		ZIndex = 3;
	});
	library:Create("TextLabel", {
		Text = name;
		Size = UDim2.new(1, -45, 1, 0);
		Position = UDim2.new(0, 12, 0, 0);
		BackgroundTransparency = 1;
		Font = options.titlefont;
		TextSize = options.titlesize;
		TextColor3 = options.titletextcolor;
		TextStrokeTransparency = options.titlestroke;
		TextStrokeColor3 = options.titlestrokecolor;
		ZIndex = 3;
		Parent = newWindow;
	});
	library:Create("TextButton", {
		Size = UDim2.new(0, 32, 0, 32);
		Position = UDim2.new(1, -38, 0, 0);
		BackgroundTransparency = 1;
		Text = "-";
		TextSize = options.titlesize;
		Font = options.titlefont;
		Name = "window_toggle";
		TextColor3 = options.titletextcolor;
		TextStrokeTransparency = options.titlestroke;
		TextStrokeColor3 = options.titlestrokecolor;
		ZIndex = 3;
		Parent = newWindow;
	});
	library:Create("Frame", {
		Name = "Underline";
		Size = UDim2.new(1, 0, 0, 2);
		Position = UDim2.new(0, 0, 1, -2);
		BackgroundColor3 = options.underlinecolor;
		BorderSizePixel = 0;
		ZIndex = 3;
		Parent = newWindow;
	});
	local container = library:Create("Frame", {
		Name = "container";
		Position = UDim2.new(0, 0, 1, 0);
		Size = UDim2.new(1, 0, 0, 0);
		BorderSizePixel = 0;
		BackgroundColor3 = options.bgcolor;
		ClipsDescendants = false;
		Parent = newWindow;
	});
	library:Create("UIListLayout", {
		Name = "List";
		SortOrder = Enum.SortOrder.LayoutOrder;
		Padding = UDim.new(0, 6);
		Parent = container;
	});
	local window = setmetatable({
		count = 0;
		object = newWindow;
		container = container;
		toggled = true;
		flags = {};
	}, types);
	table.insert(library.queue, {
		w = window.object;
		p = window.object.Position;
	});
	newWindow.window_toggle.MouseButton1Click:Connect(function()
		window.toggled = not window.toggled;
		newWindow.window_toggle.Text = (window.toggled and "-" or "+");
		if (not window.toggled) then
			container.ClipsDescendants = true;
		end;
		local y = 0;
		for _, v in next, container:GetChildren() do
			if (not v:IsA("UIListLayout")) then
				y = y + v.AbsoluteSize.Y;
			end;
		end;
		local targetSize = window.toggled and UDim2.new(1, 0, 0, y + 12) or UDim2.new(1, 0, 0, 0);
		local tween = game:GetService("TweenService"):Create(container, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize});
		tween:Play();
		tween.Completed:Connect(function()
			if window.toggled then
				container.ClipsDescendants = false;
			end;
		end);
	end);
	return window;
end;

function types:Resize()
	local y = 0;
	for _, v in next, self.container:GetChildren() do
		if (not v:IsA("UIListLayout")) then
			y = y + v.AbsoluteSize.Y;
		end;
	end;
	self.container.Size = UDim2.new(1, 0, 0, y + 12);
end;

function types:GetOrder()
	local c = 0;
	for _, v in next, self.container:GetChildren() do
		if (not v:IsA("UIListLayout")) then
			c = c + 1;
		end;
	end;
	return c;
end;

function types:Toggle(name, options, callback)
	local default = options.default or false;
	local location = options.location or self.flags;
	local flag = options.flag or "";
	local callback = callback or function() end;
	location[flag] = default;
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 28);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	library:Create("TextLabel", {
		Name = name;
		Text = name;
		BackgroundTransparency = 1;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, 12, 0, 0);
		Size = UDim2.new(1, -45, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Left;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = check;
	});
	local checkmark = library:Create("TextButton", {
		Text = (location[flag] and "✓" or "");
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Name = "Checkmark";
		Size = UDim2.new(0, 24, 0, 24);
		Position = UDim2.new(1, -32, 0, 2);
		TextColor3 = library.options.textcolor;
		BackgroundColor3 = library.options.btncolor;
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = check;
	});
	local function click()
		location[flag] = not location[flag];
		callback(location[flag]);
		checkmark.Text = location[flag] and "✓" or "";
	end;
	checkmark.MouseButton1Click:Connect(click);
	library.callbacks[flag] = click;
	if location[flag] == true then
		callback(location[flag]);
	end;
	self:Resize();
	return {
		Set = function(self, b)
			location[flag] = b;
			callback(location[flag]);
			checkmark.Text = location[flag] and "✓" or "";
		end;
	};
end;

function types:Button(name, callback)
	callback = callback or function() end;
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 32);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	local button = library:Create("TextButton", {
		Name = name;
		Text = name;
		BackgroundColor3 = library.options.btncolor;
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, 8, 0, 4);
		Size = UDim2.new(1, -16, 0, 24);
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Parent = check;
	});
	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}):Play();
	end);
	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(button, tweenInfo, {BackgroundColor3 = library.options.btncolor}):Play();
	end);
	button.MouseButton1Click:Connect(callback);
	self:Resize();
	return {
		Fire = function()
			callback();
		end;
	};
end;

function types:Box(name, options, callback)
	local typ = options.type or "";
	local default = options.default or "";
	local location = options.location or self.flags;
	local flag = options.flag or "";
	local callback = callback or function() end;
	local min = options.min or 0;
	local max = options.max or 9e9;
	if typ == "number" and (not tonumber(default)) then
		location[flag] = default;
	else
		location[flag] = "";
		default = "";
	end;
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 28);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	library:Create("TextLabel", {
		Name = name;
		Text = name;
		BackgroundTransparency = 1;
		TextColor3 = library.options.textcolor;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Position = UDim2.new(0, 12, 0, 0);
		Size = UDim2.new(1, -85, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Left;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Parent = check;
	});
	local box = library:Create("TextBox", {
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Text = tostring(default);
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Name = "Box";
		Size = UDim2.new(0, 68, 0, 24);
		Position = UDim2.new(1, -76, 0, 2);
		TextColor3 = library.options.textcolor;
		BackgroundColor3 = library.options.boxcolor;
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		PlaceholderColor3 = library.options.placeholdercolor;
		Parent = check;
	});
	box.FocusLost:Connect(function(e)
		local old = location[flag];
		if typ == "number" then
			local num = tonumber(box.Text);
			if (not num) then
				box.Text = tostring(location[flag]);
			else
				location[flag] = math.clamp(num, min, max);
				box.Text = tostring(location[flag]);
			end;
		else
			location[flag] = tostring(box.Text);
		end;
		callback(location[flag], old, e);
	end);
	if typ == "number" then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			box.Text = string.gsub(box.Text, "[^%d.-]", "");
		end);
	end;
	self:Resize();
	return box;
end;

function types:Bind(name, options, callback)
	local location = options.location or self.flags;
	local keyboardOnly = options.kbonly or false;
	local flag = options.flag or "";
	local callback = callback or function() end;
	local default = options.default;
	location[flag] = default;
	local banned = {
		Return = true;
		Space = true;
		Tab = true;
		Unknown = true;
	};
	local shortNames = {
		RightControl = "RightCtrl";
		LeftControl = "LeftCtrl";
		LeftShift = "LShift";
		RightShift = "RShift";
		MouseButton1 = "Mouse1";
		MouseButton2 = "Mouse2";
	};
	local allowed = {
		MouseButton1 = true;
		MouseButton2 = true;
	};
	local nm = (default and (shortNames[default.Name] or default.Name) or "None");
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 32);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	library:Create("TextLabel", {
		Name = name;
		Text = name;
		BackgroundTransparency = 1;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, 12, 0, 0);
		Size = UDim2.new(1, -45, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Left;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = check;
	});
	local button = library:Create("TextButton", {
		Name = "Keybind";
		Text = nm;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Size = UDim2.new(0, 68, 0, 24);
		Position = UDim2.new(1, -76, 0, 4);
		TextColor3 = library.options.textcolor;
		BackgroundColor3 = library.options.bgcolor;
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		Parent = check;
	});
	button.MouseButton1Click:Connect(function()
		library.binding = true;
		button.Text = "...";
		local a, b = game:GetService("UserInputService").InputBegan:Wait();
		local name = tostring(a.KeyCode.Name);
		local typeName = tostring(a.UserInputType.Name);
		if (a.UserInputType ~= Enum.UserInputType.Keyboard and (allowed[a.UserInputType.Name]) and (not keyboardOnly)) or (a.KeyCode and (not banned[a.KeyCode.Name])) then
			local name = (a.UserInputType ~= Enum.UserInputType.Keyboard and a.UserInputType.Name or a.KeyCode.Name);
			location[flag] = a;
			button.Text = shortNames[name] or name;
		else
			if (location[flag]) then
				if (not pcall(function() return location[flag].UserInputType; end)) then
					local name = tostring(location[flag]);
					button.Text = shortNames[name] or name;
				else
					local name = (location[flag].UserInputType ~= Enum.UserInputType.Keyboard and location[flag].UserInputType.Name or location[flag].KeyCode.Name);
					button.Text = shortNames[name] or name;
				end;
			end;
		end;
		task.wait(0.1);
		library.binding = false;
	end);
	if location[flag] then
		button.Text = shortNames[tostring(location[flag].Name)] or tostring(location[flag].Name);
	end;
	library.binds[flag] = {
		location = location;
		callback = callback;
	};
	self:Resize();
end;

function types:Section(name)
	local order = self:GetOrder();
	local check = library:Create("Frame", {
		Name = "Section";
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 26);
		BorderSizePixel = 0;
		LayoutOrder = order;
		Parent = self.container;
	});
	library:Create("TextLabel", {
		Name = "section_lbl";
		Text = name;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, 12, 0, 0);
		Size = UDim2.new(1, -10, 1, 0);
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = check;
	});
	self:Resize();
end;

function types:Slider(name, options, callback)
	local default = options.default or options.min;
	local min = options.min or 0;
	local max = options.max or 1;
	local location = options.location or self.flags;
	local precise = options.precise or false;
	local flag = options.flag or "";
	local callback = callback or function() end;
	location[flag] = default;
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 32);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	library:Create("TextLabel", {
		Name = name;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Text = name;
		BackgroundTransparency = 1;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, 12, 0, 4);
		Size = UDim2.new(1, -85, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Left;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Parent = check;
	});
	local container = library:Create("Frame", {
		Name = "Container";
		Size = UDim2.new(0, 68, 0, 24);
		Position = UDim2.new(1, -76, 0, 4);
		BackgroundTransparency = 1;
		Parent = check;
	});
	library:Create("TextLabel", {
		Name = "ValueLabel";
		Text = default;
		BackgroundTransparency = 1;
		TextColor3 = library.options.textcolor;
		Position = UDim2.new(0, -8, 0, 0);
		Size = UDim2.new(0, 1, 1, 0);
		TextXAlignment = Enum.TextXAlignment.Right;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = container;
	});
	local button = library:Create("TextButton", {
		Name = "Button";
		Size = UDim2.new(0, 6, 1, -4);
		Position = UDim2.new(0, 0, 0, 2);
		AutoButtonColor = false;
		Text = "";
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		BorderSizePixel = 0;
		ZIndex = 2;
		Parent = container;
	});
	library:Create("Frame", {
		Name = "Line";
		BackgroundTransparency = 0;
		Position = UDim2.new(0, 0, 0.5, 0);
		Size = UDim2.new(1, 0, 0, 2);
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		BorderSizePixel = 0;
		Parent = container;
	});
	local renderSteppedConnection;
	local inputBeganConnection;
	local inputEndedConnection;
	local mouseLeaveConnection;
	local mouseDownConnection;
	local mouseUpConnection;
	container.MouseEnter:Connect(function()
		local function update()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect();
			end;
			renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
				local mouse = game:GetService("UserInputService"):GetMouseLocation();
				local percent = (mouse.X - container.AbsolutePosition.X) / container.AbsoluteSize.X;
				percent = math.clamp(percent, 0, 1);
				percent = tonumber(string.format("%.2f", percent));
				button.Position = UDim2.new(math.clamp(percent, 0, 0.99), 0, 0, 1);
				local num = min + (max - min) * percent;
				local value = (precise and num or math.floor(num));
				container.ValueLabel.Text = value;
				callback(tonumber(value));
				location[flag] = tonumber(value);
			end);
		end;
		local function disconnect()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect();
			end;
			if inputBeganConnection then
				inputBeganConnection:Disconnect();
			end;
			if inputEndedConnection then
				inputEndedConnection:Disconnect();
			end;
			if mouseLeaveConnection then
				mouseLeaveConnection:Disconnect();
			end;
			if mouseUpConnection then
				mouseUpConnection:Disconnect();
			end;
		end;
		inputBeganConnection = container.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				update();
			end;
		end);
		inputEndedConnection = container.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				disconnect();
			end;
		end);
		mouseDownConnection = button.MouseButton1Down:Connect(update);
		mouseUpConnection = game:GetService("UserInputService").InputEnded:Connect(function(a)
			if a.UserInputType == Enum.UserInputType.MouseButton1 and (mouseDownConnection.Connected) then
				disconnect();
			end;
		end);
	end);
	if default ~= min then
		local percent = 1 - ((max - default) / (max - min));
		local number = default;
		number = tonumber(string.format("%.2f", number));
		if (not precise) then
			number = math.floor(number);
		end;
		button.Position = UDim2.new(math.clamp(percent, 0, 0.99), 0, 0, 1);
		container.ValueLabel.Text = number;
	end;
	self:Resize();
	return {
		Set = function(self, value)
			local percent = 1 - ((max - value) / (max - min));
			local number = value;
			number = tonumber(string.format("%.2f", number));
			if (not precise) then
				number = math.floor(number);
			end;
			button.Position = UDim2.new(math.clamp(percent, 0, 0.99), 0, 0, 1);
			container.ValueLabel.Text = number;
			location[flag] = number;
			callback(number);
		end;
	};
end;

function types:SearchBox(text, options, callback)
	local list = options.list or {};
	local flag = options.flag or "";
	local location = options.location or self.flags;
	local callback = callback or function() end;
	local busy = false;
	local box = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 28);
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	local textbox = library:Create("TextBox", {
		Text = "";
		PlaceholderText = text;
		PlaceholderColor3 = Color3.fromRGB(110, 110, 110);
		Font = library.options.font;
		TextSize = library.options.fontsize;
		Name = "Box";
		Size = UDim2.new(1, -16, 0, 24);
		Position = UDim2.new(0, 8, 0, 2);
		TextColor3 = library.options.textcolor;
		BackgroundColor3 = library.options.dropcolor;
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = box;
	});
	local scroll = library:Create("ScrollingFrame", {
		Position = UDim2.new(0, 0, 1, 4);
		Name = "Container";
		BackgroundColor3 = library.options.btncolor;
		ScrollBarThickness = 0;
		BorderSizePixel = 0;
		BorderColor3 = library.options.bordercolor;
		Size = UDim2.new(1, 0, 0, 0);
		Parent = textbox;
	});
	library:Create("UIListLayout", {
		Name = "ListLayout";
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = scroll;
	});
	local function rebuild(text)
		textbox.Container.ScrollBarThickness = 0;
		for _, child in next, textbox.Container:GetChildren() do
			if (not child:IsA("UIListLayout")) then
				child:Destroy();
			end;
		end;
		if #text > 0 then
			for _, v in next, list do
				if string.sub(string.lower(v), 1, string.len(text)) == string.lower(text) then
					local button = library:Create("TextButton", {
						Text = v;
						Font = library.options.font;
						TextSize = library.options.fontsize;
						TextColor3 = library.options.textcolor;
						BorderColor3 = library.options.bordercolor;
						BorderSizePixel = 1;
						TextStrokeTransparency = library.options.textstroke;
						TextStrokeColor3 = library.options.strokecolor;
						Parent = textbox.Container;
						Size = UDim2.new(1, 0, 0, 22);
						LayoutOrder = _;
						BackgroundColor3 = library.options.btncolor;
						ZIndex = 2;
					});
					button.MouseButton1Click:Connect(function()
						busy = true;
						textbox.Text = button.Text;
						task.wait();
						busy = false;
						location[flag] = button.Text;
						callback(location[flag]);
						textbox.Container.ScrollBarThickness = 0;
						for _, child in next, textbox.Container:GetChildren() do
							if (not child:IsA("UIListLayout")) then
								child:Destroy();
							end;
						end;
						textbox.Container:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.18, true);
					end);
				end;
			end;
		end;
		local c = textbox.Container:GetChildren();
		local ry = (22 * (#c)) - 22;
		local y = math.clamp((22 * (#c)) - 22, 0, 120);
		if ry > 120 then
			textbox.Container.ScrollBarThickness = 4;
		end;
		textbox.Container:TweenSize(UDim2.new(1, 0, 0, y), "Out", "Quad", 0.18, true);
		textbox.Container.CanvasSize = UDim2.new(1, 0, 0, (22 * (#c)) - 22);
	end;
	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		if (not busy) then
			rebuild(textbox.Text);
		end;
	end);
	local function reload(new_list)
		list = new_list;
		rebuild("");
	end;
	self:Resize();
	return reload, textbox;
end;

function types:Dropdown(name, options, callback)
	local location = options.location or self.flags;
	local flag = options.flag or "";
	local callback = callback or function() end;
	local list = options.list or {};
	location[flag] = list[1];
	local check = library:Create("Frame", {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 0, 28);
		BorderSizePixel = 0;
		LayoutOrder = self:GetOrder();
		Parent = self.container;
	});
	local dropdown = library:Create("Frame", {
		Name = "dropdown_lbl";
		BackgroundTransparency = 0;
		BackgroundColor3 = library.options.dropcolor;
		Position = UDim2.new(0, 8, 0, 2);
		BorderColor3 = library.options.bordercolor;
		BorderSizePixel = 1;
		Size = UDim2.new(1, -16, 0, 24);
		Parent = check;
	});
	library:Create("TextLabel", {
		Name = "Selection";
		Size = UDim2.new(1, 0, 1, 0);
		Text = list[1];
		TextColor3 = library.options.textcolor;
		BackgroundTransparency = 1;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = dropdown;
	});
	library:Create("TextButton", {
		Name = "drop";
		BackgroundTransparency = 1;
		Size = UDim2.new(0, 24, 1, 0);
		Position = UDim2.new(1, -28, 0, 0);
		Text = "▼";
		TextColor3 = library.options.textcolor;
		Font = library.options.font;
		TextSize = library.options.fontsize;
		TextStrokeTransparency = library.options.textstroke;
		TextStrokeColor3 = library.options.strokecolor;
		Parent = dropdown;
	});
	local button = check.dropdown_lbl.drop;
	local input;
	button.MouseButton1Click:Connect(function()
		if (input and input.Connected) then
			return;
		end;
		check.dropdown_lbl.Selection.TextColor3 = Color3.fromRGB(160, 160, 160);
		check.dropdown_lbl.Selection.Text = name;
		local c = 0;
		for _, v in next, list do
			c = c + 22;
		end;
		local size = UDim2.new(1, 0, 0, c);
		local clampedSize;
		local scrollSize = 0;
		if size.Y.Offset > 140 then
			clampedSize = UDim2.new(1, 0, 0, 140);
			scrollSize = 4;
		end;
		local goSize = (clampedSize ~= nil and clampedSize) or size;
		local container = library:Create("ScrollingFrame", {
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
			Name = "DropContainer";
			Parent = check.dropdown_lbl;
			Size = UDim2.new(1, 0, 0, 0);
			BackgroundColor3 = library.options.bgcolor;
			BorderColor3 = library.options.bordercolor;
			BorderSizePixel = 1;
			Position = UDim2.new(0, 0, 1, 4);
			ScrollBarThickness = scrollSize;
			CanvasSize = UDim2.new(0, 0, 0, size.Y.Offset);
			ZIndex = 5;
			ClipsDescendants = true;
			Parent = check.dropdown_lbl;
		});
		library:Create("UIListLayout", {
			Name = "List";
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = container;
		});
		for i, v in next, list do
			local btn = library:Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 22);
				BackgroundColor3 = library.options.btncolor;
				BorderColor3 = library.options.bordercolor;
				BorderSizePixel = 1;
				Text = v;
				Font = library.options.font;
				TextSize = library.options.fontsize;
				LayoutOrder = i;
				Parent = container;
				ZIndex = 5;
				TextColor3 = library.options.textcolor;
				TextStrokeTransparency = library.options.textstroke;
				TextStrokeColor3 = library.options.strokecolor;
			});
			btn.MouseButton1Click:Connect(function()
				check.dropdown_lbl.Selection.TextColor3 = library.options.textcolor;
				check.dropdown_lbl.Selection.Text = btn.Text;
				location[flag] = tostring(btn.Text);
				callback(location[flag]);
				game:GetService("Debris"):AddItem(container, 0);
				input:Disconnect();
			end);
		end;
		container:TweenSize(goSize, "Out", "Quad", 0.18, true);
		local function isInGui(frame)
			local mloc = game:GetService("UserInputService"):GetMouseLocation();
			local mouse = Vector2.new(mloc.X, mloc.Y - 36);
			local x1, x2 = frame.AbsolutePosition.X, frame.AbsolutePosition.X + frame.AbsoluteSize.X;
			local y1, y2 = frame.AbsolutePosition.Y, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y;
			return (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2);
		end;
		input = game:GetService("UserInputService").InputBegan:Connect(function(a)
			if a.UserInputType == Enum.UserInputType.MouseButton1 and (not isInGui(container)) then
				check.dropdown_lbl.Selection.TextColor3 = library.options.textcolor;
				check.dropdown_lbl.Selection.Text = location[flag];
				container:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.18, true);
				task.wait(0.18);
				game:GetService("Debris"):AddItem(container, 0);
				input:Disconnect();
			end;
		end);
	end);
	self:Resize();
	local function reload(array)
		list = array;
		location[flag] = array[1];
		pcall(function()
			input:Disconnect();
		end);
		check.dropdown_lbl.Selection.Text = location[flag];
		check.dropdown_lbl.Selection.TextColor3 = library.options.textcolor;
		game:GetService("Debris"):AddItem(container, 0);
	end;
	return {
		Refresh = reload;
	};
end;

function library:Create(class, data)
	local obj = Instance.new(class);
	for i, v in next, data do
		if i ~= "Parent" then
			if typeof(v) == "Instance" then
				v.Parent = obj;
			else
				obj[i] = v;
			end;
		end;
	end;
	if class == "Frame" or class == "TextButton" or class == "TextLabel" or class == "ScrollingFrame" or class == "TextBox" then
		local corner = Instance.new("UICorner");
		corner.CornerRadius = UDim.new(0, 6);
		corner.Parent = obj;
	end;
	obj.Parent = data.Parent;
	return obj;
end;

function library:CreateWindow(name, options)
	if (not library.container) then
		library.container = self:Create("ScreenGui", {
			self:Create("Frame", {
				Name = "Container";
				Size = UDim2.new(1, -40, 1, 0);
				Position = UDim2.new(0, 20, 0, 20);
				BackgroundTransparency = 1;
				Active = false;
			});
			Parent = game:GetService("CoreGui");
		}):FindFirstChild("Container");
	end;
	if (not library.options) then
		library.options = setmetatable(options or {}, {__index = defaults});
	end;
	local window = types:window(name, library.options);
	dragger.new(window.object);
	return window;
end;

local function isreallypressed(bind, inp)
	local key = bind;
	if typeof(key) == "Instance" then
		if key.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key.KeyCode then
			return true;
		elseif tostring(key.UserInputType):find("MouseButton") and inp.UserInputType == key.UserInputType then
			return true;
		end;
	end;
	if tostring(key):find("MouseButton") then
		return key == inp.UserInputType;
	else
		return key == inp.KeyCode;
	end;
end;

game:GetService("UserInputService").InputBegan:Connect(function(input)
	if (not library.binding) then
		for idx, binds in next, library.binds do
			local real_binding = binds.location[idx];
			if real_binding and isreallypressed(real_binding, input) then
				binds.callback(input, true);
			end;
		end;
	end;
end);

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if (not library.binding) then
		for idx, binds in next, library.binds do
			local real_binding = binds.location[idx];
			if real_binding and isreallypressed(real_binding, input) then
				binds.callback(input, false);
			end;
		end;
	end;
end);

return library;
