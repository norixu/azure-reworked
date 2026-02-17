local EternalUI = {}
EternalUI.__index = EternalUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

EternalUI.Theme = {
    Background = Color3.fromRGB(15,15,15),
    Secondary = Color3.fromRGB(25,25,25),
    Element = Color3.fromRGB(35,35,35),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(180,180,180),
    Accent = Color3.fromRGB(255,255,255),
    Outline = Color3.fromRGB(60,60,60)
}

local function Tween(obj, time, props)
    TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart
    local startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function EternalUI:CreateWindow(config)
    config = config or {}
    local Window = {}
    Window.Tabs = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EternalUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = config.Size or UDim2.fromOffset(600,400)
    Main.Position = UDim2.fromScale(.5,.5)
    Main.AnchorPoint = Vector2.new(.5,.5)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main
    MakeDraggable(Main)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,30)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Eternal UI"
    Title.TextColor3 = self.Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Main

    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0,120,1,-30)
    TabHolder.Position = UDim2.fromOffset(0,30)
    TabHolder.BackgroundColor3 = self.Theme.Secondary
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Main
    local TabHolderCorner = Instance.new("UICorner")
    TabHolderCorner.CornerRadius = UDim.new(0, 8)
    TabHolderCorner.Parent = TabHolder
    local TabHolderPadding = Instance.new("UIPadding")
    TabHolderPadding.PaddingTop = UDim.new(0, 5)
    TabHolderPadding.PaddingBottom = UDim.new(0, 5)
    TabHolderPadding.PaddingLeft = UDim.new(0, 5)
    TabHolderPadding.PaddingRight = UDim.new(0, 5)
    TabHolderPadding.Parent = TabHolder
    local TabHolderLayout = Instance.new("UIListLayout")
    TabHolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabHolderLayout.Parent = TabHolder

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,-120,1,-30)
    Container.Position = UDim2.fromOffset(120,30)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    function Window:Notify(text)
        local Notif = Instance.new("TextLabel")
        Notif.Size = UDim2.fromOffset(200,30)
        Notif.Position = UDim2.new(1,-210,1,-40)
        Notif.BackgroundColor3 = EternalUI.Theme.Element
        Notif.TextColor3 = EternalUI.Theme.Text
        Notif.Text = text
        Notif.BorderSizePixel = 0
        Notif.Parent = ScreenGui
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = Notif
        Tween(Notif,.3,{Position = UDim2.new(1,-210,1,-80)})
        task.wait(3)
        Tween(Notif,.3,{Position = UDim2.new(1,-210,1,-40)})
        task.wait(.3)
        Notif:Destroy()
    end

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Sections = {}

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1,-10,0,30)
        Button.BackgroundColor3 = EternalUI.Theme.Element
        Button.TextColor3 = EternalUI.Theme.Text
        Button.Text = name
        Button.BorderSizePixel = 0
        Button.Parent = TabHolder
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.Parent = Container
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 5)
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)
        PagePadding.Parent = Page
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent = Page

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Container:GetChildren()) do
                v.Visible = false
            end
            Page.Visible = true
        end)

        function Tab:CreateSection(name)
            local Section = {}

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1,0,0,0)
            SectionFrame.BackgroundColor3 = EternalUI.Theme.Secondary
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = Page
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = SectionFrame
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingTop = UDim.new(0, 5)
            SectionPadding.PaddingBottom = UDim.new(0, 5)
            SectionPadding.PaddingLeft = UDim.new(0, 5)
            SectionPadding.PaddingRight = UDim.new(0, 5)
            SectionPadding.Parent = SectionFrame
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 5)
            SectionLayout.Parent = SectionFrame

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1,0,0,20)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = name
            SectionTitle.TextColor3 = EternalUI.Theme.SubText
            SectionTitle.Font = Enum.Font.GothamSemibold
            SectionTitle.TextSize = 12
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame

            function Section:CreateButton(text, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,0,0,30)
                Btn.BackgroundColor3 = EternalUI.Theme.Element
                Btn.Text = text
                Btn.TextColor3 = EternalUI.Theme.Text
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Btn.BorderSizePixel = 0
                Btn.Parent = SectionFrame
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn
                Btn.MouseButton1Click:Connect(callback)
            end

            function Section:CreateToggle(text, callback)
                local State = false
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,0,0,30)
                Btn.BackgroundColor3 = EternalUI.Theme.Element
                Btn.Text = text.." : OFF"
                Btn.TextColor3 = EternalUI.Theme.Text
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Btn.BorderSizePixel = 0
                Btn.Parent = SectionFrame
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn
                Btn.MouseButton1Click:Connect(function()
                    State = not State
                    Btn.Text = text.." : "..(State and "ON" or "OFF")
                    callback(State)
                end)
            end

            function Section:CreateTextbox(text, callback)
                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1,0,0,30)
                Box.BackgroundColor3 = EternalUI.Theme.Element
                Box.PlaceholderText = text
                Box.TextColor3 = EternalUI.Theme.Text
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 14
                Box.BorderSizePixel = 0
                Box.Parent = SectionFrame
                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 6)
                BoxCorner.Parent = Box
                Box.FocusLost:Connect(function()
                    callback(Box.Text)
                end)
            end

            function Section:CreateSlider(text,min,max,callback)
                local Value = min
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1,0,0,50)
                SliderFrame.BackgroundColor3 = EternalUI.Theme.Element
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SectionFrame
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = SliderFrame

                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Size = UDim2.new(1,0,0,20)
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Text = text.." : "..Value
                SliderTitle.TextColor3 = EternalUI.Theme.Text
                SliderTitle.Font = Enum.Font.Gotham
                SliderTitle.TextSize = 14
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.Size = UDim2.new(1,-10,0,5)
                SliderBar.Position = UDim2.new(0,5,1,-15)
                SliderBar.BackgroundColor3 = EternalUI.Theme.Secondary
                SliderBar.BorderSizePixel = 0
                SliderBar.Parent = SliderFrame
                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new(0,0,1,0)
                SliderFill.BackgroundColor3 = EternalUI.Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBar
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill

                local dragging = false
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Value = math.floor(min + relativeX * (max - min))
                        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                        SliderTitle.Text = text.." : "..Value
                        callback(Value)
                    end
                end)
                local relativeX = (Value - min) / (max - min)
                SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            end

            function Section:CreateKeybind(text,key,callback)
                UIS.InputBegan:Connect(function(input)
                    if input.KeyCode == key then
                        callback()
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return EternalUI
