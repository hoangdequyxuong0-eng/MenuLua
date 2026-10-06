local Players = game:GetService("Players")

local function ShowFatal(message)
	local gui = Instance.new("ScreenGui")
	gui.Name = "SieuToc_Error"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	local getters = {
		function() return Players.LocalPlayer:WaitForChild("PlayerGui", 5) end,
		function() return gethui() end,
		function() return game:GetService("CoreGui") end
	}
	for _, getter in ipairs(getters) do
		local ok = pcall(function() gui.Parent = getter() end)
		if ok and gui.Parent then break end
	end
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 8)
	label.Size = UDim2.new(0.9, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundColor3 = Color3.fromRGB(30, 12, 16)
	label.TextColor3 = Color3.fromRGB(255, 130, 130)
	label.TextWrapped = true
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.Text = message
	label.Parent = gui
	task.delay(8, function() gui:Destroy() end)
end

local bootOk, bootErr = pcall(function()
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Lighting = game:GetService("Lighting")
	local Workspace = game:GetService("Workspace")
	local Stats = game:GetService("Stats")
	local TweenService = game:GetService("TweenService")
	local VirtualInputManager = game:GetService("VirtualInputManager")
	local LocalPlayer = Players.LocalPlayer
	local GuiParent = LocalPlayer:WaitForChild("PlayerGui")

	local realInput = {
		TouchEnabled = UserInputService.TouchEnabled,
		KeyboardEnabled = UserInputService.KeyboardEnabled,
		MouseEnabled = UserInputService.MouseEnabled
	}
	local isTouchOnly = realInput.TouchEnabled and not realInput.KeyboardEnabled

	local Theme = {
		Bg = Color3.fromRGB(13, 15, 23),
		Panel = Color3.fromRGB(19, 22, 33),
		Card = Color3.fromRGB(27, 31, 45),
		CardHover = Color3.fromRGB(38, 43, 62),
		Accent = Color3.fromRGB(124, 92, 255),
		AccentSoft = Color3.fromRGB(64, 48, 140),
		Cyan = Color3.fromRGB(56, 189, 248),
		Text = Color3.fromRGB(240, 242, 250),
		Sub = Color3.fromRGB(148, 157, 182),
		On = Color3.fromRGB(52, 211, 153),
		Off = Color3.fromRGB(62, 68, 92),
		Red = Color3.fromRGB(248, 113, 113),
		Gold = Color3.fromRGB(251, 191, 36),
		Blue = Color3.fromRGB(96, 165, 250)
	}

	local Perf = { espInterval = 0.12, saver = false }
	local Motion = { speed = 17, speedLock = true, jump = 50, jumpLock = false }

	local Lang = { code = "vi" }
	local Dict = {
		["Kéo thanh này để di chuyển  •  RightShift ẩn/hiện"] = { en = "Drag this bar to move  •  RightShift to show/hide", ko = "이 바를 끌어 이동  •  RightShift로 숨김/표시" },
		["Di Chuyển"] = { en = "Movement", ko = "이동" },
		["Năng Lực"] = { en = "Abilities", ko = "능력" },
		["Chiến Đấu"] = { en = "Combat", ko = "전투" },
		["Hình Ảnh"] = { en = "Visuals", ko = "시각" },
		["Người Chơi"] = { en = "Players", ko = "플레이어" },
		["Hệ Thống"] = { en = "System", ko = "시스템" },
		["Máy tính"] = { en = "Calculator", ko = "계산기" },
		["Aimbot"] = { en = "Aimbot", ko = "에임봇" },
		["Ghim"] = { en = "Pin", ko = "고정" },
		["Lỗi"] = { en = "Error", ko = "오류" },
		["Ngôn ngữ"] = { en = "Language", ko = "언어" },
		["Tốc độ chạy"] = { en = "Run speed", ko = "달리기 속도" },
		["Tốc độ"] = { en = "Speed", ko = "속도" },
		["Siêu tốc (100)"] = { en = "Super speed (100)", ko = "초고속 (100)" },
		["Về tốc độ mặc định (16)"] = { en = "Reset speed (16)", ko = "기본 속도로 (16)" },
		["Kích thước cơ thể"] = { en = "Body size", ko = "몸 크기" },
		["Tỷ lệ kích thước"] = { en = "Size scale", ko = "크기 배율" },
		["Về kích thước gốc"] = { en = "Reset size", ko = "원래 크기로" },
		["Chống khống chế"] = { en = "Anti crowd control", ko = "제어 방지" },
		["Chống stun / đóng băng"] = { en = "Anti stun / freeze", ko = "기절·빙결 방지" },
		["Tự gỡ trạng thái khống chế"] = { en = "Auto remove control effects", ko = "제어 상태 자동 해제" },
		["Điểm dịch chuyển"] = { en = "Teleport points", ko = "순간이동 지점" },
		["Lưu vị trí"] = { en = "Save point", ko = "위치 저장" },
		["Đến vị trí"] = { en = "Go to point", ko = "위치로 이동" },
		["Sức nhảy"] = { en = "Jump power", ko = "점프력" },
		["Lực nhảy"] = { en = "Jump force", ko = "점프 힘" },
		["Nhảy cao (200)"] = { en = "High jump (200)", ko = "높이 점프 (200)" },
		["Về lực nhảy mặc định"] = { en = "Reset jump force", ko = "기본 점프력으로" },
		["Nhảy vô hạn trên không"] = { en = "Infinite air jump", ko = "공중 무한 점프" },
		["Xuyên tường & tàng hình"] = { en = "Noclip & invisibility", ko = "벽 통과 및 투명화" },
		["Xuyên tường (Noclip)"] = { en = "Noclip", ko = "벽 통과 (Noclip)" },
		["Tàng hình"] = { en = "Invisible", ko = "투명화" },
		["Bấm để ẩn / hiện"] = { en = "Tap to hide / show", ko = "눌러서 숨김/표시" },
		["Sàn đất ảo"] = { en = "Virtual platform", ko = "가상 바닥" },
		["Tạo đất đứng ảo"] = { en = "Create virtual ground", ko = "가상 땅 만들기" },
		["Đất ảo bám chân (đi theo)"] = { en = "Ground follows your feet", ko = "발밑 땅 따라가기" },
		["Nâng đất +5m"] = { en = "Raise ground +5m", ko = "땅 올리기 +5m" },
		["Hạ đất -5m"] = { en = "Lower ground -5m", ko = "땅 내리기 -5m" },
		["Dịch chuyển theo trục Y"] = { en = "Teleport on Y axis", ko = "Y축 이동" },
		["Teleport lên trời"] = { en = "Teleport to sky", ko = "하늘로 순간이동" },
		["Nhảy xuống đất"] = { en = "Drop to ground", ko = "땅으로 내려가기" },
		["Bật Aimbot"] = { en = "Enable Aimbot", ko = "에임봇 켜기" },
		["Giữ chuột phải để ghim (điện thoại: tự động)"] = { en = "Hold right mouse to lock (mobile: auto)", ko = "우클릭 유지로 고정 (모바일: 자동)" },
		["Aim cả đồng đội"] = { en = "Aim at teammates too", ko = "팀원도 조준" },
		["Tắt = chỉ nhắm kẻ địch"] = { en = "Off = enemies only", ko = "끄면 적만 조준" },
		["Kiểm tra vật cản (Wallcheck)"] = { en = "Wall check", ko = "장애물 확인 (Wallcheck)" },
		["Khóa dính mục tiêu"] = { en = "Sticky target lock", ko = "타깃 고정" },
		["Không đổi mục tiêu khi đang ghim"] = { en = "Keep target while locked", ko = "고정 중 타깃 변경 안 함" },
		["Mục tiêu"] = { en = "Target", ko = "목표" },
		["Đầu"] = { en = "Head", ko = "머리" },
		["Thân"] = { en = "Body", ko = "몸통" },
		["Bán kính FOV"] = { en = "FOV radius", ko = "FOV 반경" },
		["Độ bám Aim"] = { en = "Aim strength", ko = "에임 강도" },
		["Tự động bắn"] = { en = "Auto fire", ko = "자동 발사" },
		["Tự bắn khi ngắm trúng địch"] = { en = "Fire when aiming at an enemy", ko = "적 조준 시 자동 발사" },
		["Tốc độ bắn mỗi giây"] = { en = "Shots per second", ko = "초당 발사 수" },
		["Chiến thuật"] = { en = "Tactics", ko = "전술" },
		["TP tới kẻ yếu máu nhất"] = { en = "Teleport to lowest HP enemy", ko = "체력 최저 적에게 이동" },
		["Tự động bấm"] = { en = "Auto click", ko = "자동 클릭" },
		["Tự bấm vào màn hình"] = { en = "Auto tap screen", ko = "화면 자동 터치" },
		["Số lần bấm mỗi giây"] = { en = "Clicks per second", ko = "초당 클릭 수" },
		["ESP người chơi"] = { en = "Player ESP", ko = "플레이어 ESP" },
		["Bật ESP"] = { en = "Enable ESP", ko = "ESP 켜기" },
		["Quét máy chủ một lần, sau đó tự theo dõi"] = { en = "Scans the server once, then tracks automatically", ko = "서버를 한 번 스캔한 후 자동 추적" },
		["Hiện đồng đội (xanh lá)"] = { en = "Show teammates (green)", ko = "팀원 표시 (초록)" },
		["Hiện kẻ địch (đỏ)"] = { en = "Show enemies (red)", ko = "적 표시 (빨강)" },
		["Hiện khung hộp"] = { en = "Show boxes", ko = "박스 표시" },
		["Hiện tên, máu, khoảng cách"] = { en = "Show name, HP, distance", ko = "이름, 체력, 거리 표시" },
		["Khoảng cách tối đa"] = { en = "Max distance", ko = "최대 거리" },
		["Xanh lá: đồng đội    Đỏ: kẻ địch    Vàng: địch sắp chết    Trắng: không rõ team"] = { en = "Green: teammate    Red: enemy    Yellow: almost dead    White: unknown team", ko = "초록: 팀원    빨강: 적    노랑: 죽어가는 적    흰색: 팀 불명" },
		["Chiếu sáng"] = { en = "Lighting", ko = "조명" },
		["Nhìn trong bóng tối (Fullbright)"] = { en = "Night vision (Fullbright)", ko = "어둠 속 시야 (Fullbright)" },
		["Điều khiển bám chân"] = { en = "Follow control", ko = "따라가기 제어" },
		["Bám chân người đã chọn"] = { en = "Follow selected players", ko = "선택한 플레이어 따라가기" },
		["Lần lượt từ trên xuống dưới"] = { en = "One by one, top to bottom", ko = "위에서 아래로 차례대로" },
		["Trạng thái: Đang tắt"] = { en = "Status: Off", ko = "상태: 꺼짐" },
		["Thời gian bám mỗi người"] = { en = "Follow time per player", ko = "플레이어당 따라가기 시간" },
		["Hitbox"] = { en = "Hitbox", ko = "히트박스" },
		["Tăng hitbox"] = { en = "Expand hitbox", ko = "히트박스 확장" },
		["Tự làm mới mỗi giây cho mọi người trong máy chủ"] = { en = "Auto refresh every second for everyone in the server", ko = "서버 내 모든 플레이어에게 1초마다 자동 갱신" },
		["Nhìn thấy hitbox"] = { en = "Show hitbox", ko = "히트박스 표시" },
		["Hitbox cả đồng đội"] = { en = "Hitbox for teammates too", ko = "팀원도 히트박스 적용" },
		["Tắt = chỉ kẻ địch"] = { en = "Off = enemies only", ko = "끄면 적만 적용" },
		["Kích thước hitbox"] = { en = "Hitbox size", ko = "히트박스 크기" },
		["Người ngã"] = { en = "Fallen players", ko = "쓰러진 플레이어" },
		["Ẩn người ngã và xác chết"] = { en = "Hide fallen players and corpses", ko = "쓰러진 플레이어와 시체 숨기기" },
		["Gồm cả xác chết, hồi sinh sẽ hiện lại"] = { en = "Includes dead bodies, shown again on standing up or respawn", ko = "시체 포함, 일어서거나 부활하면 다시 표시됨" },
		["Góc nghiêng coi là ngã"] = { en = "Tilt angle counted as fallen", ko = "쓰러짐으로 보는 기울기" },
		["Khoảng cách ra sau lưng"] = { en = "Distance behind", ko = "뒤쪽 거리" },
		["Độ cao bám"] = { en = "Follow height", ko = "따라가기 높이" },
		["Xóa tất cả người đã chọn"] = { en = "Clear all selected", ko = "선택 모두 지우기" },
		["Đã chọn (bám lần lượt)"] = { en = "Selected (follow in order)", ko = "선택됨 (순서대로 따라가기)" },
		["Chưa chọn ai. Bấm vào người chơi bên dưới để chọn."] = { en = "None selected. Tap a player below to select.", ko = "선택된 사람이 없습니다. 아래 플레이어를 눌러 선택하세요." },
		["Người chơi trong máy chủ"] = { en = "Players in server", ko = "서버 내 플레이어" },
		["Người mới vào: 0"] = { en = "New players: 0", ko = "신규 입장: 0" },
		["Người mới vào: %d  •  đặt lại sau %ds"] = { en = "New players: %d  •  resets in %ds", ko = "신규 입장: %d  •  %d초 후 초기화" },
		["Làm mới danh sách"] = { en = "Refresh list", ko = "목록 새로고침" },
		["Chưa có người chơi khác trong máy chủ"] = { en = "No other players in the server", ko = "서버에 다른 플레이어가 없습니다" },
		["Còn sống"] = { en = "Alive", ko = "생존" },
		["Đã chết"] = { en = "Dead", ko = "사망" },
		["Đang bám"] = { en = "Following", ko = "따라가는 중" },
		["Đang bám: %s\n@%s  •  #%d / %d"] = { en = "Following: %s\n@%s  •  #%d / %d", ko = "따라가는 중: %s\n@%s  •  #%d / %d" },
		["Chưa chọn người nào để bám"] = { en = "No player selected to follow", ko = "따라갈 플레이어를 선택하지 않았습니다" },
		["Đang chờ người được chọn hồi sinh"] = { en = "Waiting for the selected player to respawn", ko = "선택한 플레이어 부활 대기 중" },
		["Mới"] = { en = "New", ko = "신규" },
		["Máu"] = { en = "HP", ko = "체력" },
		["Mát máy & tiết kiệm pin"] = { en = "Cooling & battery saver", ko = "발열 감소 및 절전" },
		["Chế độ mát máy & tiết kiệm pin"] = { en = "Cooling & battery saver mode", ko = "발열 감소·절전 모드" },
		["Giảm đồ họa, tắt hiệu ứng, hạ FPS"] = { en = "Lower graphics, disable effects, cap FPS", ko = "그래픽 낮춤, 효과 끄기, FPS 제한" },
		["Giới hạn FPS khi tiết kiệm"] = { en = "FPS limit in saver mode", ko = "절전 시 FPS 제한" },
		["Chất lượng đồ họa"] = { en = "Graphics quality", ko = "그래픽 품질" },
		["Preset hiện tại: Thường"] = { en = "Current preset: Normal", ko = "현재 프리셋: 보통" },
		["Preset hiện tại: "] = { en = "Current preset: ", ko = "현재 프리셋: " },
		["Mượt (FPS Boost)"] = { en = "Smooth (FPS Boost)", ko = "부드럽게 (FPS 부스트)" },
		["Đẹp"] = { en = "Beautiful", ko = "고화질" },
		["Ultra High"] = { en = "Ultra High", ko = "울트라 하이" },
		["Góc nhìn"] = { en = "View", ko = "시야" },
		["Góc nhìn FOV"] = { en = "Field of view (FOV)", ko = "시야각 (FOV)" },
		["Thông tin hiển thị"] = { en = "Display info", ko = "표시 정보" },
		["Hiện bảng Ping & FPS"] = { en = "Show Ping & FPS panel", ko = "Ping·FPS 표시" },
		["Hiện số người online"] = { en = "Show online count", ko = "접속자 수 표시" },
		["%d / %d Online"] = { en = "%d / %d Online", ko = "접속 %d / %d" },
		["Đồng Hồ"] = { en = "Clock", ko = "시계" },
		["Đồng hồ"] = { en = "Clock", ko = "시계" },
		["Báo thức"] = { en = "Alarm", ko = "알람" },
		["Bộ đếm"] = { en = "Timer", ko = "타이머" },
		["Bấm giờ"] = { en = "Stopwatch", ko = "스톱워치" },
		["Sức khỏe"] = { en = "Health", ko = "건강" },
		["Thời gian online"] = { en = "Online time", ko = "접속 시간" },
		["Tạm nghỉ sau: %s"] = { en = "Break in: %s", ko = "휴식까지: %s" },
		["Đang tạm nghỉ: còn %s"] = { en = "On break: %s left", ko = "휴식 중: %s 남음" },
		["Chăm sóc sức khỏe"] = { en = "Health care", ko = "건강 관리" },
		["Luôn bật  •  Không thể tắt"] = { en = "Always on  •  Cannot be turned off", ko = "항상 켜짐  •  끌 수 없음" },
		["Uống nước mát"] = { en = "Cool water", ko = "시원한 물" },
		["Nhắc uống nước mỗi 30 phút"] = { en = "Water reminder every 30 minutes", ko = "30분마다 물 마시기 알림" },
		["Tạm nghỉ 30 phút"] = { en = "30-minute break", ko = "30분 휴식" },
		["Sau mỗi 2 giờ online sẽ bắt nghỉ 30 phút"] = { en = "A 30-minute break after every 2 hours online", ko = "접속 2시간마다 30분 휴식" },
		["Giờ ăn cơm"] = { en = "Meal times", ko = "식사 시간" },
		["Sáng"] = { en = "Morning", ko = "아침" },
		["Trưa"] = { en = "Noon", ko = "점심" },
		["Tối"] = { en = "Evening", ko = "저녁" },
		["Các nhắc nhở sẽ che toàn màn hình cho đến khi bạn bấm xác nhận."] = { en = "Reminders cover the whole screen until you confirm.", ko = "알림은 확인을 누를 때까지 전체 화면을 덮습니다." },
		["Đến giờ uống nước mát"] = { en = "Time to drink cool water", ko = "시원한 물을 마실 시간입니다" },
		["Hãy đứng dậy uống một cốc nước mát để giữ cơ thể khỏe mạnh. Uống xong hãy bấm xác nhận."] = { en = "Stand up and drink a glass of cool water to stay healthy. Press confirm when you are done.", ko = "일어나서 시원한 물 한 잔을 마시고 건강을 지키세요. 다 마신 후 확인을 누르세요." },
		["Tôi đã uống nước xong"] = { en = "I have finished drinking", ko = "물을 다 마셨습니다" },
		["Đến giờ ăn cơm sáng"] = { en = "Time for breakfast", ko = "아침 식사 시간입니다" },
		["Đến giờ ăn cơm trưa"] = { en = "Time for lunch", ko = "점심 식사 시간입니다" },
		["Đến giờ ăn cơm tối"] = { en = "Time for dinner", ko = "저녁 식사 시간입니다" },
		["Hãy tạm dừng game và đi ăn cơm ngay. Ăn xong hãy bấm xác nhận."] = { en = "Pause the game and go eat now. Press confirm when you have finished.", ko = "게임을 잠시 멈추고 지금 식사하세요. 식사 후 확인을 누르세요." },
		["Tôi đã ăn cơm xong"] = { en = "I have finished eating", ko = "식사를 마쳤습니다" },
		["Đã đến lúc tạm nghỉ 30 phút"] = { en = "Time for a 30-minute break", ko = "30분간 휴식할 시간입니다" },
		["Bạn đã chơi liên tục 2 tiếng. Hãy rời màn hình, đi lại và cho mắt nghỉ ngơi."] = { en = "You have played for 2 hours straight. Step away from the screen, move around and rest your eyes.", ko = "2시간 연속으로 플레이했습니다. 화면에서 떨어져 움직이고 눈을 쉬게 하세요." },
		["Tiếp tục chơi"] = { en = "Continue playing", ko = "계속 플레이" },
		["Thời gian còn chờ"] = { en = "Time remaining", ko = "남은 시간" },
		["Giờ hiện tại"] = { en = "Current time", ko = "현재 시간" },
		["Xác nhận sau %ds"] = { en = "Confirm in %ds", ko = "%d초 후 확인 가능" },
		["Còn %s mới được chơi tiếp"] = { en = "%s left before you can play again", ko = "%s 후에 다시 플레이할 수 있습니다" },
		["Thêm báo thức"] = { en = "Add alarm", ko = "알람 추가" },
		["Giờ"] = { en = "Hour", ko = "시" },
		["Phút"] = { en = "Minute", ko = "분" },
		["Giây"] = { en = "Second", ko = "초" },
		["Lặp lại hàng ngày"] = { en = "Repeat daily", ko = "매일 반복" },
		["Danh sách báo thức"] = { en = "Alarm list", ko = "알람 목록" },
		["Chưa có báo thức nào"] = { en = "No alarms yet", ko = "알람이 없습니다" },
		["Hàng ngày"] = { en = "Daily", ko = "매일" },
		["Một lần"] = { en = "Once", ko = "한 번" },
		["Xóa"] = { en = "Delete", ko = "삭제" },
		["Tối đa 8 báo thức"] = { en = "Maximum 8 alarms", ko = "알람은 최대 8개" },
		["Tắt báo thức"] = { en = "Dismiss", ko = "알람 끄기" },
		["Báo lại 5 phút"] = { en = "Snooze 5 min", ko = "5분 후 다시" },
		["Bộ đếm giờ"] = { en = "Countdown timer", ko = "카운트다운 타이머" },
		["Sẵn sàng"] = { en = "Ready", ko = "준비" },
		["Đang chạy"] = { en = "Running", ko = "실행 중" },
		["Tạm dừng"] = { en = "Paused", ko = "일시정지" },
		["Bắt đầu"] = { en = "Start", ko = "시작" },
		["Tiếp tục"] = { en = "Resume", ko = "계속" },
		["Đặt lại"] = { en = "Reset", ko = "초기화" },
		["Cài nhanh"] = { en = "Quick set", ko = "빠른 설정" },
		["phút"] = { en = "min", ko = "분" },
		["Bộ đếm đã hết giờ"] = { en = "Timer finished", ko = "타이머 종료" },
		["Đóng"] = { en = "Close", ko = "닫기" },
		["Ghi vòng"] = { en = "Lap", ko = "랩" },
		["Vòng %d"] = { en = "Lap %d", ko = "랩 %d" },
		["Chưa có vòng nào"] = { en = "No laps yet", ko = "랩 기록 없음" },
		["Đang khởi động..."] = { en = "Starting...", ko = "시작하는 중..." },
		["Đang khởi động... %.1fs"] = { en = "Starting... %.1fs", ko = "시작하는 중... %.1fs" },
	}
	local LocReg = setmetatable({}, { __mode = "k" })
	local LocHooks = {}
	local function T(key)
		local entry = Dict[key]
		if entry and Lang.code ~= "vi" then
			return entry[Lang.code] or key
		end
		return key
	end
	local function Reg(obj, source)
		LocReg[obj] = source
		if type(source) == "function" then
			obj.Text = source()
		else
			obj.Text = T(source)
		end
	end
	local LocRev = nil
	local function BuildLocRev()
		LocRev = {}
		for key, entry in pairs(Dict) do
			LocRev[key] = key
			if entry.en and LocRev[entry.en] == nil then
				LocRev[entry.en] = key
			end
			if entry.ko and LocRev[entry.ko] == nil then
				LocRev[entry.ko] = key
			end
		end
	end
	local function LocSweepAll()
		if not LocRev then
			BuildLocRev()
		end
		for _, root in ipairs(GuiParent:GetChildren()) do
			if root:IsA("ScreenGui") and root.Name:sub(1, 8) == "SieuToc_" then
				for _, obj in ipairs(root:GetDescendants()) do
					if obj:IsA("TextBox") then
						local pkey = LocRev[obj.PlaceholderText]
						if pkey then
							obj.PlaceholderText = T(pkey)
						end
					elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and LocReg[obj] == nil then
						local key = LocRev[obj.Text]
						if key then
							local want = T(key)
							if obj.Text ~= want then
								obj.Text = want
							end
						end
					end
				end
			end
		end
	end
	local function ApplyLang()
		for obj, source in pairs(LocReg) do
			if obj.Parent then
				if type(source) == "function" then
					obj.Text = source()
				else
					obj.Text = T(source)
				end
			end
		end
		pcall(LocSweepAll)
		for _, hook in ipairs(LocHooks) do
			pcall(hook)
		end
	end

	local function New(class, props, parent)
		local obj = Instance.new(class)
		for key, val in pairs(props) do
			obj[key] = val
		end
		if parent then
			obj.Parent = parent
		end
		if (class == "TextLabel" or class == "TextButton") and type(props.Text) == "string" and Dict[props.Text] then
			LocReg[obj] = props.Text
			obj.Text = T(props.Text)
		end
		return obj
	end

	local function Corner(obj, radius)
		return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, obj)
	end

	local function Stroke(obj, color, thickness, transparency)
		return New("UIStroke", {
			Color = color or Theme.Accent,
			Thickness = thickness or 1,
			Transparency = transparency or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, obj)
	end

	local function Pad(obj, top, right, bottom, left)
		return New("UIPadding", {
			PaddingTop = UDim.new(0, top),
			PaddingRight = UDim.new(0, right),
			PaddingBottom = UDim.new(0, bottom),
			PaddingLeft = UDim.new(0, left)
		}, obj)
	end

	local function Tween(obj, duration, props, style, direction)
		local tween = TweenService:Create(
			obj,
			TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
			props
		)
		tween:Play()
		return tween
	end

	local orderCounter = 0
	local function Next()
		orderCounter = orderCounter + 1
		return orderCounter
	end

	local function GetRoot(char)
		return char and char:FindFirstChild("HumanoidRootPart")
	end

	local function GetHumanoid()
		local char = LocalPlayer.Character
		return char and char:FindFirstChildOfClass("Humanoid")
	end

	local function GetRelation(p)
		local myTeam, theirTeam = LocalPlayer.Team, p.Team
		if myTeam and theirTeam then
			return myTeam == theirTeam and "ally" or "enemy"
		end
		if myTeam or theirTeam then
			return "neutral"
		end
		local white = BrickColor.new("White")
		if LocalPlayer.TeamColor ~= white or p.TeamColor ~= white then
			return LocalPlayer.TeamColor == p.TeamColor and "ally" or "enemy"
		end
		return "enemy"
	end

	local function IsEnemy(p)
		return p ~= LocalPlayer and GetRelation(p) == "enemy"
	end

	local function IsAlive(p)
		if not p or not p.Parent then
			return false
		end
		local char = p.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		return hum ~= nil and hum.Health > 0 and GetRoot(char) ~= nil
	end

	local function DistanceTo(p)
		local myRoot = GetRoot(LocalPlayer.Character)
		local root = p.Character and GetRoot(p.Character)
		if myRoot and root then
			return (myRoot.Position - root.Position).Magnitude
		end
		return math.huge
	end

	local Fallen = { set = {}, onChange = nil }

	local function PerformClick(x, y)
		if isTouchOnly then
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then
				pcall(function() tool:Activate() end)
			end
			return
		end
		pcall(function()
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end)
	end

	local function MakeDraggable(handle, target)
		local dragging = false
		local moved = false
		local dragInput, dragStart, startPos
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = target.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		handle.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				if delta.Magnitude > 10 then
					moved = true
				end
				target.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
		return {
			IsDragging = function() return dragging or moved end
		}
	end

	local MainGui = New("ScreenGui", {
		Name = "SieuToc_Main",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, GuiParent)
	local FloatGui = New("ScreenGui", {
		Name = "SieuToc_Float",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = 20,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, GuiParent)
	local OverlayGui = New("ScreenGui", {
		Name = "SieuToc_Overlay",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, GuiParent)

	local floatCount = 0
	local function CreateFloat(text, onPress)
		local col = math.floor(floatCount / 6)
		local row = floatCount % 6
		floatCount = floatCount + 1
		local btn = New("TextButton", {
			Size = UDim2.fromOffset(112, 32),
			Position = UDim2.new(0, 16 + col * 120, 0, 96 + row * 38),
			BackgroundColor3 = Theme.CardHover,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextWrapped = true
		}, FloatGui)
		Reg(btn, text)
		Corner(btn, 10)
		Stroke(btn, Theme.Accent, 1.2, 0.4)
		local drag = MakeDraggable(btn, btn)
		btn.MouseButton1Click:Connect(function()
			if not drag.IsDragging() then
				onPress()
			end
		end)
		return btn
	end

	local ICON_PARTS = {
"/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAkGBwgHBgkIBwgKCgkLDRYPDQwMDRsUFRAWIB0iIiAdHx8kKDQsJCYxJx8fLT0tMTU3Ojo6Iys/RD84QzQ5Ojf/",
"2wBDAQoKCg0MDRoPDxo3JR8lNzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzf/wAARCABwAHADASIAAhEBAxEB/8QA",
"HAAAAgMBAQEBAAAAAAAAAAAABgcDBAUBAggA/8QAPBAAAgECBAMGBAQFAwQDAAAAAQIDBBEABRIhBjFBEyJRYXGBFDKRoQcjUsFCYrHR4RUzghZDU6LC8PH/",
"xAAaAQADAQEBAQAAAAAAAAAAAAACAwQFAQYA/8QAKREAAgIBBAIBAwQDAAAAAAAAAAECAxEEEiExE0FhIlHBBSMycaHR4f/aAAwDAQACEQMRAD8ANPxS4i+B",
"y/8A02mb8+cDXboOg/f2HjhOxnTKrjocXc/zeTOs3q6121DWVSx28yPLoPIDFJkIsvgAMTzeWej0lPirS9kz061FdPKo7oCoo8R4/W+LMUINhbpiKjcqNXU3",
"/fGrT1UJNPeIHRq1D9QsAMKbL4JYO0dMCCLX30jGhlNPCK6ooashBEol0uPnRhvb0Oxxco6iCB6j4ZO6wAQEfLdf7jEmXUX+rZlLEjBZ2iZ42O5DKdwPUMds",
"cSAtm4xb6RRrZGRlAYl4V0qx/wC5H5+JH3GMdpBFNJHLTmeOYFY7HvRm3IeI8MXqyOeCVoZgVZCQAeYxXVUlAEmyX71uY9PPHMjdqceChQzmPTTSuGBJEb9V",
"I/hOLRnKyXGwYX0n7jFTiSgnoJmjnXS5UOlQo2lXmCcQw1BqIQ5sJF3IBvuOftyPvgmgIWJ8I1Ip3p50lidoyHDRuOcb/wCcObhbPIs6y6OS9p1FpU8G64Sc",
"qGak1xC7AX0/qHh6/uMafCOcVFPUE0jgzhdcak2EpUXKnw1Lf0IGCrltZJrtOrofK6Hnj9ijk+ZwZtQx1UBIvs6N8yN1B88XsVnmpJxeGfLqJ2aaQLC9yL8s",
"WdP5inocV5FEaqnK2lftiyp7gJ5gjEjPVw6we4j+QpH6cSwXEigAnnfy2xVp2vQXHT++CDKKI1CV8gXaKmL38NxgWHuxHd/REkzrYg2ON/geU/8AVFMzHZta",
"/VTjBEe6emNvhFGXiGmIuLOpv7HHI9hajDpkvhhhxhk1NWAVMekVSC7Rj5pF8hzuPvhe1lLJQ1Sh0YxSgFH02DDowv0w237OkYaEOqQ7Ku1z1LH9zhbcXcWU",
"lRHPRZTSRZh2b/mOraUjZrjuHmd9zb9ycMlDL4MjS6qVaUXyjVpKBOJOF2onutbRkimlsLr1UHy6H0wrG7SgzRqedAkhYq6jaxGxGCXLariWOGA5bMsdRVaQ",
"VCWLC5uNxtYg7+uCdeCTmGcwZrn5hZI4+0np6dSqOyjYEliT5+NscXPA+Vnibl6fKA7K5lFT2WoFWGtDfFad/gs0+Ih7pWQPb9S3vcYLeNsrmhhp80mgSORG",
"U/loFtETbSQP03Fj4E4FcxS4Em4MVmB9NrffHMYZXXYra9y9DJ4MzWNaWKsDadEq0tUvQo3+258we7fw9MMPCH4ar/hIKmA30VMQUD+ZXVh9O9h7RNqjRgbg",
"qDiit5Rh/qFWyefv/wAPmCoN5I28ZP8A44n1C6+Di3viOoA7FJx8omI+x/tjsik07W+ZDcYSbceMnaGzUskfUORb3wyOAaCKZK+WqC27NY7P8qXvv5nCzy6V",
"VmqSwNgdYsOnXBFTz8S1dDPmmRvJR5ezAsoA7Qi5Gq/QDy8euPkuSfUT/a2r3+GaFVRmCYJe9mI+ht/99cEHClNfMoWA+WQ3PouMqh4czEvHWVNXPJdTqiaV",
"iGOnnY9Sb4M8my9qJklNheMah/MSbn6WwCjyduvzS0+zXzGkjraSSmmLCORdL6TYleov54G4OFspy8v8LT6QWLBR/Dc8geYHTngtdQR3TcWxUkgJOGyRl02O",
"PsFa2khy2elnpYljAdUAHqTYexON/MNRyes0yNG3ZHS6gEqeh32xlcUxMsdLp5q7P7Af5x3inimm4XymgqJ4jK1XIqIoNtNluW9tvrgYrllN8t1cGY3HmYim",
"4WeOZb1NXGIEjK/7ZYm7eXdBIGAMntaCklffWQG87ixx6z3PKniKtq6/tHWE6I0gtYBQC1j4m9zf/wDMSZfT9tR0MLbhpjt4gEkjH0izSRcYNv2EWS8P1Fec",
"rSABZKiHt2Y8kUl1J+y/XDliQRRpGvJVCi/lhefhrUmszatGtXipKdIIGXloDNhi4dWljJka6yUpqL9fk+aMuWIyVeW1R0s8g0MeSMPH1Bt9MdpYyYiHHfHd",
"YfzDYg/TBC2Q0+f0ckuXlVzVlExiJt2qW0uo8wQCPXApSV708yx1JLxyCxcjvKw5E9eWxGFNcGzXYlNplExmDNVuuoW+U9QN7fTDU4F+EenZVi0kkOkZa4U9",
"duXgb4BKqh+OMc9E154m70Z5nBBkecQo8Cx1EcFdEB3ZNhIvgD18D1FsD2DbHYmvTGfElyARfGjEm2+M7JK6nzKnMsDIWRtEqo4bQ3gcawFhg4oyrZ84OPIk",
"Yu7BR5nHI5El3jOofqANj6HrjwtMikm7MxNyzG5OJuQwQl49GTnVL8RFOx3tF2SDzYgn7AYSH4g5y+cZvSUyluwy6njjW4tqdrFj/Qe2HXxHW9jTNTQECZ1P",
"LmgO1/Xc2wk+OaZaPP0KAlHgUk22BX/GB9llPMUmcyOG8JFtnck+gFv3xYqHkpqChCMVKyM3qQ1xf6Yu5NR9jw1LXSsF7KIuVPO1idvU7YiziO+VwSbbOFHh",
"sD/bC/ZsfTsSGl+GlNTx0NRU06qq1LBwAbne5I8rG4t5eeDTCS/D/iefJZDDLFJPRSuAezF3iY7XA6+nXDloquGtpxNTyLIh6r0P7Yoraawef11M42OT6Ymc",
"ujhyrOKjKc6Z6eON3CVSHS8LqLq6nwO3kb4w5eHaoS0KVX5T18DVFKWB3JvZW262/wDYYcPGHCEXEUaTwyCmrUGzstw48G/v/XANxhmc7ZZTUlfRTpnFDIGh",
"qqR1eEsLX5G67AG1uYxzbgqhqPJhrt9/7ATL5Xkk7NJWhqoxZHvY28D6YzcwkmlmdatFEqbGw039uXvixKlU1S1TMrKWYkPfcte+LNSY80RY3ZY6sd3URbUP",
"C+Axhlje+v5X+SlkmaZjk0gqssqnppgLNbdXHgw5HB9lv4wVFMqrnWVrMv8A5aV9JP8Axbb74Aa+B6WYAqoBAICrYW5ftiGaMS05XrbY4J8MldcbI5xyP/Ke",
"NskzOminSeSBZRdfiIyt/cXGLeZ8Q0VLTg0ssVVUSbRRROGufE25DCb/AA/rFMZyuaPUhZ2VjyDX5e+/0weUlBDTPrQHURtc8sceUTKqPstIrtqkncyTOdTu",
"ep/t0GBjiqlFQInXSS0zIwbqvL7WwUSMyKSiazbYagMBufU9QkSrPN+ZJIxKL8qJe/PmbkjAt46KqIqc8MpZnVK1J8PDfsdkAHUDcn7WxNxAgpuD8tR7LMrC",
"WU+GoEfvjhoDA8RqWYQvGGKrz2PIDxINsS1E7V0faToO8SSg5KALBR7DAfxwaGfNnb6M3IW7WTREyx1Ki1m3WRfA/scMzJM5WeALUu1DmEQCipO6TdAHt83h",
"fn6YD14VimaKShDWk70Wlgjr4b8j9sa0WTZ7CdDRRzOBuksDG4/msLHDHCUXwRyupujiTww34qzFo4/goGsXH5pB3seQ9/6euAXMqOSRIamgA1wsT2Z5OORH",
"0xs5nU9pmVTI5vepKg+XIfYDEaAIzRnx2xbt4MWuTg8oBuKHgkgiSFZUdnAKyIVKeV+R9sYE8a0+agE2CSi5Ph1wZ8SUjVtY0cQ1R0sLSlR1kO4A9hf3wIZ1",
"+ZmkrA2EjKwPkQMIsTzk1NNJOGz4Zzi6H4ephSNiUKEgar7YzY7sEXqTi7mIlMMSTXcX0xOdrxrccve+IqBNdQrW2Aa2Am8yGULbDvJu8L5aBWRHcK1OJTbn",
"fUbWwwqeTtIgT8w2PrgY4YhaH4aSZSO2hMaXHRTcfucFKi2wwMlhiHJM5KzKpKqWPQAYxJcvmnrY562RXFyHUL3QtthfG8QbXxdyqg+JqbThggTX4X32OOYy",
"fRscE2gczym7qmQaGS99Q8QP8YGaOXV2SuCoYd4HmNsH+d0c2bcRx0MRDbhpWtYBVAO/qdsBmd0rUOYysqkC7m3h5ffAzjlZLdDak9nt8h7wcqVHD1PEgVnL",
"Elz/AA6TY79Oh98EU3fbsYPnZu9IRv7e2FzwHmHw2YpRyyfkSSalBNgNSkX+oA9sM+nUdo8p3J5eQxRXLdEy9bV4rn9nyhfVaFpZI+TmVx/yDEYnfvqjrtqF",
"tx1x74giakzWrAvpaTtNuYBsSR74rUkwnSRFI1L31tyIPh7/ANcULojPSxIjqbbkkkn+InqcLni2i+Gzl413VlDDyGGXKUMRLMFBFwT0wFZw4rs3UU4WR3hK",
"LIRZRbckE9R++F2pYK9HJqbfwYOe1kdWYXhQIixhEFuR64iyiAvIiR/Oz6V9yMT51lz0KxFypDMdNhba2O5CVhr6ZpbhNYYkDlY/5xO2931GpBR8T2dDCy+k",
"V8rp4GUl42utuYYE41aKimq1Z4St030sbEnqPXE2SxtBM0pG4bXH5g8/vf64uw8Q5BmGcyUNDmEL16MRJCtwSQN7G1iRYg2PTyw6yOejHhbtk0/ZBR0DVE6q",
"yMIgbsSLbeGNfs9NRJKHMa6Qg0jc2xcXcYz82q1pKWaYo8hjQsVjF2sOdvPCUgnPJ7yChihepq0U652J1MbsVGwufqffA9xtkrVDS1sEZMKr+Zbq/j6W2J8c",
"DVF+KOYUXFFRSZvQwx5X2giVYQTJDsLG/wDFz3Fh5ebZhlhqqdZInWWGRbhhuGBw5w4wxUL5V2eRdiXyYwxTdlUWKA2JP6D19Rhs5QsyUyIJhURkXErm5I6b",
"j5voDhdcWZMMuzeV4SewMgYD9Ia2wxvcJ0tRFGs4jWoha4IMjIUYbEC2x9DhFeYy2mrrPHfSrYvHwf/Z"
}

	local function DecodeBase64(data)
		local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local lookup = {}
		for i = 1, 64 do
			lookup[chars:sub(i, i)] = i - 1
		end
		local out, buffer, bits = {}, 0, 0
		for i = 1, #data do
			local v = lookup[data:sub(i, i)]
			if v then
				buffer = buffer * 64 + v
				bits = bits + 6
				if bits >= 8 then
					bits = bits - 8
					local byte = math.floor(buffer / 2 ^ bits)
					buffer = buffer % 2 ^ bits
					out[#out + 1] = string.char(byte)
				end
			end
		end
		return table.concat(out)
	end

	local function LoadIconAsset()
		if not (writefile and getcustomasset) then
			return nil
		end
		local ok, asset = pcall(function()
			local path = "MenuSieuToc_icon.jpg"
			writefile(path, DecodeBase64(table.concat(ICON_PARTS)))
			return getcustomasset(path)
		end)
		if ok and asset and asset ~= "" then
			return asset
		end
		return nil
	end

	local iconAsset = LoadIconAsset()

	local viewport = Workspace.CurrentCamera.ViewportSize
	local winW = math.min(500, viewport.X - 16)
	local winH = math.min(340, viewport.Y - 28)
	local HEADER_H = 46
	local SIDE_W = 112

	local Window = New("CanvasGroup", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.5, -winH / 2),
		Size = UDim2.fromOffset(winW, winH),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		Visible = false
	}, MainGui)
	Corner(Window, 16)
	Stroke(Window, Theme.Accent, 1.5, 0.45)
	local winScale = New("UIScale", { Scale = 1 }, Window)

	local Header = New("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER_H),
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0
	}, Window)
	New("UIGradient", {
		Color = ColorSequence.new(Theme.Panel, Color3.fromRGB(34, 26, 70)),
		Rotation = 0
	}, Header)
	MakeDraggable(Header, Window)

	local Logo = New("Frame", {
		Position = UDim2.new(0, 8, 0.5, -17),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0
	}, Header)
	Corner(Logo, 17)
	Stroke(Logo, Theme.Cyan, 2, 0.2)
	if iconAsset then
		local logoImage = New("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = iconAsset,
			ScaleType = Enum.ScaleType.Crop
		}, Logo)
		Corner(logoImage, 17)
	else
		New("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Cyan), Rotation = 45 }, Logo)
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBlack,
			Text = "S",
			TextSize = 16,
			TextColor3 = Theme.Text
		}, Logo)
	end
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 6),
		Size = UDim2.new(1, -210, 0, 20),
		Font = Enum.Font.GothamBlack,
		Text = "SIÊU TỐC PRO",
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Header)
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 26),
		Size = UDim2.new(1, -210, 0, 14),
		Font = Enum.Font.GothamMedium,
		Text = "Kéo thanh này để di chuyển  •  RightShift ẩn/hiện",
		TextColor3 = Theme.Sub,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd
	}, Header)

	local function HeaderButton(text, offset)
		local btn = New("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, offset, 0.5, 0),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = Theme.CardHover,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = 16
		}, Header)
		Corner(btn, 9)
		btn.MouseEnter:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = Theme.Accent }) end)
		btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = Theme.CardHover }) end)
		return btn
	end
	local HideBtn = HeaderButton("X", -10)
	local MinBtn = HeaderButton("-", -46)
	local CalcBtn = HeaderButton("", -82)
	CalcBtn.Size = UDim2.fromOffset(66, 30)
	CalcBtn.TextSize = 10
	Reg(CalcBtn, "Máy tính")

	local Body = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, HEADER_H),
		Size = UDim2.new(1, 0, 1, -HEADER_H)
	}, Window)

	local Sidebar = New("Frame", {
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, SIDE_W, 1, 0)
	}, Body)
	local TabList = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0
	}, Sidebar)
	New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, TabList)
	Pad(TabList, 8, 8, 8, 8)

	local PageHolder = New("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, SIDE_W, 0, 0),
		Size = UDim2.new(1, -SIDE_W, 1, 0)
	}, Body)

	local pages = {}
	local tabButtons = {}

	local function SelectTab(name)
		for pageName, page in pairs(pages) do
			if pageName == name then
				if not page.Visible then
					page.Position = UDim2.new(0, 0, 0, 14)
					page.Visible = true
					Tween(page, 0.25, { Position = UDim2.new() }, Enum.EasingStyle.Back)
				end
			else
				page.Visible = false
			end
		end
		for tabName, tab in pairs(tabButtons) do
			local selected = tabName == name
			Tween(tab.btn, 0.18, { BackgroundTransparency = selected and 0.8 or 1 })
			Tween(tab.bar, 0.18, { BackgroundTransparency = selected and 0 or 1 })
			Tween(tab.label, 0.18, { TextColor3 = selected and Theme.Text or Theme.Sub })
		end
	end

	local function AddTab(name)
		local btn = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = Next()
		}, TabList)
		Corner(btn, 10)
		local bar = New("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 18),
			BackgroundColor3 = Theme.Cyan,
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		}, btn)
		Corner(bar, 2)
		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -16, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = name,
			TextSize = 11,
			TextColor3 = Theme.Sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		}, btn)
		local page = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			Visible = false
		}, PageHolder)
		New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
		Pad(page, 8, 10, 14, 8)
		pages[name] = page
		tabButtons[name] = { btn = btn, bar = bar, label = label }
		btn.MouseButton1Click:Connect(function()
			SelectTab(name)
		end)
		return page
	end

	local function Section(page, text)
		local row = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = Next()
		}, page)
		local sectionLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 2, 0, 4),
			Size = UDim2.new(1, -2, 1, -4),
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Cyan,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left
		}, row)
		Reg(sectionLabel, function() return "▍ " .. T(text) end)
		return row
	end

	local function Note(page, text, color)
		local card = New("Frame", {
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = Next()
		}, page)
		Corner(card, 10)
		Pad(card, 8, 10, 8, 10)
		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = color or Theme.Sub,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, card)
		Reg(label, text)
		return label, card
	end

	local function MakePin(card, build)
		local pin = New("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -7, 0.5, 0),
			Size = UDim2.fromOffset(44, 24),
			BackgroundColor3 = Theme.CardHover,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "Ghim",
			TextSize = 10,
			TextColor3 = Theme.Text
		}, card)
		Corner(pin, 8)
		local floatBtn = nil
		pin.MouseButton1Click:Connect(function()
			if floatBtn then
				floatBtn:Destroy()
				floatBtn = nil
				Tween(pin, 0.2, { BackgroundColor3 = Theme.CardHover })
			else
				floatBtn = build()
				Tween(pin, 0.2, { BackgroundColor3 = Theme.Accent })
			end
		end)
		return function() return floatBtn end
	end

	local function Toggle(page, text, default, callback, desc)
		local card = New("Frame", {
			Size = UDim2.new(1, 0, 0, desc and 50 or 40),
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0,
			LayoutOrder = Next()
		}, page)
		Corner(card, 10)
		local hit = New("TextButton", {
			Size = UDim2.new(1, -56, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false
		}, card)
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, desc and 8 or 0),
			Size = UDim2.new(1, -62, 0, desc and 18 or 40),
			Font = Enum.Font.GothamSemibold,
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, hit)
		if desc then
			New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 27),
				Size = UDim2.new(1, -62, 0, 16),
				Font = Enum.Font.GothamMedium,
				Text = desc,
				TextColor3 = Theme.Sub,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, hit)
		end
		local pill = New("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(38, 20),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0
		}, hit)
		Corner(pill, 10)
		local knob = New("Frame", {
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0
		}, pill)
		Corner(knob, 8)
		hit.MouseEnter:Connect(function() Tween(card, 0.12, { BackgroundColor3 = Theme.CardHover }) end)
		hit.MouseLeave:Connect(function() Tween(card, 0.15, { BackgroundColor3 = Theme.Card }) end)

		local state = false
		local getFloat = nil
		local function SetState(value, silent)
			state = value
			Tween(pill, 0.18, { BackgroundColor3 = value and Theme.On or Theme.Off })
			Tween(knob, 0.18, { Position = value and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
			local float = getFloat and getFloat()
			if float then
				Tween(float, 0.18, { BackgroundColor3 = value and Theme.On or Theme.CardHover })
			end
			if not silent then
				task.spawn(callback, value)
			end
		end
		hit.MouseButton1Click:Connect(function()
			SetState(not state)
		end)
		getFloat = MakePin(card, function()
			local float = CreateFloat(text, function() SetState(not state) end)
			float.BackgroundColor3 = state and Theme.On or Theme.CardHover
			return float
		end)
		if default then
			SetState(true)
		end
		return SetState
	end

	local function Button(page, text, callback)
		local card = New("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0,
			LayoutOrder = Next()
		}, page)
		Corner(card, 10)
		local scale = New("UIScale", { Scale = 1 }, card)
		local btn = New("TextButton", {
			Size = UDim2.new(1, -56, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 12,
			TextWrapped = true,
			AutoButtonColor = false
		}, card)
		Reg(btn, text)
		btn.MouseEnter:Connect(function() Tween(card, 0.12, { BackgroundColor3 = Theme.CardHover }) end)
		btn.MouseLeave:Connect(function()
			Tween(card, 0.15, { BackgroundColor3 = Theme.Card })
			Tween(scale, 0.12, { Scale = 1 })
		end)
		btn.MouseButton1Down:Connect(function() Tween(scale, 0.08, { Scale = 0.97 }) end)
		btn.MouseButton1Up:Connect(function() Tween(scale, 0.14, { Scale = 1 }, Enum.EasingStyle.Back) end)
		local getFloat = nil
		local function Fire()
			task.spawn(callback, btn)
			local float = getFloat and getFloat()
			if float then
				Reg(float, LocReg[btn] or btn.Text)
			end
		end
		btn.MouseButton1Click:Connect(Fire)
		getFloat = MakePin(card, function()
			return CreateFloat(LocReg[btn] or btn.Text, Fire)
		end)
		return btn
	end

	local activeSlider = nil
	local activePage = nil
	UserInputService.InputChanged:Connect(function(input)
		if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			activeSlider(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if activeSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local page = activePage
			activeSlider = nil
			activePage = nil
			if page then
				page.ScrollingEnabled = true
			end
		end
	end)

	local function Slider(page, text, minV, maxV, default, step, callback, suffix)
		suffix = suffix or ""
		local card = New("Frame", {
			Size = UDim2.new(1, 0, 0, 54),
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0,
			LayoutOrder = Next()
		}, page)
		Corner(card, 10)
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 6),
			Size = UDim2.new(1, -92, 0, 20),
			Font = Enum.Font.GothamSemibold,
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		}, card)
		local box = New("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 6),
			Size = UDim2.fromOffset(66, 20),
			BackgroundColor3 = Theme.Bg,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Cyan,
			TextSize = 11,
			ClearTextOnFocus = false
		}, card)
		Corner(box, 6)
		local track = New("Frame", {
			Position = UDim2.new(0, 12, 0, 38),
			Size = UDim2.new(1, -24, 0, 6),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0
		}, card)
		Corner(track, 3)
		local fill = New("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0
		}, track)
		Corner(fill, 3)
		New("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Cyan) }, fill)
		local knob = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			ZIndex = 2
		}, track)
		Corner(knob, 8)
		local hit = New("TextButton", {
			Position = UDim2.new(0, 0, 0, 26),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3
		}, card)

		local value = default
		local function render()
			local ratio = (value - minV) / (maxV - minV)
			fill.Size = UDim2.fromScale(ratio, 1)
			knob.Position = UDim2.new(ratio, 0, 0.5, 0)
			box.Text = tostring(tonumber(string.format("%.3f", value))) .. suffix
		end
		local function set(v, fire)
			v = math.clamp(v, minV, maxV)
			v = math.floor(v / step + 0.5) * step
			v = math.clamp(v, minV, maxV)
			local changed = v ~= value
			value = v
			render()
			if fire and changed then
				task.spawn(callback, v)
			end
		end
		render()

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				activePage = page
				page.ScrollingEnabled = false
				activeSlider = function(x)
					local width = track.AbsoluteSize.X
					if width <= 0 then
						return
					end
					set(minV + (maxV - minV) * math.clamp((x - track.AbsolutePosition.X) / width, 0, 1), true)
				end
				activeSlider(input.Position.X)
			end
		end)
		box.FocusLost:Connect(function()
			local n = tonumber(string.match(box.Text, "-?%d+%.?%d*"))
			if n then
				set(n, true)
			else
				render()
			end
		end)
		return { Set = set, Get = function() return value end }
	end

	local tMove = AddTab("Di Chuyển")
	local tAbility = AddTab("Năng Lực")
	local tCombat = AddTab("Chiến Đấu")
	local tVisual = AddTab("Hình Ảnh")
	local tPlayers = AddTab("Người Chơi")
	local tSystem = AddTab("Hệ Thống")
	local tClock = AddTab("Đồng Hồ")

	local menuOpen = false
	local function SetMenuOpen(open)
		menuOpen = open
		if open then
			Window.Visible = true
			winScale.Scale = 0.85
			Window.GroupTransparency = 1
			Tween(winScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			Tween(Window, 0.22, { GroupTransparency = 0 })
		else
			Tween(winScale, 0.18, { Scale = 0.9 })
			local fade = Tween(Window, 0.18, { GroupTransparency = 1 })
			fade.Completed:Connect(function()
				if not menuOpen then
					Window.Visible = false
				end
			end)
		end
	end

	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		MinBtn.Text = minimized and "+" or "-"
		if minimized then
			Tween(Window, 0.3, { Size = UDim2.fromOffset(winW, HEADER_H) }, Enum.EasingStyle.Quint)
			task.delay(0.3, function()
				if minimized then
					Body.Visible = false
				end
			end)
		else
			Body.Visible = true
			Tween(Window, 0.3, { Size = UDim2.fromOffset(winW, winH) }, Enum.EasingStyle.Quint)
		end
	end)
	HideBtn.MouseButton1Click:Connect(function()
		SetMenuOpen(false)
	end)

	local calcPanel = nil
	local function BuildCalculator()
		local CALC_W, CALC_H = 168, 256
		local function FitScale()
			local area = FloatGui.AbsoluteSize
			if area.X <= 0 or area.Y <= 0 then
				area = Workspace.CurrentCamera.ViewportSize
			end
			return math.clamp(math.min((area.Y - 16) / CALC_H, (area.X - 16) / CALC_W), 0.5, 1)
		end
		local baseScale = FitScale()
		local panel = New("Frame", {
			Name = "Calculator",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(CALC_W, CALC_H),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Active = true,
			Visible = false,
			ZIndex = 50
		}, FloatGui)
		Corner(panel, 12)
		Stroke(panel, Theme.Accent, 1.2, 0.35)
		New("UIGradient", { Color = ColorSequence.new(Theme.Panel, Theme.Bg), Rotation = 90 }, panel)
		local panelScale = New("UIScale", { Scale = baseScale }, panel)

		local titleBar = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			Active = true
		}, panel)
		MakeDraggable(titleBar, panel)
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(1, -44, 1, 0),
			Font = Enum.Font.GothamBlack,
			Text = "Máy tính",
			TextColor3 = Theme.Text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left
		}, titleBar)
		local closeBtn = New("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -5, 0.5, 0),
			Size = UDim2.fromOffset(24, 20),
			BackgroundColor3 = Theme.CardHover,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "X",
			TextColor3 = Theme.Text,
			TextSize = 11
		}, titleBar)
		Corner(closeBtn, 7)
		closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.12, { BackgroundColor3 = Theme.Red }) end)
		closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.15, { BackgroundColor3 = Theme.CardHover }) end)

		local display = New("Frame", {
			Position = UDim2.new(0, 8, 0, 28),
			Size = UDim2.new(1, -16, 0, 48),
			BackgroundColor3 = Theme.Bg,
			BorderSizePixel = 0,
			ClipsDescendants = true
		}, panel)
		Corner(display, 10)
		Stroke(display, Theme.Accent, 1, 0.7)
		local exprLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0, 3),
			Size = UDim2.new(1, -16, 0, 12),
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Theme.Sub,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Right
		}, display)
		local resultLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0, 16),
			Size = UDim2.new(1, -16, 0, 28),
			Font = Enum.Font.GothamBold,
			Text = "0",
			TextColor3 = Theme.Text,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right
		}, display)
		New("UITextSizeConstraint", { MaxTextSize = 24, MinTextSize = 10 }, resultLabel)

		local pad = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0, 82),
			Size = UDim2.new(1, -16, 0, 166)
		}, panel)
		New("UIGridLayout", {
			CellSize = UDim2.new(0.25, -3, 0, 30),
			CellPadding = UDim2.fromOffset(4, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirectionMaxCells = 4
		}, pad)

		local state = { tokens = {}, cur = "0", fresh = true, justEval = false, err = false, exprText = "" }

		local function FormatNum(n)
			if n ~= n or n == math.huge or n == -math.huge then
				return nil
			end
			if math.abs(n) >= 1e15 then
				return string.format("%.6g", n)
			end
			local str = string.format("%.10f", n)
			str = str:gsub("0+$", "")
			str = str:gsub("%.$", "")
			if str == "-0" or str == "" then
				str = "0"
			end
			return str
		end

		local function Render()
			local parts = {}
			if state.exprText ~= "" then
				parts[1] = state.exprText
			else
				for _, tk in ipairs(state.tokens) do
					parts[#parts + 1] = type(tk) == "number" and (FormatNum(tk) or "0") or tk
				end
			end
			exprLabel.Text = table.concat(parts, " ")
			if state.err then
				resultLabel.Text = T("Lỗi")
				resultLabel.TextColor3 = Theme.Red
			else
				resultLabel.Text = state.cur
				resultLabel.TextColor3 = Theme.Text
			end
		end

		local function ResetState()
			state.tokens = {}
			state.cur = "0"
			state.fresh = true
			state.justEval = false
			state.err = false
			state.exprText = ""
		end

		local function Evaluate(tokens)
			local list = { tokens[1] }
			for i = 2, #tokens, 2 do
				local op, rhs = tokens[i], tokens[i + 1]
				if op == "×" then
					list[#list] = list[#list] * rhs
				elseif op == "÷" then
					if rhs == 0 then
						return nil
					end
					list[#list] = list[#list] / rhs
				else
					list[#list + 1] = op
					list[#list + 1] = rhs
				end
			end
			local result = list[1]
			for i = 2, #list, 2 do
				if list[i] == "+" then
					result = result + list[i + 1]
				else
					result = result - list[i + 1]
				end
			end
			return result
		end

		local function PressDigit(d)
			if state.err or state.justEval then
				ResetState()
			end
			state.exprText = ""
			if state.fresh then
				state.cur = d
				state.fresh = false
			else
				if #state.cur >= 15 then
					return
				end
				state.cur = (state.cur == "0") and d or (state.cur .. d)
			end
		end

		local function PressDot()
			if state.err or state.justEval then
				ResetState()
			end
			state.exprText = ""
			if state.fresh then
				state.cur = "0."
				state.fresh = false
			elseif not string.find(state.cur, ".", 1, true) then
				state.cur = state.cur .. "."
			end
		end

		local function PressOp(op)
			if state.err then
				return
			end
			if state.justEval then
				state.tokens = {}
				state.justEval = false
			end
			state.exprText = ""
			local n = #state.tokens
			if state.fresh and n > 0 then
				state.tokens[n] = op
			else
				state.tokens[n + 1] = tonumber(state.cur) or 0
				state.tokens[n + 2] = op
				state.fresh = true
			end
		end

		local function PressEquals()
			if state.err or #state.tokens == 0 then
				return
			end
			local tokens = table.clone(state.tokens)
			if state.fresh then
				table.remove(tokens)
			else
				tokens[#tokens + 1] = tonumber(state.cur) or 0
			end
			local parts = {}
			for _, tk in ipairs(tokens) do
				parts[#parts + 1] = type(tk) == "number" and (FormatNum(tk) or "0") or tk
			end
			local result = Evaluate(tokens)
			local formatted = result and FormatNum(result)
			state.tokens = {}
			if formatted then
				state.cur = formatted
				state.exprText = table.concat(parts, " ") .. " ="
				state.justEval = true
			else
				state.cur = "0"
				state.exprText = ""
				state.err = true
			end
			state.fresh = true
		end

		local function PressPercent()
			if state.err then
				return
			end
			local value = FormatNum((tonumber(state.cur) or 0) / 100)
			state.cur = value or "0"
		end

		local function PressSign()
			if state.err or state.cur == "0" then
				return
			end
			if string.sub(state.cur, 1, 1) == "-" then
				state.cur = string.sub(state.cur, 2)
			else
				state.cur = "-" .. state.cur
			end
		end

		local function PressDelete()
			if state.err or state.justEval then
				ResetState()
				return
			end
			if state.fresh then
				return
			end
			state.cur = string.sub(state.cur, 1, -2)
			if state.cur == "" or state.cur == "-" then
				state.cur = "0"
			end
		end

		local function MakeKey(label, order, bg, textColor, handler)
			local key = New("TextButton", {
				BackgroundColor3 = bg,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = label,
				TextColor3 = textColor,
				TextSize = 14,
				LayoutOrder = order
			}, pad)
			Corner(key, 8)
			local keyScale = New("UIScale", { Scale = 1 }, key)
			local hoverColor = bg:Lerp(Color3.new(1, 1, 1), 0.14)
			key.MouseEnter:Connect(function() Tween(key, 0.1, { BackgroundColor3 = hoverColor }) end)
			key.MouseLeave:Connect(function()
				Tween(key, 0.12, { BackgroundColor3 = bg })
				Tween(keyScale, 0.1, { Scale = 1 })
			end)
			key.MouseButton1Down:Connect(function() Tween(keyScale, 0.06, { Scale = 0.93 }) end)
			key.MouseButton1Up:Connect(function() Tween(keyScale, 0.12, { Scale = 1 }, Enum.EasingStyle.Back) end)
			key.MouseButton1Click:Connect(function()
				handler()
				Render()
			end)
		end

		local layout = {
			{ "C", Theme.CardHover, Theme.Red, function() ResetState() end },
			{ "DEL", Theme.CardHover, Theme.Text, PressDelete },
			{ "%", Theme.CardHover, Theme.Text, PressPercent },
			{ "÷", Theme.Accent, Theme.Text, function() PressOp("÷") end },
			{ "7", Theme.Card, Theme.Text, function() PressDigit("7") end },
			{ "8", Theme.Card, Theme.Text, function() PressDigit("8") end },
			{ "9", Theme.Card, Theme.Text, function() PressDigit("9") end },
			{ "×", Theme.Accent, Theme.Text, function() PressOp("×") end },
			{ "4", Theme.Card, Theme.Text, function() PressDigit("4") end },
			{ "5", Theme.Card, Theme.Text, function() PressDigit("5") end },
			{ "6", Theme.Card, Theme.Text, function() PressDigit("6") end },
			{ "-", Theme.Accent, Theme.Text, function() PressOp("-") end },
			{ "1", Theme.Card, Theme.Text, function() PressDigit("1") end },
			{ "2", Theme.Card, Theme.Text, function() PressDigit("2") end },
			{ "3", Theme.Card, Theme.Text, function() PressDigit("3") end },
			{ "+", Theme.Accent, Theme.Text, function() PressOp("+") end },
			{ "±", Theme.CardHover, Theme.Text, PressSign },
			{ "0", Theme.Card, Theme.Text, function() PressDigit("0") end },
			{ ".", Theme.Card, Theme.Text, PressDot },
			{ "=", Theme.On, Theme.Bg, PressEquals }
		}
		for order, item in ipairs(layout) do
			MakeKey(item[1], order, item[2], item[3], item[4])
		end

		local function SetOpen(open)
			if open then
				baseScale = FitScale()
				panel.Visible = true
				panelScale.Scale = baseScale * 0.88
				Tween(panelScale, 0.22, { Scale = baseScale }, Enum.EasingStyle.Back)
			else
				panel.Visible = false
			end
		end
		closeBtn.MouseButton1Click:Connect(function() SetOpen(false) end)
		table.insert(LocHooks, Render)
		Render()
		return { Panel = panel, SetOpen = SetOpen }
	end

	CalcBtn.MouseButton1Click:Connect(function()
		if not calcPanel then
			calcPanel = BuildCalculator()
		end
		calcPanel.SetOpen(not calcPanel.Panel.Visible)
	end)


	local ICON_SIZE = 46
	local MenuIcon = New("ImageButton", {
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.fromOffset(ICON_SIZE, ICON_SIZE),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Image = iconAsset or "",
		ScaleType = Enum.ScaleType.Crop
	}, FloatGui)
	Corner(MenuIcon, ICON_SIZE / 2)
	local iconStroke = Stroke(MenuIcon, Theme.Cyan, 3, 0)
	Perf.iconPulse = TweenService:Create(
		iconStroke,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.75, Thickness = 5 }
	)
	Perf.iconPulse:Play()
	local iconScale = New("UIScale", { Scale = 1 }, MenuIcon)
	MenuIcon.MouseEnter:Connect(function() Tween(iconScale, 0.15, { Scale = 1.1 }) end)
	MenuIcon.MouseLeave:Connect(function() Tween(iconScale, 0.15, { Scale = 1 }) end)
	MenuIcon.MouseButton1Down:Connect(function() Tween(iconScale, 0.08, { Scale = 0.92 }) end)
	MenuIcon.MouseButton1Up:Connect(function() Tween(iconScale, 0.15, { Scale = 1.1 }, Enum.EasingStyle.Back) end)
	if not iconAsset then
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			Text = "S",
			TextColor3 = Theme.Text,
			TextSize = 26
		}, MenuIcon)
	end
	local iconDrag = MakeDraggable(MenuIcon, MenuIcon)
	MenuIcon.MouseButton1Click:Connect(function()
		if not iconDrag.IsDragging() then
			SetMenuOpen(not menuOpen)
		end
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.RightShift then
			SetMenuOpen(not menuOpen)
		end
	end)

	local function ApplyBodyScale(scale)
		local char = LocalPlayer.Character
		if not char then
			return
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if not part:FindFirstChild("OriginalSize") then
					New("Vector3Value", { Name = "OriginalSize", Value = part.Size }, part)
				end
				if part.Name == "HumanoidRootPart" then
					part.Size = Vector3.new(2, 2, 1) * scale
				else
					part.Size = part.OriginalSize.Value * scale
				end
			end
		end
		local hum = GetHumanoid()
		if hum then
			hum.HipHeight = 2 * scale
		end
	end

	RunService.Heartbeat:Connect(function()
		local hum = GetHumanoid()
		if not hum then
			return
		end
		if Motion.speedLock and hum.WalkSpeed ~= Motion.speed then
			hum.WalkSpeed = Motion.speed
		end
		if Motion.jumpLock then
			if not hum.UseJumpPower then
				hum.UseJumpPower = true
			end
			if hum.JumpPower ~= Motion.jump then
				hum.JumpPower = Motion.jump
			end
		end
	end)

	do
		Section(tMove, "Tốc độ chạy")
		local speedSlider = Slider(tMove, "Tốc độ", 16, 300, 17, 1, function(v)
			Motion.speed = v
			Motion.speedLock = true
		end)
		Button(tMove, "Siêu tốc (100)", function()
			Motion.speed = 100
			Motion.speedLock = true
			speedSlider.Set(100, false)
		end)
		Button(tMove, "Về tốc độ mặc định (16)", function()
			Motion.speedLock = false
			speedSlider.Set(16, false)
			local hum = GetHumanoid()
			if hum then
				hum.WalkSpeed = 16
			end
		end)

		Section(tMove, "Kích thước cơ thể")
		local scaleSlider = Slider(tMove, "Tỷ lệ kích thước", 0.5, 6, 1, 0.1, ApplyBodyScale, "x")
		Button(tMove, "Về kích thước gốc", function()
			scaleSlider.Set(1, false)
			ApplyBodyScale(1)
		end)

		Section(tMove, "Chống khống chế")
		local antiStunConn = nil
		Toggle(tMove, "Chống stun / đóng băng", false, function(enabled)
			if antiStunConn then
				antiStunConn:Disconnect()
				antiStunConn = nil
			end
			if enabled then
				antiStunConn = RunService.Heartbeat:Connect(function()
					local char = LocalPlayer.Character
					local hum = GetHumanoid()
					if hum then
						hum.PlatformStand = false
						hum.Sit = false
						hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
						hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						hum:SetStateEnabled(Enum.HumanoidStateType.Stunned, false)
						if hum.WalkSpeed <= 0 then
							hum.WalkSpeed = Motion.speedLock and Motion.speed or 16
						end
					end
					if char then
						for _, child in ipairs(char:GetChildren()) do
							if child:IsA("ValueBase") then
								local name = child.Name:lower()
								if name:find("stun") or name:find("freeze") or name:find("slow") or name:find("bind") then
									child:Destroy()
								end
							end
						end
					end
				end)
			end
		end, "Tự gỡ trạng thái khống chế")

		Section(tMove, "Điểm dịch chuyển")
		local waypoints = {}
		for i = 1, 3 do
			local row = New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 36),
				LayoutOrder = Next()
			}, tMove)
			New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, row)
			local function Half(key, color, onPress)
				local source = function() return T(key) .. " " .. i end
				local card = New("Frame", {
					Size = UDim2.new(0.5, -3, 1, 0),
					BackgroundColor3 = color,
					BorderSizePixel = 0
				}, row)
				Corner(card, 10)
				local btn = New("TextButton", {
					Size = UDim2.new(1, -54, 1, 0),
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					Font = Enum.Font.GothamSemibold,
					Text = "",
					TextColor3 = Theme.Text,
					TextSize = 11,
					TextWrapped = true
				}, card)
				Reg(btn, source)
				local function Fire()
					onPress(card, color)
				end
				btn.MouseButton1Click:Connect(Fire)
				MakePin(card, function()
					return CreateFloat(source, Fire)
				end)
			end
			Half("Lưu vị trí", Theme.Card, function(card, color)
				local root = GetRoot(LocalPlayer.Character)
				if root then
					waypoints[i] = root.CFrame
					card.BackgroundColor3 = Theme.On
					task.delay(0.4, function() card.BackgroundColor3 = color end)
				end
			end)
			Half("Đến vị trí", Theme.AccentSoft, function()
				local root = GetRoot(LocalPlayer.Character)
				if root and waypoints[i] then
					root.CFrame = waypoints[i]
				end
			end)
		end
	end

	do
		Section(tAbility, "Sức nhảy")
		local jumpSlider = Slider(tAbility, "Lực nhảy", 50, 500, 50, 5, function(v)
			Motion.jump = v
			Motion.jumpLock = true
		end)
		Button(tAbility, "Nhảy cao (200)", function()
			Motion.jump = 200
			Motion.jumpLock = true
			jumpSlider.Set(200, false)
		end)
		Button(tAbility, "Về lực nhảy mặc định", function()
			Motion.jumpLock = false
			jumpSlider.Set(50, false)
			local hum = GetHumanoid()
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = 50
			end
		end)
		local infiniteJump = false
		Toggle(tAbility, "Nhảy vô hạn trên không", false, function(v)
			infiniteJump = v
		end)
		UserInputService.JumpRequest:Connect(function()
			if infiniteJump then
				local hum = GetHumanoid()
				if hum then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)

		Section(tAbility, "Xuyên tường & tàng hình")
		local noclipConn = nil
		local noclipOriginal = setmetatable({}, { __mode = "k" })
		local function RestoreNoclip()
			for part, wasSolid in pairs(noclipOriginal) do
				if wasSolid and part.Parent then
					part.CanCollide = true
				end
				noclipOriginal[part] = nil
			end
			local root = GetRoot(LocalPlayer.Character)
			if root then
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
		Toggle(tAbility, "Xuyên tường (Noclip)", false, function(enabled)
			if noclipConn then
				noclipConn:Disconnect()
				noclipConn = nil
			end
			if enabled then
				noclipConn = RunService.Stepped:Connect(function()
					local char = LocalPlayer.Character
					if char then
						for _, p in ipairs(char:GetDescendants()) do
							if p:IsA("BasePart") then
								if noclipOriginal[p] == nil then
									noclipOriginal[p] = p.CanCollide
								end
								if p.CanCollide then
									p.CanCollide = false
								end
							end
						end
					end
				end)
			else
				RestoreNoclip()
			end
		end)

		local invisConn = nil
		local invisOriginal = setmetatable({}, { __mode = "k" })
		local function RestoreInvisible()
			for obj, value in pairs(invisOriginal) do
				if obj.Parent then
					obj.Transparency = value
				end
				invisOriginal[obj] = nil
			end
		end
		Toggle(tAbility, "Tàng hình", false, function(enabled)
			if invisConn then
				invisConn:Disconnect()
				invisConn = nil
			end
			if enabled then
				invisConn = RunService.RenderStepped:Connect(function()
					local char = LocalPlayer.Character
					if not char then
						return
					end
					for _, obj in ipairs(char:GetDescendants()) do
						if (obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart") or obj:IsA("Decal") then
							if invisOriginal[obj] == nil then
								invisOriginal[obj] = obj.Transparency
							end
							if obj.Transparency ~= 1 then
								obj.Transparency = 1
							end
						end
					end
				end)
			else
				RestoreInvisible()
			end
		end, "Bấm để ẩn / hiện")

		Section(tAbility, "Sàn đất ảo")
		local vPlatform, vConn = nil, nil
		local platformY = 0
		local platformFollow = false
		local function GetFeetY()
			local root, hum = GetRoot(LocalPlayer.Character), GetHumanoid()
			if root and hum then
				return root.Position.Y - (hum.HipHeight + root.Size.Y / 2) - 0.5
			end
			return nil
		end
		local function ClearPlatform()
			if vConn then
				vConn:Disconnect()
				vConn = nil
			end
			if vPlatform then
				vPlatform:Destroy()
				vPlatform = nil
			end
		end
		Toggle(tAbility, "Tạo đất đứng ảo", false, function(v)
			ClearPlatform()
			if v then
				platformY = GetFeetY() or 0
				vPlatform = New("Part", {
					Name = "VirtualPlatform",
					Anchored = true,
					CanCollide = true,
					Size = Vector3.new(16, 1, 16),
					Material = Enum.Material.Neon,
					Color = Theme.Accent,
					Transparency = 0.4,
					CastShadow = false
				}, Workspace)
				vConn = RunService.Heartbeat:Connect(function()
					local root = GetRoot(LocalPlayer.Character)
					if root and vPlatform then
						if platformFollow then
							local y = GetFeetY()
							if y then
								platformY = y
							end
						end
						vPlatform.CFrame = CFrame.new(root.Position.X, platformY, root.Position.Z)
					end
				end)
			end
		end)
		Toggle(tAbility, "Đất ảo bám chân (đi theo)", false, function(v)
			platformFollow = v
		end)
		Button(tAbility, "Nâng đất +5m", function() platformY = platformY + 5 end)
		Button(tAbility, "Hạ đất -5m", function() platformY = platformY - 5 end)

		Section(tAbility, "Dịch chuyển theo trục Y")
		local skyHeight = 500
		Button(tAbility, "Teleport lên trời", function()
			local root = GetRoot(LocalPlayer.Character)
			if root then
				root.CFrame = root.CFrame + Vector3.new(0, skyHeight, 0)
				if vPlatform then
					platformY = platformY + skyHeight
				end
			end
		end)
		Button(tAbility, "Nhảy xuống đất", function()
			local root = GetRoot(LocalPlayer.Character)
			if root then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = { LocalPlayer.Character, vPlatform }
				local hit = Workspace:Raycast(root.Position, Vector3.new(0, -10000, 0), params)
				if hit then
					root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 4, 0))
					if vPlatform then
						platformY = GetFeetY() or platformY
					end
				end
			end
		end)
	end

	do
		local aimEnabled = false
		local aimAll = false
		local aimFov = 150
		local aimSmooth = 0.35
		local aimWall = true
		local aimPart = "Head"
		local rmbHeld = false
		local aimSticky = false
		local lockedPart = nil

		local fovCircle = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(aimFov * 2, aimFov * 2),
			BackgroundTransparency = 1,
			Visible = false
		}, OverlayGui)
		Corner(fovCircle, 1000)
		Stroke(fovCircle, Theme.Text, 1, 0.4)

		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				rmbHeld = true
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				rmbHeld = false
			end
		end)

		local function IsTargetVisible(part, char)
			local cam = Workspace.CurrentCamera
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { LocalPlayer.Character }
			local res = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
			return res == nil or res.Instance:IsDescendantOf(char)
		end

		local function GetAimTarget()
			local cam = Workspace.CurrentCamera
			local center = cam.ViewportSize / 2
			local bestTarget, bestDist = nil, math.huge
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and (aimAll or IsEnemy(p)) and p.Character and not Fallen.set[p] then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					local part = p.Character:FindFirstChild(aimPart)
					if hum and hum.Health > 0 and part then
						local pos, onScreen = cam:WorldToViewportPoint(part.Position)
						if onScreen then
							local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
							if dist <= aimFov and dist < bestDist then
								if not aimWall or IsTargetVisible(part, p.Character) then
									bestTarget = part
									bestDist = dist
								end
							end
						end
					end
				end
			end
			return bestTarget
		end

		RunService.RenderStepped:Connect(function()
			fovCircle.Visible = aimEnabled
			if not aimEnabled then
				return
			end
			fovCircle.Size = UDim2.fromOffset(aimFov * 2, aimFov * 2)
			if isTouchOnly or rmbHeld then
				local target = nil
				if aimSticky and lockedPart and lockedPart.Parent then
					local lockedHum = lockedPart.Parent:FindFirstChildOfClass("Humanoid")
					if lockedHum and lockedHum.Health > 0 then
						target = lockedPart
					end
				end
				if not target then
					target = GetAimTarget()
					lockedPart = target
				end
				if target then
					local cam = Workspace.CurrentCamera
					cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), aimSmooth)
				end
			else
				lockedPart = nil
			end
		end)

		Section(tCombat, "Aimbot")
		Toggle(tCombat, "Bật Aimbot", false, function(v) aimEnabled = v end, "Giữ chuột phải để ghim (điện thoại: tự động)")
		Toggle(tCombat, "Aim cả đồng đội", false, function(v) aimAll = v end, "Tắt = chỉ nhắm kẻ địch")
		Toggle(tCombat, "Kiểm tra vật cản (Wallcheck)", true, function(v) aimWall = v end)
		Toggle(tCombat, "Khóa dính mục tiêu", false, function(v)
			aimSticky = v
			if not v then
				lockedPart = nil
			end
		end, "Không đổi mục tiêu khi đang ghim")
		Button(tCombat, function() return T("Mục tiêu") .. ": " .. T(aimPart == "Head" and "Đầu" or "Thân") end, function(b)
			aimPart = (aimPart == "Head") and "HumanoidRootPart" or "Head"
			b.Text = LocReg[b]()
		end)
		Slider(tCombat, "Bán kính FOV", 30, 800, 150, 5, function(v) aimFov = v end)
		Slider(tCombat, "Độ bám Aim", 1, 100, 35, 1, function(v) aimSmooth = v / 100 end, "%")

		local triggerEnabled = false
		local triggerRate = 12
		local triggerOnTarget = false
		local triggerId = 0
		local triggerLastCheck = 0
		local triggerParams = RaycastParams.new()
		triggerParams.FilterType = Enum.RaycastFilterType.Exclude

		local function GetCrosshairEnemy()
			local cam = Workspace.CurrentCamera
			local myChar = LocalPlayer.Character
			if not (cam and myChar) then
				return nil
			end
			triggerParams.FilterDescendantsInstances = { myChar }
			local result = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 2000, triggerParams)
			if not result then
				return nil
			end
			local node = result.Instance
			while node and node ~= Workspace do
				local p = Players:GetPlayerFromCharacter(node)
				if p then
					if p ~= LocalPlayer and (aimAll or IsEnemy(p)) and not Fallen.set[p] then
						local hum = node:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							return p
						end
					end
					return nil
				end
				node = node.Parent
			end
			return nil
		end

		RunService.Heartbeat:Connect(function()
			if not triggerEnabled then
				triggerOnTarget = false
				return
			end
			local now = tick()
			if now - triggerLastCheck < 0.03 then
				return
			end
			triggerLastCheck = now
			triggerOnTarget = GetCrosshairEnemy() ~= nil
		end)

		Section(tCombat, "Tự động bắn")
		Toggle(tCombat, "Tự bắn khi ngắm trúng địch", false, function(v)
			triggerEnabled = v
			triggerId = triggerId + 1
			triggerOnTarget = false
			if v then
				local id = triggerId
				task.spawn(function()
					while triggerEnabled and id == triggerId do
						if triggerOnTarget then
							local center = Workspace.CurrentCamera.ViewportSize / 2
							PerformClick(center.X, center.Y)
							task.wait(1 / triggerRate)
						else
							task.wait()
						end
					end
				end)
			end
		end)
		Slider(tCombat, "Tốc độ bắn mỗi giây", 1, 60, 12, 1, function(v) triggerRate = v end)

		Section(tCombat, "Chiến thuật")
		Button(tCombat, "TP tới kẻ yếu máu nhất", function()
			local myRoot = GetRoot(LocalPlayer.Character)
			if not myRoot then
				return
			end
			local targetRoot, lowestPct = nil, 101
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and not Fallen.set[p] then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					local root = GetRoot(p.Character)
					if hum and root and hum.Health > 0 then
						local pct = (hum.Health / hum.MaxHealth) * 100
						if pct < lowestPct then
							lowestPct = pct
							targetRoot = root
						end
					end
				end
			end
			if targetRoot then
				myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
			end
		end)

		local autoClickEnabled = false
		local autoClickRate = 10
		local autoClickId = 0
		local function GetClickPoint()
			if realInput.MouseEnabled and not realInput.TouchEnabled then
				return UserInputService:GetMouseLocation()
			end
			return Workspace.CurrentCamera.ViewportSize / 2
		end

		Section(tCombat, "Tự động bấm")
		Toggle(tCombat, "Tự bấm vào màn hình", false, function(v)
			autoClickEnabled = v
			autoClickId = autoClickId + 1
			if v then
				local id = autoClickId
				task.spawn(function()
					while autoClickEnabled and id == autoClickId do
						local point = GetClickPoint()
						PerformClick(point.X, point.Y)
						task.wait(1 / autoClickRate)
					end
				end)
			end
		end)
		Slider(tCombat, "Số lần bấm mỗi giây", 1, 60, 10, 1, function(v) autoClickRate = v end)
	end

	do
		local hb = {
			enabled = false,
			visible = true,
			team = false,
			size = 10,
			token = 0,
			orig = {},
			vis = {},
			hooked = {},
			conns = {}
		}

		local function DropVisual(root)
			local v = hb.vis[root]
			if v then
				hb.vis[root] = nil
				v:Destroy()
			end
		end

		local function Restore(root)
			local o = hb.orig[root]
			if not o then
				return
			end
			hb.orig[root] = nil
			DropVisual(root)
			if root.Parent then
				root.Size = o.Size
				root.Transparency = o.Transparency
				root.CanCollide = o.CanCollide
				root.Massless = o.Massless
				root.CustomPhysicalProperties = o.Props
			end
		end

		local function RestoreAll()
			for root in pairs(hb.orig) do
				Restore(root)
			end
		end

		local function Apply(p)
			if not hb.enabled or p == LocalPlayer then
				return
			end
			local char = p.Character
			local root = char and GetRoot(char)
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not (root and hum) then
				return
			end
			if hum.Health <= 0 or Fallen.set[p] or not (hb.team or IsEnemy(p)) then
				Restore(root)
				return
			end
			if not hb.orig[root] then
				hb.orig[root] = {
					Size = root.Size,
					Transparency = root.Transparency,
					CanCollide = root.CanCollide,
					Massless = root.Massless,
					Props = root.CustomPhysicalProperties
				}
			end
			root.Massless = true
			root.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0)
			root.Size = Vector3.new(hb.size, hb.size, hb.size)
			root.Transparency = 1
			root.CanCollide = false
			local v = hb.vis[root]
			if not v then
				v = New("Part", {
					Name = "ST_Hitbox",
					Anchored = true,
					CanCollide = false,
					CanQuery = false,
					CanTouch = false,
					CastShadow = false,
					Massless = true,
					Color = Theme.Red,
					Material = Enum.Material.Neon
				}, Workspace)
				hb.vis[root] = v
			end
			v.Size = root.Size
			v.CFrame = root.CFrame
			v.Transparency = hb.visible and 0.65 or 1
		end

		local function ApplyAll()
			for _, p in ipairs(Players:GetPlayers()) do
				pcall(Apply, p)
			end
		end

		local function Hook(p)
			if p == LocalPlayer or hb.hooked[p] then
				return
			end
			hb.hooked[p] = p.CharacterAdded:Connect(function()
				task.delay(0.6, function()
					pcall(Apply, p)
				end)
			end)
		end

		local function Start()
			if hb.enabled then
				return
			end
			hb.enabled = true
			hb.token = hb.token + 1
			local id = hb.token
			for _, p in ipairs(Players:GetPlayers()) do
				Hook(p)
			end
			hb.conns[1] = Players.PlayerAdded:Connect(Hook)
			hb.conns[2] = Players.PlayerRemoving:Connect(function(p)
				local conn = hb.hooked[p]
				if conn then
					conn:Disconnect()
					hb.hooked[p] = nil
				end
			end)
			hb.conns[3] = RunService.RenderStepped:Connect(function()
				local want = Vector3.new(hb.size, hb.size, hb.size)
				for root in pairs(hb.orig) do
					if root.Parent then
						if root.Size ~= want then
							root.Size = want
						end
						local v = hb.vis[root]
						if v then
							v.CFrame = root.CFrame
						end
					else
						hb.orig[root] = nil
						DropVisual(root)
					end
				end
			end)
			task.spawn(function()
				while hb.enabled and hb.token == id do
					ApplyAll()
					task.wait(1)
				end
			end)
		end

		local function Stop()
			hb.enabled = false
			hb.token = hb.token + 1
			for index, conn in pairs(hb.conns) do
				conn:Disconnect()
				hb.conns[index] = nil
			end
			for p, conn in pairs(hb.hooked) do
				conn:Disconnect()
				hb.hooked[p] = nil
			end
			RestoreAll()
		end

		Fallen.onChange = function(p)
			Apply(p)
		end

		Section(tCombat, "Hitbox")
		Toggle(tCombat, "Tăng hitbox", false, function(v)
			if v then Start() else Stop() end
		end, "Tự làm mới mỗi giây cho mọi người trong máy chủ")
		Toggle(tCombat, "Nhìn thấy hitbox", true, function(v)
			hb.visible = v
			ApplyAll()
		end)
		Toggle(tCombat, "Hitbox cả đồng đội", false, function(v)
			hb.team = v
			ApplyAll()
		end, "Tắt = chỉ kẻ địch")
		Slider(tCombat, "Kích thước hitbox", 2, 60, 10, 1, function(v)
			hb.size = v
			ApplyAll()
		end)
	end

	do
		local fl = { enabled = false, angle = 60, token = 0, saved = setmetatable({}, { __mode = "k" }), conn = nil }

		local function HideChar(char)
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.LocalTransparencyModifier = 1
				elseif obj.Name:sub(1, 3) ~= "ST_" then
					if obj:IsA("Decal") or obj:IsA("Texture") then
						if fl.saved[obj] == nil then
							fl.saved[obj] = obj.Transparency
						end
						obj.Transparency = 1
					elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
						if fl.saved[obj] == nil then
							fl.saved[obj] = obj.Enabled
						end
						obj.Enabled = false
					end
				end
			end
		end

		local function ShowChar(char)
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.LocalTransparencyModifier = 0
				else
					local value = fl.saved[obj]
					if value ~= nil then
						fl.saved[obj] = nil
						pcall(function()
							if type(value) == "number" then
								obj.Transparency = value
							else
								obj.Enabled = value
							end
						end)
					end
				end
			end
		end

		local function Evaluate(p)
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then
				return false
			end
			if hum.Health <= 0 then
				return true
			end
			local root = GetRoot(char)
			if not root or hum.Sit then
				return false
			end
			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Swimming then
				return false
			end
			if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
				return true
			end
			local up = root.CFrame.UpVector.Y
			if Fallen.set[p] then
				return up < math.cos(math.rad(math.max(fl.angle - 15, 5)))
			end
			return up < math.cos(math.rad(fl.angle))
		end

		local function Tick()
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					local fallen = Evaluate(p)
					local was = Fallen.set[p] == true
					if fallen then
						Fallen.set[p] = true
						if p.Character then
							HideChar(p.Character)
						end
					elseif was then
						Fallen.set[p] = nil
						if p.Character then
							ShowChar(p.Character)
						end
					end
					if fallen ~= was and Fallen.onChange then
						pcall(Fallen.onChange, p)
					end
				end
			end
		end

		local function Start()
			if fl.enabled then
				return
			end
			fl.enabled = true
			fl.token = fl.token + 1
			local id = fl.token
			fl.conn = Players.PlayerRemoving:Connect(function(p)
				Fallen.set[p] = nil
			end)
			task.spawn(function()
				while fl.enabled and fl.token == id do
					pcall(Tick)
					task.wait(0.15)
				end
			end)
		end

		local function Stop()
			fl.enabled = false
			fl.token = fl.token + 1
			if fl.conn then
				fl.conn:Disconnect()
				fl.conn = nil
			end
			for p in pairs(Fallen.set) do
				Fallen.set[p] = nil
				if p.Character then
					pcall(ShowChar, p.Character)
				end
				if Fallen.onChange then
					pcall(Fallen.onChange, p)
				end
			end
		end

		Section(tCombat, "Người ngã")
		Toggle(tCombat, "Ẩn người ngã và xác chết", false, function(v)
			if v then Start() else Stop() end
		end, "Gồm cả xác chết, hồi sinh sẽ hiện lại")
		Slider(tCombat, "Góc nghiêng coi là ngã", 30, 85, 60, 1, function(v)
			fl.angle = v
		end, "°")
	end

	do
		local RelationColor = { ally = Theme.On, enemy = Theme.Red, neutral = Theme.Sub }
		local esp = {
			enabled = false,
			showAlly = true,
			showEnemy = true,
			showBox = true,
			showInfo = true,
			maxDist = 2000,
			scale = 1.15,
			token = 0,
			data = {},
			playerConns = {},
			conns = {}
		}

		local function Destroy(p)
			local d = esp.data[p]
			if d then
				esp.data[p] = nil
				for _, name in ipairs({ "hl", "box", "bb" }) do
					local obj = d[name]
					if obj then
						pcall(function() obj:Destroy() end)
					end
				end
			end
		end

		local function Build(p, char)
			local root = char:WaitForChild("HumanoidRootPart", 5)
			local hum = char:WaitForChild("Humanoid", 5)
			if not (esp.enabled and root and hum and p.Parent and p.Character == char) then
				return
			end
			Destroy(p)
			local hl = New("Highlight", {
				Name = "ST_Highlight",
				Adornee = char,
				FillTransparency = 0.7,
				OutlineTransparency = 0,
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
				Enabled = false
			}, char)
			local box = New("BoxHandleAdornment", {
				Name = "ST_Box",
				Adornee = root,
				AlwaysOnTop = true,
				ZIndex = 5,
				Transparency = 0.82,
				Size = char:GetExtentsSize() * esp.scale,
				Visible = false
			}, root)
			local bb = New("BillboardGui", {
				Name = "ST_Info",
				Adornee = char:FindFirstChild("Head") or root,
				AlwaysOnTop = true,
				Size = UDim2.fromOffset(190, 44),
				StudsOffset = Vector3.new(0, 2.8, 0),
				Enabled = false
			}, char)
			local nameLabel = New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.5, 0),
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = Theme.Text,
				TextStrokeTransparency = 0.4
			}, bb)
			local infoLabel = New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
				Font = Enum.Font.GothamMedium,
				TextSize = 11,
				TextStrokeTransparency = 0.4
			}, bb)
			esp.data[p] = {
				char = char, root = root, hum = hum,
				hl = hl, box = box, bb = bb,
				nameLabel = nameLabel, infoLabel = infoLabel
			}
		end

		local function Track(p)
			if p == LocalPlayer or esp.playerConns[p] then
				return
			end
			esp.playerConns[p] = {
				p.CharacterAdded:Connect(function(char)
					task.spawn(Build, p, char)
				end),
				p.CharacterRemoving:Connect(function()
					Destroy(p)
				end)
			}
			if p.Character then
				task.spawn(Build, p, p.Character)
			end
		end

		local function Untrack(p)
			local list = esp.playerConns[p]
			if list then
				for _, conn in ipairs(list) do
					conn:Disconnect()
				end
				esp.playerConns[p] = nil
			end
			Destroy(p)
		end

		local function UpdateOne(p, d, myRoot)
			if not (p.Parent and d.char.Parent and d.root.Parent) then
				Destroy(p)
				return
			end
			local relation = GetRelation(p)
			local health = d.hum.Health
			local maxHealth = d.hum.MaxHealth
			local pct = maxHealth > 0 and math.clamp(health / maxHealth, 0, 1) or 0
			local dist = myRoot and (d.root.Position - myRoot.Position).Magnitude or 0
			local wanted = (relation == "ally" and esp.showAlly) or (relation ~= "ally" and esp.showEnemy)
			local visible = health > 0 and dist <= esp.maxDist and wanted and not Fallen.set[p]
			d.hl.Enabled = visible
			d.box.Visible = visible and esp.showBox
			d.bb.Enabled = visible and esp.showInfo
			if not visible then
				return
			end
			local color = RelationColor[relation]
			if relation ~= "ally" and pct > 0 and pct < 0.35 then
				color = Theme.Gold
			end
			d.hl.FillColor = color
			d.hl.OutlineColor = color
			d.box.Color3 = color
			d.box.Size = d.char:GetExtentsSize() * esp.scale
			local tag = p.Team and (" • " .. p.Team.Name) or ""
			d.nameLabel.Text = p.DisplayName .. tag
			d.nameLabel.TextColor3 = color
			d.infoLabel.Text = string.format("%s %d%%  •  %dm", T("Máu"), math.floor(pct * 100), math.floor(dist))
			d.infoLabel.TextColor3 = Color3.fromHSV(pct * 0.33, 0.9, 1)
		end

		local function Update()
			local myRoot = GetRoot(LocalPlayer.Character)
			for p, d in pairs(esp.data) do
				pcall(UpdateOne, p, d, myRoot)
			end
		end

		local function Start()
			if esp.enabled then
				return
			end
			esp.enabled = true
			esp.token = esp.token + 1
			local token = esp.token
			for _, p in ipairs(Players:GetPlayers()) do
				Track(p)
			end
			esp.conns[1] = Players.PlayerAdded:Connect(Track)
			esp.conns[2] = Players.PlayerRemoving:Connect(Untrack)
			task.spawn(function()
				while esp.enabled and esp.token == token do
					Update()
					task.wait(Perf.espInterval)
				end
			end)
		end

		local function Stop()
			esp.enabled = false
			esp.token = esp.token + 1
			for index, conn in pairs(esp.conns) do
				conn:Disconnect()
				esp.conns[index] = nil
			end
			for p in pairs(esp.playerConns) do
				Untrack(p)
			end
			for p in pairs(esp.data) do
				Destroy(p)
			end
		end

		Section(tVisual, "ESP người chơi")
		Toggle(tVisual, "Bật ESP", false, function(v)
			if v then Start() else Stop() end
		end, "Quét máy chủ một lần, sau đó tự theo dõi")
		Toggle(tVisual, "Hiện đồng đội (xanh lá)", true, function(v) esp.showAlly = v end)
		Toggle(tVisual, "Hiện kẻ địch (đỏ)", true, function(v) esp.showEnemy = v end)
		Toggle(tVisual, "Hiện khung hộp", true, function(v) esp.showBox = v end)
		Toggle(tVisual, "Hiện tên, máu, khoảng cách", true, function(v) esp.showInfo = v end)
		Slider(tVisual, "Khoảng cách tối đa", 50, 5000, 2000, 50, function(v) esp.maxDist = v end, "m")
		local legend = Note(tVisual, "Xanh lá: đồng đội    Đỏ: kẻ địch    Vàng: địch sắp chết    Trắng: không rõ team", Theme.Sub)
		legend.TextSize = 10

		Section(tVisual, "Chiếu sáng")
		local fullbrightConn, fullbrightOrig = nil, nil
		Toggle(tVisual, "Nhìn trong bóng tối (Fullbright)", false, function(v)
			if v then
				fullbrightOrig = {
					Brightness = Lighting.Brightness,
					ClockTime = Lighting.ClockTime,
					GlobalShadows = Lighting.GlobalShadows,
					Ambient = Lighting.Ambient
				}
				fullbrightConn = RunService.RenderStepped:Connect(function()
					Lighting.Brightness = 2
					Lighting.ClockTime = 14
					Lighting.GlobalShadows = false
					Lighting.Ambient = Color3.fromRGB(190, 190, 190)
				end)
			else
				if fullbrightConn then
					fullbrightConn:Disconnect()
					fullbrightConn = nil
				end
				if fullbrightOrig then
					for prop, val in pairs(fullbrightOrig) do
						pcall(function() Lighting[prop] = val end)
					end
				end
			end
		end)
	end

	do
		local NEW_JOIN_WINDOW = 30
		local joinTimes = {}
		local chosenList = {}
		local currentTarget = nil
		local stickEnabled = false
		local stickConn = nil
		local stickCollideConn = nil
		local stickOffsetY = 0
		local stickBack = 3
		local stickDuration = 10
		local stickSwitchAt = 0
		local stickOriginal = setmetatable({}, { __mode = "k" })
		local serverRows = {}
		local chosenRows = {}
		local chosenSignature = ""
		local RefreshAll
		local RefreshChosenList
		local UpdateStatus
		local StartStick
		local StopStick

		local function AvatarUrl(p)
			return "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
		end

		local function IsNewPlayer(p)
			local t = joinTimes[p]
			return t ~= nil and (tick() - t) < NEW_JOIN_WINDOW
		end

		local function DistanceText(d)
			if d == math.huge then
				return "? m"
			end
			return math.floor(d) .. " m"
		end

		local function MakeEmptyRow(parent, text)
			return New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Font = Enum.Font.GothamMedium,
				Text = text,
				TextColor3 = Theme.Sub,
				TextSize = 10,
				TextWrapped = true,
				LayoutOrder = 99999
			}, parent)
		end

		local function ListBox(page)
			local frame = New("Frame", {
				BackgroundColor3 = Theme.Panel,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = Next()
			}, page)
			Corner(frame, 10)
			Stroke(frame, Theme.Accent, 1, 0.8)
			New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
			Pad(frame, 6, 6, 6, 6)
			return frame
		end

		Section(tPlayers, "Điều khiển bám chân")
		Toggle(tPlayers, "Bám chân người đã chọn", false, function(v)
			stickEnabled = v
			if v then
				StartStick()
			else
				StopStick()
			end
		end, "Lần lượt từ trên xuống dưới")

		local statusCard = New("Frame", {
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 58),
			LayoutOrder = Next()
		}, tPlayers)
		Corner(statusCard, 10)
		Stroke(statusCard, Theme.Accent, 1, 0.6)
		local statusAvatar = New("ImageLabel", {
			Position = UDim2.new(0, 10, 0.5, -21),
			Size = UDim2.fromOffset(42, 42),
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Visible = false
		}, statusCard)
		Corner(statusAvatar, 21)
		Stroke(statusAvatar, Theme.Accent, 2, 0)
		local stickStatus = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = "Trạng thái: Đang tắt",
			TextColor3 = Theme.Sub,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, statusCard)

		LocReg[stickStatus] = nil
		Slider(tPlayers, "Thời gian bám mỗi người", 1, 300, 10, 1, function(v) stickDuration = v end, "s")
		Slider(tPlayers, "Khoảng cách ra sau lưng", -20, 20, 3, 0.5, function(v) stickBack = v end, "m")
		Slider(tPlayers, "Độ cao bám", -50, 50, 0, 1, function(v) stickOffsetY = v end, "m")
		Button(tPlayers, "Xóa tất cả người đã chọn", function()
			chosenList = {}
			currentTarget = nil
			RefreshAll()
		end)

		Section(tPlayers, "Đã chọn (bám lần lượt)")
		local chosenContainer = ListBox(tPlayers)
		local emptyChosenLabel = MakeEmptyRow(chosenContainer, "Chưa chọn ai. Bấm vào người chơi bên dưới để chọn.")

		Section(tPlayers, "Người chơi trong máy chủ")
		local newLabel = New("TextLabel", {
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			Font = Enum.Font.GothamBold,
			Text = "Người mới vào: 0",
			TextColor3 = Theme.Sub,
			TextSize = 10,
			LayoutOrder = Next()
		}, tPlayers)
		Corner(newLabel, 10)
		Button(tPlayers, "Làm mới danh sách", function()
			RefreshAll()
		end)
		local serverContainer = ListBox(tPlayers)
		local emptyServerLabel = MakeEmptyRow(serverContainer, "Chưa có người chơi khác trong máy chủ")

		local function ComputeSignature()
			local parts = {}
			for i, p in ipairs(chosenList) do
				parts[i] = tostring(p.UserId)
			end
			return table.concat(parts, ",") .. "|" .. tostring(currentTarget and currentTarget.UserId) .. "|" .. tostring(stickEnabled)
		end

		local function UpdateChosenInfo()
			for _, row in ipairs(chosenRows) do
				local p = row.player
				local alive = IsAlive(p)
				local status = alive and T("Còn sống") or T("Đã chết")
				if p == currentTarget and stickEnabled then
					status = T("Đang bám")
				end
				row.subLabel.Text = "@" .. p.Name .. "  •  " .. status .. "  •  " .. DistanceText(DistanceTo(p))
				row.subLabel.TextColor3 = alive and Theme.Sub or Theme.Gold
			end
		end

		local function CreateServerRow(p)
			local btn = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = ""
			}, serverContainer)
			Corner(btn, 10)
			local avatar = New("ImageLabel", {
				Position = UDim2.new(0, 8, 0.5, -17),
				Size = UDim2.fromOffset(34, 34),
				BackgroundColor3 = Theme.Panel,
				BorderSizePixel = 0,
				Image = AvatarUrl(p)
			}, btn)
			Corner(avatar, 17)
			local nameLabel = New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 50, 0, 8),
				Size = UDim2.new(1, -112, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = p.DisplayName,
				TextColor3 = Theme.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, btn)
			local subLabel = New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 50, 0, 27),
				Size = UDim2.new(1, -112, 0, 16),
				Font = Enum.Font.GothamMedium,
				Text = "@" .. p.Name,
				TextColor3 = Theme.Sub,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, btn)
			local badge = New("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(46, 26),
				BackgroundColor3 = Theme.Panel,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamBold,
				Text = "+",
				TextColor3 = Theme.Text,
				TextSize = 11
			}, btn)
			Corner(badge, 8)
			btn.MouseButton1Click:Connect(function()
				local idx = table.find(chosenList, p)
				if idx then
					table.remove(chosenList, idx)
					if currentTarget == p then
						currentTarget = nil
					end
				else
					table.insert(chosenList, p)
				end
				RefreshAll()
			end)
			return { btn = btn, nameLabel = nameLabel, subLabel = subLabel, badge = badge, isChosen = false }
		end

		local function UpdateServerRows()
			local entries = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Parent then
					local row = serverRows[p]
					if not row then
						row = CreateServerRow(p)
						serverRows[p] = row
					end
					table.insert(entries, { player = p, row = row, dist = DistanceTo(p) })
				end
			end
			for p, row in pairs(serverRows) do
				if not p.Parent then
					row.btn:Destroy()
					serverRows[p] = nil
				end
			end
			table.sort(entries, function(a, b)
				if a.dist == b.dist then
					return a.player.DisplayName:lower() < b.player.DisplayName:lower()
				end
				return a.dist < b.dist
			end)
			emptyServerLabel.Visible = #entries == 0
			for i, entry in ipairs(entries) do
				local p, row = entry.player, entry.row
				local chosenIdx = table.find(chosenList, p)
				local isNew = IsNewPlayer(p)
				row.btn.LayoutOrder = i
				row.nameLabel.Text = (isNew and ("[" .. T("Mới") .. "] ") or "") .. p.DisplayName
				row.nameLabel.TextColor3 = isNew and Theme.Gold or Theme.Text
				row.subLabel.Text = "@" .. p.Name .. "  •  " .. DistanceText(entry.dist)
				row.badge.Text = chosenIdx and ("#" .. chosenIdx) or "+"
				row.badge.BackgroundColor3 = chosenIdx and Theme.Accent or Theme.Panel
				local nowChosen = chosenIdx ~= nil
				if row.isChosen ~= nowChosen then
					row.isChosen = nowChosen
					Tween(row.btn, 0.25, { BackgroundColor3 = nowChosen and Theme.AccentSoft or Theme.Card })
				end
			end
		end

		RefreshChosenList = function()
			for _, row in ipairs(chosenRows) do
				row.frame:Destroy()
			end
			chosenRows = {}
			emptyChosenLabel.Visible = #chosenList == 0
			for i, p in ipairs(chosenList) do
				local active = (p == currentTarget and stickEnabled)
				local frame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 50),
					BackgroundColor3 = active and Theme.AccentSoft or Theme.Card,
					BorderSizePixel = 0,
					LayoutOrder = i
				}, chosenContainer)
				Corner(frame, 10)
				if active then
					Stroke(frame, Theme.Accent, 1.6, 0)
				end
				local avatar = New("ImageLabel", {
					Position = UDim2.new(0, 8, 0.5, -17),
					Size = UDim2.fromOffset(34, 34),
					BackgroundColor3 = Theme.Panel,
					BorderSizePixel = 0,
					Image = AvatarUrl(p)
				}, frame)
				Corner(avatar, 17)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 50, 0, 8),
					Size = UDim2.new(1, -100, 0, 18),
					Font = Enum.Font.GothamBold,
					Text = i .. ". " .. p.DisplayName,
					TextColor3 = Theme.Text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd
				}, frame)
				local subLabel = New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 50, 0, 27),
					Size = UDim2.new(1, -100, 0, 16),
					Font = Enum.Font.GothamMedium,
					Text = "@" .. p.Name,
					TextColor3 = Theme.Sub,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd
				}, frame)
				local delBtn = New("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.fromOffset(32, 32),
					BackgroundColor3 = Theme.Red,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Font = Enum.Font.GothamBold,
					Text = "X",
					TextColor3 = Theme.Text,
					TextSize = 13
				}, frame)
				Corner(delBtn, 8)
				delBtn.MouseButton1Click:Connect(function()
					local idx = table.find(chosenList, p)
					if idx then
						table.remove(chosenList, idx)
					end
					if currentTarget == p then
						currentTarget = nil
					end
					RefreshAll()
				end)
				table.insert(chosenRows, { frame = frame, subLabel = subLabel, player = p })
			end
			chosenSignature = ComputeSignature()
			UpdateChosenInfo()
		end

		UpdateStatus = function()
			local text, color = T("Trạng thái: Đang tắt"), Theme.Sub
			local showAvatar = false
			if stickEnabled then
				if currentTarget then
					local idx = table.find(chosenList, currentTarget) or 0
					text = string.format(T("Đang bám: %s\n@%s  •  #%d / %d"), currentTarget.DisplayName, currentTarget.Name, idx, #chosenList)
					color = Theme.On
					showAvatar = true
					statusAvatar.Image = AvatarUrl(currentTarget)
				elseif #chosenList == 0 then
					text = T("Chưa chọn người nào để bám")
					color = Theme.Gold
				else
					text = T("Đang chờ người được chọn hồi sinh")
					color = Theme.Gold
				end
			end
			stickStatus.Text = text
			stickStatus.TextColor3 = color
			statusAvatar.Visible = showAvatar
			stickStatus.Position = showAvatar and UDim2.new(0, 64, 0, 0) or UDim2.new(0, 14, 0, 0)
			stickStatus.Size = showAvatar and UDim2.new(1, -76, 1, 0) or UDim2.new(1, -28, 1, 0)
		end

		RefreshAll = function()
			UpdateServerRows()
			RefreshChosenList()
			UpdateStatus()
		end
		table.insert(LocHooks, function()
			RefreshAll()
		end)

		local function SetTarget(p)
			if currentTarget ~= p then
				currentTarget = p
				stickSwitchAt = tick() + stickDuration
				RefreshChosenList()
			end
			UpdateStatus()
		end

		local function PickNextTarget()
			local n = #chosenList
			if n == 0 then
				return nil
			end
			local startIdx = currentTarget and table.find(chosenList, currentTarget) or 0
			for step = 1, n do
				local idx = ((startIdx - 1 + step) % n) + 1
				local p = chosenList[idx]
				if IsAlive(p) then
					return p
				end
			end
			return nil
		end

		local function StickStep()
			if not IsAlive(currentTarget) then
				SetTarget(PickNextTarget())
			elseif #chosenList > 1 and tick() >= stickSwitchAt then
				local nextTarget = PickNextTarget()
				if nextTarget and nextTarget ~= currentTarget then
					SetTarget(nextTarget)
				else
					stickSwitchAt = tick() + stickDuration
				end
			end
			local myRoot = GetRoot(LocalPlayer.Character)
			local myHum = GetHumanoid()
			if not (currentTarget and myRoot and myHum) then
				return
			end
			local tChar = currentTarget.Character
			local tRoot = GetRoot(tChar)
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			if not (tRoot and tHum) then
				return
			end
			local heightDiff = (myHum.HipHeight + myRoot.Size.Y / 2) - (tHum.HipHeight + tRoot.Size.Y / 2) + stickOffsetY
			myRoot.CFrame = tRoot.CFrame * CFrame.new(0, heightDiff, stickBack)
			myRoot.AssemblyLinearVelocity = Vector3.zero
			myRoot.AssemblyAngularVelocity = Vector3.zero
		end

		local function RestoreStickCollide()
			for part, wasSolid in pairs(stickOriginal) do
				if wasSolid and part.Parent then
					part.CanCollide = true
				end
				stickOriginal[part] = nil
			end
		end

		StopStick = function()
			if stickConn then
				stickConn:Disconnect()
				stickConn = nil
			end
			if stickCollideConn then
				stickCollideConn:Disconnect()
				stickCollideConn = nil
			end
			RestoreStickCollide()
			currentTarget = nil
			RefreshChosenList()
			UpdateStatus()
		end

		StartStick = function()
			if stickConn then
				stickConn:Disconnect()
			end
			if stickCollideConn then
				stickCollideConn:Disconnect()
			end
			stickSwitchAt = tick() + stickDuration
			stickConn = RunService.Heartbeat:Connect(StickStep)
			stickCollideConn = RunService.Stepped:Connect(function()
				local char = LocalPlayer.Character
				if char and currentTarget then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							if stickOriginal[part] == nil then
								stickOriginal[part] = part.CanCollide
							end
							if part.CanCollide then
								part.CanCollide = false
							end
						end
					end
				end
			end)
			RefreshChosenList()
			UpdateStatus()
		end

		Players.PlayerAdded:Connect(function(p)
			joinTimes[p] = tick()
			RefreshAll()
		end)
		Players.PlayerRemoving:Connect(function(p)
			joinTimes[p] = nil
			local idx = table.find(chosenList, p)
			if idx then
				table.remove(chosenList, idx)
			end
			if currentTarget == p then
				currentTarget = nil
			end
			task.delay(0.2, RefreshAll)
		end)

		task.spawn(function()
			while true do
				local now = tick()
				local count, newest = 0, 0
				for p, t in pairs(joinTimes) do
					if p.Parent and now - t < NEW_JOIN_WINDOW then
						count = count + 1
						if t > newest then
							newest = t
						end
					end
				end
				if count > 0 then
					newLabel.Text = string.format(
						T("Người mới vào: %d  •  đặt lại sau %ds"),
						count, math.ceil(NEW_JOIN_WINDOW - (now - newest))
					)
					newLabel.TextColor3 = Theme.On
				else
					newLabel.Text = T("Người mới vào: 0")
					newLabel.TextColor3 = Theme.Sub
				end
				if tPlayers.Visible and menuOpen then
					UpdateServerRows()
					if ComputeSignature() ~= chosenSignature then
						RefreshChosenList()
						UpdateStatus()
					end
					UpdateChosenInfo()
				end
				task.wait(Perf.saver and 1.5 or 0.6)
			end
		end)
		RefreshAll()
	end

	do
		Section(tSystem, "Ngôn ngữ")
		local langRow = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = Next()
		}, tSystem)
		New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, langRow)
		local langButtons = {}
		local function RefreshLangButtons()
			for code, b in pairs(langButtons) do
				Tween(b, 0.15, { BackgroundColor3 = code == Lang.code and Theme.Accent or Theme.Card })
			end
		end
		for _, item in ipairs({ { "vi", "Tiếng Việt" }, { "en", "English" }, { "ko", "한국어" } }) do
			local b = New("TextButton", {
				Size = UDim2.new(1 / 3, -4, 1, 0),
				BackgroundColor3 = item[1] == Lang.code and Theme.Accent or Theme.Card,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = item[2],
				TextColor3 = Theme.Text,
				TextSize = 11
			}, langRow)
			Corner(b, 10)
			langButtons[item[1]] = b
			b.MouseButton1Click:Connect(function()
				Lang.code = item[1]
				ApplyLang()
				RefreshLangButtons()
			end)
		end

		Section(tSystem, "Mát máy & tiết kiệm pin")
		local saverFpsCap = 30
		local saverActive = false
		local saverTouched = setmetatable({}, { __mode = "k" })
		local saverOrig = nil
		local saverConns = {}

		local function SaverKill(obj)
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire")
				or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("PostEffect") then
				if saverTouched[obj] == nil then
					saverTouched[obj] = obj.Enabled
				end
				obj.Enabled = false
			end
		end

		local function SaverSetFps(n)
			if setfpscap then
				pcall(setfpscap, n)
			end
		end

		local function SaverOn()
			if saverActive then
				return
			end
			saverActive = true
			local origFps = 60
			if getfpscap then
				local ok, v = pcall(getfpscap)
				if ok and tonumber(v) then
					origFps = v
				end
			end
			local okQ, quality = pcall(function() return settings().Rendering.QualityLevel end)
			local terrain = Workspace:FindFirstChildOfClass("Terrain")
			saverOrig = {
				quality = okQ and quality or nil,
				shadows = Lighting.GlobalShadows,
				fps = origFps,
				decoration = terrain and terrain.Decoration
			}
			pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			Lighting.GlobalShadows = false
			if terrain then
				pcall(function() terrain.Decoration = false end)
			end
			SaverSetFps(saverFpsCap)
			Perf.espInterval = 0.4
			Perf.saver = true
			if Perf.iconPulse then
				Perf.iconPulse:Pause()
			end
			for _, obj in ipairs(Lighting:GetChildren()) do
				SaverKill(obj)
			end
			saverConns[1] = Workspace.DescendantAdded:Connect(SaverKill)
			saverConns[2] = Lighting.ChildAdded:Connect(SaverKill)
			task.spawn(function()
				local n = 0
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if not saverActive then
						return
					end
					SaverKill(obj)
					n = n + 1
					if n % 400 == 0 then
						task.wait()
					end
				end
			end)
		end

		local function SaverOff()
			if not saverActive then
				return
			end
			saverActive = false
			for _, conn in ipairs(saverConns) do
				conn:Disconnect()
			end
			saverConns = {}
			for obj, was in pairs(saverTouched) do
				if obj.Parent and was then
					obj.Enabled = true
				end
				saverTouched[obj] = nil
			end
			if saverOrig then
				if saverOrig.quality then
					pcall(function() settings().Rendering.QualityLevel = saverOrig.quality end)
				end
				Lighting.GlobalShadows = saverOrig.shadows
				local terrain = Workspace:FindFirstChildOfClass("Terrain")
				if terrain and saverOrig.decoration ~= nil then
					pcall(function() terrain.Decoration = saverOrig.decoration end)
				end
				SaverSetFps(saverOrig.fps)
			end
			Perf.espInterval = 0.12
			Perf.saver = false
			if Perf.iconPulse then
				Perf.iconPulse:Play()
			end
		end

		Toggle(tSystem, "Chế độ mát máy & tiết kiệm pin", false, function(v)
			if v then SaverOn() else SaverOff() end
		end, "Giảm đồ họa, tắt hiệu ứng, hạ FPS")
		Slider(tSystem, "Giới hạn FPS khi tiết kiệm", 10, 60, 30, 5, function(v)
			saverFpsCap = v
			if saverActive then
				SaverSetFps(v)
			end
		end)

		Section(tSystem, "Chất lượng đồ họa")
		local statusLabel = Note(tSystem, "Preset hiện tại: Thường", Theme.Sub)
		local presets = {
			{ "Mượt (FPS Boost)", function()
				pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
				Lighting.GlobalShadows = false
				for _, v in ipairs(Workspace:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Material = Enum.Material.SmoothPlastic
						v.CastShadow = false
					elseif v:IsA("Decal") or v:IsA("Texture") then
						v.Transparency = 1
					end
				end
			end },
			{ "Đẹp", function()
				pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level10 end)
				Lighting.GlobalShadows = true
			end },
			{ "Ultra High", function()
				pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
				Lighting.GlobalShadows = true
			end }
		}
		for _, preset in ipairs(presets) do
			Button(tSystem, preset[1], function()
				pcall(preset[2])
				Reg(statusLabel, function() return T("Preset hiện tại: ") .. T(preset[1]) end)
			end)
		end

		Section(tSystem, "Góc nhìn")
		Slider(tSystem, "Góc nhìn FOV", 30, 120, math.clamp(math.floor(Workspace.CurrentCamera.FieldOfView + 0.5), 30, 120), 1, function(v)
			Workspace.CurrentCamera.FieldOfView = v
		end)

		Section(tSystem, "Thông tin hiển thị")
		local hudLabel, hudConn = nil, nil
		Toggle(tSystem, "Hiện bảng Ping & FPS", false, function(v)
			if hudConn then
				hudConn:Disconnect()
				hudConn = nil
			end
			if hudLabel then
				hudLabel:Destroy()
				hudLabel = nil
			end
			if v then
				hudLabel = New("TextLabel", {
					Position = UDim2.new(0.5, -95, 0, 10),
					Size = UDim2.fromOffset(190, 30),
					BackgroundColor3 = Theme.Panel,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamBold,
					Text = "? ms  •  ? FPS",
					TextColor3 = Theme.Text,
					TextSize = 11,
					Active = true
				}, FloatGui)
				Corner(hudLabel, 10)
				Stroke(hudLabel, Theme.Accent, 1.2, 0.3)
				MakeDraggable(hudLabel, hudLabel)
				local acc, frames = 0, 0
				hudConn = RunService.Heartbeat:Connect(function(dt)
					acc = acc + dt
					frames = frames + 1
					if acc >= 0.5 then
						local okPing, pingVal = pcall(function()
							return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
						end)
						local ping = okPing and math.floor(pingVal) or 0
						local fps = math.floor(frames / acc)
						acc, frames = 0, 0
						hudLabel.Text = string.format("%d ms  •  %d FPS", ping, fps)
						hudLabel.TextColor3 = ping < 80 and Theme.On or (ping < 150 and Theme.Gold or Theme.Red)
					end
				end)
			end
		end)

		local onlineFrame, onlineConns, onlinePulse = nil, {}, nil
		local function DestroyOnline()
			for _, conn in ipairs(onlineConns) do
				conn:Disconnect()
			end
			onlineConns = {}
			if onlinePulse then
				pcall(function() onlinePulse:Cancel() end)
				onlinePulse = nil
			end
			if onlineFrame then
				onlineFrame:Destroy()
				onlineFrame = nil
			end
		end
		Toggle(tSystem, "Hiện số người online", true, function(v)
			DestroyOnline()
			if not v then
				return
			end
			local frame = New("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 10),
				Size = UDim2.fromOffset(132, 40),
				BackgroundColor3 = Theme.Panel,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				Active = true
			}, FloatGui)
			onlineFrame = frame
			Corner(frame, 12)
			Stroke(frame, Theme.Accent, 1.2, 0.35)
			New("UIGradient", {
				Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 180, 235)),
				Rotation = 90
			}, frame)
			local dot = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 11, 0.5, -3),
				Size = UDim2.fromOffset(9, 9),
				BackgroundColor3 = Theme.On,
				BorderSizePixel = 0
			}, frame)
			Corner(dot, 5)
			local dotStroke = Stroke(dot, Theme.On, 3, 0.5)
			onlinePulse = TweenService:Create(
				dotStroke,
				TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Transparency = 1, Thickness = 6 }
			)
			onlinePulse:Play()
			New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(28, 4),
				Size = UDim2.new(1, -36, 0, 10),
				Font = Enum.Font.GothamBold,
				Text = "ONLINE",
				TextColor3 = Theme.Sub,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left
			}, frame)
			local countLabel = New("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(28, 13),
				Size = UDim2.new(1, -36, 0, 18),
				Font = Enum.Font.GothamBlack,
				Text = "",
				TextColor3 = Theme.Text,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left
			}, frame)
			local track = New("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 12, 1, -5),
				Size = UDim2.new(1, -24, 0, 3),
				BackgroundColor3 = Theme.Off,
				BorderSizePixel = 0
			}, frame)
			Corner(track, 2)
			local fill = New("Frame", {
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			}, track)
			Corner(fill, 2)
			New("UIGradient", { Color = ColorSequence.new(Theme.On, Theme.Cyan) }, fill)
			local lastCount = -1
			local function Refresh()
				if not frame.Parent then
					return
				end
				local count = #Players:GetPlayers()
				local maxPlayers = math.max(Players.MaxPlayers, 1)
				countLabel.Text = string.format("%d / %d", count, maxPlayers)
				Tween(fill, 0.35, { Size = UDim2.fromScale(math.clamp(count / maxPlayers, 0, 1), 1) }, Enum.EasingStyle.Quint)
				if lastCount >= 0 and count ~= lastCount then
					countLabel.TextColor3 = count > lastCount and Theme.On or Theme.Red
					Tween(countLabel, 0.8, { TextColor3 = Theme.Text })
				end
				lastCount = count
			end
			Refresh()
			onlineConns[1] = Players.PlayerAdded:Connect(function() task.defer(Refresh) end)
			onlineConns[2] = Players.PlayerRemoving:Connect(function() task.delay(0.1, Refresh) end)
			task.spawn(function()
				while frame.Parent do
					task.wait(10)
					Refresh()
				end
			end)
			MakeDraggable(frame, frame)
		end)
	end

	local function BuildClock()
		local ContextActionService = game:GetService("ContextActionService")
		local HttpService = game:GetService("HttpService")

		local WATER_EVERY = 1800
		local PLAY_LIMIT = 7200
		local BREAK_LENGTH = 1800
		local CONFIRM_DELAY = 5
		local MAX_ALARMS = 8
		local BREAK_FILE = "SieuToc_break.txt"
		local ALARM_FILE = "SieuToc_alarms.json"

		local MEALS = {
			{ h = 7, title = "Đến giờ ăn cơm sáng", short = "Sáng" },
			{ h = 12, title = "Đến giờ ăn cơm trưa", short = "Trưa" },
			{ h = 19, title = "Đến giờ ăn cơm tối", short = "Tối" }
		}

		local DAY_NAMES = {
			vi = { "Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy" },
			en = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" },
			ko = { "일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일" }
		}

		local startedAt = os.time()
		local lastBreakEnd = startedAt
		local nextWater = startedAt + WATER_EVERY
		local breakUntil = 0
		local waterPending = false
		local firedMeals = {}
		local queue = {}
		local current = nil
		local rings = {}
		local alarms = {}
		local snoozes = {}

		local function FormatHMS(sec)
			sec = math.max(0, math.floor(sec))
			return string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
		end

		local function Hour12(h)
			local hh = h % 12
			if hh == 0 then
				hh = 12
			end
			return hh
		end

		local function ClockHM(h, m)
			if Lang.code == "en" then
				return string.format("%d:%02d %s", Hour12(h), m, h >= 12 and "PM" or "AM")
			elseif Lang.code == "ko" then
				return string.format("%s %d:%02d", h >= 12 and "오후" or "오전", Hour12(h), m)
			end
			return string.format("%02d:%02d", h, m)
		end

		local function ClockHMS(h, m, s)
			if Lang.code == "en" then
				return string.format("%d:%02d:%02d %s", Hour12(h), m, s, h >= 12 and "PM" or "AM")
			elseif Lang.code == "ko" then
				return string.format("%s %d:%02d:%02d", h >= 12 and "오후" or "오전", Hour12(h), m, s)
			end
			return string.format("%02d:%02d:%02d", h, m, s)
		end

		local function DateText(t)
			local names = DAY_NAMES[Lang.code] or DAY_NAMES.vi
			if Lang.code == "en" then
				return string.format("%s, %02d/%02d/%d", names[t.wday], t.month, t.day, t.year)
			elseif Lang.code == "ko" then
				return string.format("%d년 %d월 %d일 %s", t.year, t.month, t.day, names[t.wday])
			end
			return string.format("%s, %02d/%02d/%d", names[t.wday], t.day, t.month, t.year)
		end

		local function FileWrite(name, content)
			if writefile then
				pcall(writefile, name, content)
			end
		end

		local function FileRead(name)
			if isfile and readfile then
				local ok, data = pcall(function()
					if isfile(name) then
						return readfile(name)
					end
					return nil
				end)
				if ok then
					return data
				end
			end
			return nil
		end

		local HealthGui = New("ScreenGui", {
			Name = "SieuToc_Health",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 1000,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, GuiParent)

		local Shield = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Active = true,
			Modal = true,
			Visible = false,
			ZIndex = 1
		}, HealthGui)
		New("UIGradient", {
			Color = ColorSequence.new(Color3.fromRGB(8, 10, 22), Color3.fromRGB(38, 24, 82)),
			Rotation = 90
		}, Shield)

		local Card = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(360, 330),
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Active = true
		}, Shield)
		Corner(Card, 20)
		local cardStroke = Stroke(Card, Theme.Cyan, 2, 0.2)
		local cardScale = New("UIScale", { Scale = 1 }, Card)
		local topBar = New("Frame", {
			Position = UDim2.fromOffset(20, 0),
			Size = UDim2.new(1, -40, 0, 4),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0
		}, Card)
		Corner(topBar, 2)
		New("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Cyan) }, topBar)

		local art = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 16),
			Size = UDim2.fromOffset(120, 92),
			BackgroundTransparency = 1
		}, Card)

		local titleLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 112),
			Size = UDim2.new(1, -32, 0, 44),
			Font = Enum.Font.GothamBlack,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 18,
			TextWrapped = true
		}, Card)
		Reg(titleLabel, function()
			return current and T(current.title) or ""
		end)

		local bodyLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 158),
			Size = UDim2.new(1, -40, 0, 54),
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Theme.Sub,
			TextSize = 12,
			TextWrapped = true
		}, Card)
		Reg(bodyLabel, function()
			return current and T(current.body) or ""
		end)

		local captionLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 214),
			Size = UDim2.new(1, -32, 0, 14),
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Theme.Sub,
			TextSize = 10
		}, Card)

		local infoLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 228),
			Size = UDim2.new(1, -32, 0, 36),
			Font = Enum.Font.GothamBlack,
			Text = "",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 28
		}, Card)
		New("UIGradient", { Color = ColorSequence.new(Theme.Cyan, Theme.Accent) }, infoLabel)

		local confirmBtn = New("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 274),
			Size = UDim2.new(1, -48, 0, 44),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Sub,
			TextSize = 14,
			TextWrapped = true
		}, Card)
		Corner(confirmBtn, 12)

		local loops = {}
		local function Loop(obj, seconds, props, delay)
			local tween = TweenService:Create(
				obj,
				TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, delay or 0),
				props
			)
			tween:Play()
			loops[#loops + 1] = tween
			return tween
		end

		local function StopLoops()
			for _, tween in ipairs(loops) do
				pcall(function() tween:Cancel() end)
			end
			loops = {}
		end

		local function ClearArt()
			StopLoops()
			for _, child in ipairs(art:GetChildren()) do
				child:Destroy()
			end
		end

		local function BuildArt(kind)
			ClearArt()
			if kind == "water" then
				local glass = New("CanvasGroup", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(54, 78),
					BackgroundColor3 = Theme.Bg,
					BorderSizePixel = 0
				}, art)
				Corner(glass, 12)
				Stroke(glass, Theme.Cyan, 2.5, 0)
				local water = New("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(1, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0
				}, glass)
				New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(125, 211, 252), Theme.Blue), Rotation = 90 }, water)
				Loop(water, 1.4, { Size = UDim2.fromScale(1, 0.82) })
				for i = 1, 3 do
					local bubble = New("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.25 * i, 0, 0.9, 0),
						Size = UDim2.fromOffset(6, 6),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 0.3,
						BorderSizePixel = 0
					}, glass)
					Corner(bubble, 3)
					Loop(bubble, 0.9 + i * 0.25, { Position = UDim2.new(0.25 * i, 0, 0.3, 0), BackgroundTransparency = 0.95 }, i * 0.15)
				end
			elseif kind == "meal" then
				local plate = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0, 58),
					Size = UDim2.fromOffset(72, 72),
					BackgroundColor3 = Theme.Card,
					BorderSizePixel = 0
				}, art)
				Corner(plate, 36)
				Stroke(plate, Theme.Gold, 2.5, 0)
				local inner = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(48, 48),
					BackgroundColor3 = Theme.Gold,
					BackgroundTransparency = 0.15,
					BorderSizePixel = 0
				}, plate)
				Corner(inner, 24)
				for i = 1, 3 do
					local steam = New("Frame", {
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.new(0.5, (i - 2) * 14, 0, 20),
						Size = UDim2.fromOffset(4, 16),
						BackgroundColor3 = Theme.Text,
						BackgroundTransparency = 0.75,
						BorderSizePixel = 0
					}, art)
					Corner(steam, 2)
					Loop(steam, 0.8 + i * 0.15, { BackgroundTransparency = 0.1, Position = UDim2.new(0.5, (i - 2) * 14, 0, 12) }, i * 0.2)
				end
			else
				local moon = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.45, 0.5),
					Size = UDim2.fromOffset(66, 66),
					BackgroundColor3 = Theme.Gold,
					BorderSizePixel = 0
				}, art)
				Corner(moon, 33)
				local mask = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.45, 18, 0.5, -10),
					Size = UDim2.fromOffset(56, 56),
					BackgroundColor3 = Theme.Panel,
					BorderSizePixel = 0
				}, art)
				Corner(mask, 28)
				local stars = { { 0.86, 0.18 }, { 0.94, 0.62 }, { 0.12, 0.14 } }
				for i, pos in ipairs(stars) do
					local star = New("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(pos[1], pos[2]),
						Size = UDim2.fromOffset(6, 6),
						BackgroundColor3 = Theme.Text,
						BorderSizePixel = 0
					}, art)
					Corner(star, 3)
					Loop(star, 0.7 + i * 0.2, { BackgroundTransparency = 0.85 }, i * 0.25)
				end
			end
		end

		local function BlockInput()
			pcall(function()
				ContextActionService:BindActionAtPriority(
					"SieuTocHealthBlock",
					function()
						return Enum.ContextActionResult.Sink
					end,
					false,
					3000,
					Enum.UserInputType.Keyboard,
					Enum.UserInputType.MouseButton1,
					Enum.UserInputType.MouseButton2,
					Enum.UserInputType.MouseWheel,
					Enum.UserInputType.Touch,
					Enum.UserInputType.Gamepad1
				)
			end)
		end

		local function UnblockInput()
			pcall(function()
				ContextActionService:UnbindAction("SieuTocHealthBlock")
			end)
		end

		local function FitScale()
			local view = Workspace.CurrentCamera.ViewportSize
			return math.clamp(math.min((view.X - 20) / 360, (view.Y - 20) / 330), 0.45, 1.15)
		end

		local cardPulse = nil

		local function Enqueue(ev, front)
			if current and current.id == ev.id then
				return
			end
			for _, queued in ipairs(queue) do
				if queued.id == ev.id then
					return
				end
			end
			if front then
				table.insert(queue, 1, ev)
			else
				queue[#queue + 1] = ev
			end
		end

		local function ShowEvent(ev)
			current = ev
			ev.shownAt = os.time()
			local target = FitScale()
			BuildArt(ev.art)
			titleLabel.Text = T(ev.title)
			bodyLabel.Text = T(ev.body)
			Shield.BackgroundTransparency = 1
			Shield.Visible = true
			Tween(Shield, 0.35, { BackgroundTransparency = 0.04 })
			cardScale.Scale = target * 0.85
			Tween(cardScale, 0.35, { Scale = target }, Enum.EasingStyle.Back)
			if cardPulse then
				pcall(function() cardPulse:Cancel() end)
			end
			cardPulse = Loop(cardStroke, 1.1, { Transparency = 0.75 })
			BlockInput()
		end

		local function Pump()
			if not current and #queue > 0 then
				ShowEvent(table.remove(queue, 1))
			end
		end

		local function CloseEvent()
			local ev = current
			if not ev then
				return
			end
			current = nil
			UnblockInput()
			ClearArt()
			cardPulse = nil
			cardStroke.Transparency = 0.2
			Shield.Visible = false
			pcall(ev.onConfirm)
			Pump()
		end

		confirmBtn.MouseButton1Click:Connect(function()
			local ev = current
			if not ev then
				return
			end
			local ready
			if ev.kind == "break" then
				ready = os.time() >= breakUntil
			else
				ready = os.time() >= ev.shownAt + CONFIRM_DELAY
			end
			if ready then
				CloseEvent()
			end
		end)

		local function WaterEvent()
			return {
				id = "water",
				kind = "water",
				art = "water",
				title = "Đến giờ uống nước mát",
				body = "Hãy đứng dậy uống một cốc nước mát để giữ cơ thể khỏe mạnh. Uống xong hãy bấm xác nhận.",
				button = "Tôi đã uống nước xong",
				onConfirm = function()
					waterPending = false
					nextWater = os.time() + WATER_EVERY
				end
			}
		end

		local function MealEvent(meal, key)
			return {
				id = "meal" .. key,
				kind = "meal",
				art = "meal",
				title = meal.title,
				body = "Hãy tạm dừng game và đi ăn cơm ngay. Ăn xong hãy bấm xác nhận.",
				button = "Tôi đã ăn cơm xong",
				onConfirm = function() end
			}
		end

		local function BreakEvent()
			return {
				id = "break",
				kind = "break",
				art = "break",
				title = "Đã đến lúc tạm nghỉ 30 phút",
				body = "Bạn đã chơi liên tục 2 tiếng. Hãy rời màn hình, đi lại và cho mắt nghỉ ngơi.",
				button = "Tiếp tục chơi",
				onConfirm = function()
					breakUntil = 0
					FileWrite(BREAK_FILE, "0")
					lastBreakEnd = os.time()
					nextWater = os.time() + WATER_EVERY
					waterPending = false
					for i = #queue, 1, -1 do
						if queue[i].kind == "water" then
							table.remove(queue, i)
						end
					end
				end
			}
		end

		local savedBreak = tonumber(FileRead(BREAK_FILE) or "0") or 0
		if savedBreak > os.time() then
			breakUntil = math.min(savedBreak, os.time() + BREAK_LENGTH)
			Enqueue(BreakEvent(), true)
		end

		local Banner = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 16),
			Size = UDim2.fromOffset(310, 124),
			BackgroundColor3 = Theme.Panel,
			BorderSizePixel = 0,
			Visible = false,
			Active = true,
			ZIndex = 20
		}, HealthGui)
		Corner(Banner, 16)
		local bannerStroke = Stroke(Banner, Theme.Gold, 2, 0)
		local bannerScale = New("UIScale", { Scale = 1 }, Banner)
		local bannerTitle = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.new(1, -28, 0, 22),
			Font = Enum.Font.GothamBlack,
			Text = "",
			TextColor3 = Theme.Gold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left
		}, Banner)
		local bannerText = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 32),
			Size = UDim2.new(1, -28, 0, 34),
			Font = Enum.Font.GothamBlack,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 26,
			TextXAlignment = Enum.TextXAlignment.Left
		}, Banner)
		local bannerRow = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 74),
			Size = UDim2.new(1, -28, 0, 38)
		}, Banner)
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, bannerRow)
		local dismissBtn = New("TextButton", {
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 12,
			LayoutOrder = 2
		}, bannerRow)
		Corner(dismissBtn, 10)
		local snoozeBtn = New("TextButton", {
			Size = UDim2.new(0.5, -4, 1, 0),
			BackgroundColor3 = Theme.CardHover,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBold,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 12,
			LayoutOrder = 1
		}, bannerRow)
		Corner(snoozeBtn, 10)

		local ringSound = New("Sound", {
			Name = "SieuToc_Ring",
			SoundId = "rbxasset://sounds/electronicpingshort.wav",
			Volume = 1,
			Looped = true
		}, HealthGui)
		local bannerLoop = nil

		local function RefreshBanner()
			local ring = rings[1]
			if not ring then
				return
			end
			local view = Workspace.CurrentCamera.ViewportSize
			bannerScale.Scale = math.clamp((view.X - 16) / 310, 0.5, 1.1)
			bannerTitle.Text = T(ring.title)
			bannerText.Text = ring.text()
			dismissBtn.Text = T(ring.dismiss)
			snoozeBtn.Text = T("Báo lại 5 phút")
			snoozeBtn.Visible = ring.snooze == true
			dismissBtn.Size = ring.snooze and UDim2.new(0.5, -4, 1, 0) or UDim2.new(1, 0, 1, 0)
		end

		local function PushRing(ring)
			rings[#rings + 1] = ring
			if #rings == 1 then
				Banner.Visible = true
				bannerLoop = TweenService:Create(
					bannerStroke,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Transparency = 0.8 }
				)
				bannerLoop:Play()
				pcall(function() ringSound:Play() end)
			end
			RefreshBanner()
		end

		local function PopRing()
			table.remove(rings, 1)
			if #rings == 0 then
				Banner.Visible = false
				pcall(function() ringSound:Stop() end)
				if bannerLoop then
					pcall(function() bannerLoop:Cancel() end)
					bannerLoop = nil
				end
				bannerStroke.Transparency = 0
			else
				RefreshBanner()
			end
		end

		dismissBtn.MouseButton1Click:Connect(PopRing)
		snoozeBtn.MouseButton1Click:Connect(function()
			local ring = rings[1]
			if ring and ring.onSnooze then
				ring.onSnooze()
			end
			PopRing()
		end)

		local function RingAlarm(a)
			PushRing({
				title = "Báo thức",
				dismiss = "Tắt báo thức",
				snooze = true,
				text = function() return ClockHM(a.h, a.m) end,
				onSnooze = function()
					snoozes[#snoozes + 1] = { at = os.time() + 300, a = a }
				end
			})
		end

		local function SaveAlarms()
			local data = {}
			for _, a in ipairs(alarms) do
				data[#data + 1] = { h = a.h, m = a.m, daily = a.daily, on = a.on }
			end
			local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
			if ok then
				FileWrite(ALARM_FILE, encoded)
			end
		end

		local rawAlarms = FileRead(ALARM_FILE)
		if rawAlarms then
			local ok, data = pcall(function() return HttpService:JSONDecode(rawAlarms) end)
			if ok and type(data) == "table" then
				for _, a in ipairs(data) do
					if type(a.h) == "number" and type(a.m) == "number" then
						alarms[#alarms + 1] = { h = a.h, m = a.m, daily = a.daily == true, on = a.on == true, last = "" }
					end
				end
			end
		end

		local function HoldButton(btn, fn)
			local token = 0
			btn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					token = token + 1
					local id = token
					fn()
					task.delay(0.4, function()
						while token == id and btn.Parent do
							fn()
							task.wait(0.08)
						end
					end)
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							token = token + 1
						end
					end)
				end
			end)
		end

		local function Panel(parent, height)
			local panel = New("Frame", {
				Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				LayoutOrder = Next()
			}, parent)
			Corner(panel, 12)
			return panel
		end

		local function Label(parent, props)
			local base = {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Text = ""
			}
			for key, value in pairs(props) do
				base[key] = value
			end
			return New("TextLabel", base, parent)
		end

		local function Action(parent, text, color, size, onClick)
			local btn = New("TextButton", {
				Size = size,
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 12,
				TextWrapped = true
			}, parent)
			Corner(btn, 10)
			btn.MouseEnter:Connect(function() Tween(btn, 0.12, { BackgroundTransparency = 0.2 }) end)
			btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundTransparency = 0 }) end)
			btn.MouseButton1Click:Connect(onClick)
			return btn
		end

		local function Row(parent, height, gap)
			local row = New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, height),
				LayoutOrder = Next()
			}, parent)
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, gap or 6),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, row)
			return row
		end

		local function Pill(parent, state, onChange, locked)
			local pill = New("TextButton", {
				Size = UDim2.fromOffset(38, 20),
				BackgroundColor3 = state and Theme.On or Theme.Off,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Active = not locked,
				Text = ""
			}, parent)
			Corner(pill, 10)
			local knob = New("Frame", {
				Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			}, pill)
			Corner(knob, 8)
			local value = state
			local function Set(v)
				value = v
				Tween(pill, 0.18, { BackgroundColor3 = v and Theme.On or Theme.Off })
				Tween(knob, 0.18, { Position = v and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
			end
			if not locked then
				pill.MouseButton1Click:Connect(function()
					Set(not value)
					if onChange then
						onChange(value)
					end
				end)
			end
			return { Button = pill, Set = Set, Get = function() return value end }
		end

		local function Stepper(parent, labelKey, minV, maxV, start, wrap, count, onChange)
			local val = start
			local box = New("Frame", {
				Size = UDim2.new(1 / count, -4, 1, 0),
				BackgroundColor3 = Theme.Bg,
				BorderSizePixel = 0
			}, parent)
			Corner(box, 10)
			Stroke(box, Theme.Accent, 1, 0.7)
			Label(box, {
				Position = UDim2.fromOffset(0, 4),
				Size = UDim2.new(1, 0, 0, 12),
				Text = labelKey,
				TextColor3 = Theme.Sub,
				TextSize = 10
			})
			local up = New("TextButton", {
				Position = UDim2.new(0.5, -20, 0, 18),
				Size = UDim2.fromOffset(40, 20),
				BackgroundColor3 = Theme.CardHover,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = "+",
				TextColor3 = Theme.Text,
				TextSize = 14
			}, box)
			Corner(up, 8)
			local field = New("TextBox", {
				Position = UDim2.fromOffset(6, 40),
				Size = UDim2.new(1, -12, 0, 26),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Text = "",
				TextColor3 = Theme.Cyan,
				TextSize = 22,
				ClearTextOnFocus = false
			}, box)
			local down = New("TextButton", {
				Position = UDim2.new(0.5, -20, 0, 68),
				Size = UDim2.fromOffset(40, 20),
				BackgroundColor3 = Theme.CardHover,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = "-",
				TextColor3 = Theme.Text,
				TextSize = 14
			}, box)
			Corner(down, 8)
			local function set(n, fire)
				n = math.floor(n)
				if wrap then
					n = (n - minV) % (maxV - minV + 1) + minV
				else
					n = math.clamp(n, minV, maxV)
				end
				val = n
				field.Text = string.format("%02d", n)
				if fire and onChange then
					onChange(n)
				end
			end
			set(start, false)
			HoldButton(up, function() set(val + 1, true) end)
			HoldButton(down, function() set(val - 1, true) end)
			field.FocusLost:Connect(function()
				local n = tonumber(string.match(field.Text, "%d+"))
				if n then
					set(n, true)
				else
					set(val, false)
				end
			end)
			return { Set = set, Get = function() return val end }
		end

		local function Bar(parent, y, height)
			local track = New("Frame", {
				Position = UDim2.new(0, 12, 0, y),
				Size = UDim2.new(1, -24, 0, height or 6),
				BackgroundColor3 = Theme.Off,
				BorderSizePixel = 0
			}, parent)
			Corner(track, 3)
			local fill = New("Frame", {
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			}, track)
			Corner(fill, 3)
			New("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Cyan) }, fill)
			return function(ratio)
				fill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
			end
		end

		local function Pane()
			local pane = New("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = Next(),
				Visible = false
			}, tClock)
			New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, pane)
			return pane
		end

		local subTitles = { "Đồng hồ", "Báo thức", "Bộ đếm", "Bấm giờ", "Sức khỏe" }
		local selector = Row(tClock, 32, 4)
		local subButtons = {}
		local panes = {}
		for index, title in ipairs(subTitles) do
			subButtons[index] = New("TextButton", {
				Size = UDim2.new(0.2, -4, 1, 0),
				BackgroundColor3 = Theme.Card,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamBold,
				Text = title,
				TextColor3 = Theme.Text,
				TextSize = 10,
				TextWrapped = true,
				LayoutOrder = index
			}, selector)
			Corner(subButtons[index], 9)
			panes[index] = Pane()
		end
		local paneClock, paneAlarm, paneTimer, paneStop, paneHealth = panes[1], panes[2], panes[3], panes[4], panes[5]

		local function SelectSub(i)
			for index, pane in ipairs(panes) do
				pane.Visible = index == i
				Tween(subButtons[index], 0.15, { BackgroundColor3 = index == i and Theme.Accent or Theme.Card })
			end
		end
		for index, btn in ipairs(subButtons) do
			btn.MouseButton1Click:Connect(function()
				SelectSub(index)
			end)
		end

		local hero = Panel(paneClock, 196)
		New("UIGradient", { Color = ColorSequence.new(Theme.Panel, Color3.fromRGB(40, 28, 92)), Rotation = 45 }, hero)
		Stroke(hero, Theme.Accent, 1.5, 0.45)
		hero.BackgroundColor3 = Color3.new(1, 1, 1)
		local face = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 10),
			Size = UDim2.fromOffset(116, 116),
			BackgroundColor3 = Theme.Bg,
			BorderSizePixel = 0
		}, hero)
		Corner(face, 58)
		Stroke(face, Theme.Cyan, 2, 0.15)
		for i = 0, 11 do
			local holder = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Rotation = i * 30
			}, face)
			local major = i % 3 == 0
			New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 4),
				Size = UDim2.fromOffset(major and 3 or 2, major and 9 or 5),
				BackgroundColor3 = major and Theme.Text or Theme.Sub,
				BorderSizePixel = 0
			}, holder)
		end
		local function MakeHand(length, width, color, order)
			local holder = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = order
			}, face)
			local hand = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(width, length),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				ZIndex = order
			}, holder)
			Corner(hand, width / 2)
			return holder
		end
		local hourHand = MakeHand(28, 4, Theme.Text, 2)
		local minuteHand = MakeHand(40, 3, Theme.Cyan, 3)
		local secondHand = MakeHand(46, 2, Theme.Red, 4)
		local hub = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(9, 9),
			BackgroundColor3 = Theme.Gold,
			BorderSizePixel = 0,
			ZIndex = 5
		}, face)
		Corner(hub, 5)
		local timeLabel = Label(hero, {
			Position = UDim2.fromOffset(10, 132),
			Size = UDim2.new(1, -20, 0, 34),
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1)
		})
		New("UITextSizeConstraint", { MaxTextSize = 30, MinTextSize = 12 }, timeLabel)
		New("UIGradient", { Color = ColorSequence.new(Theme.Cyan, Theme.Accent) }, timeLabel)
		local dateLabel = Label(hero, {
			Position = UDim2.fromOffset(10, 168),
			Size = UDim2.new(1, -20, 0, 18),
			TextColor3 = Theme.Sub,
			TextSize = 11
		})

		local onlineCard = Panel(paneClock, 96)
		Stroke(onlineCard, Theme.Cyan, 1, 0.6)
		Label(onlineCard, {
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 14),
			Text = "Thời gian online",
			TextColor3 = Theme.Sub,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		local onlineValue = Label(onlineCard, {
			Position = UDim2.fromOffset(12, 22),
			Size = UDim2.new(1, -24, 0, 30),
			Font = Enum.Font.GothamBlack,
			TextColor3 = Theme.Cyan,
			TextSize = 24,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		local playBar = Bar(onlineCard, 62, 6)
		local playLabel = Label(onlineCard, {
			Position = UDim2.fromOffset(12, 72),
			Size = UDim2.new(1, -24, 0, 16),
			TextColor3 = Theme.Sub,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		Section(paneAlarm, "Thêm báo thức")
		local composer = Row(paneAlarm, 94, 4)
		local alarmHour = Stepper(composer, "Giờ", 0, 23, 7, true, 2)
		local alarmMinute = Stepper(composer, "Phút", 0, 59, 0, true, 2)
		local dailyCard = Panel(paneAlarm, 38)
		Label(dailyCard, {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -70, 1, 0),
			Font = Enum.Font.GothamSemibold,
			Text = "Lặp lại hàng ngày",
			TextXAlignment = Enum.TextXAlignment.Left
		})
		local dailyPill = Pill(dailyCard, true)
		dailyPill.Button.AnchorPoint = Vector2.new(1, 0.5)
		dailyPill.Button.Position = UDim2.new(1, -10, 0.5, 0)

		local addRow = Row(paneAlarm, 38, 6)
		local alarmHolder = nil
		local RefreshAlarmList = nil
		local addBtn = nil
		addBtn = Action(addRow, "Thêm báo thức", Theme.Accent, UDim2.new(1, 0, 1, 0), function()
			if #alarms >= MAX_ALARMS then
				addBtn.Text = T("Tối đa 8 báo thức")
				task.delay(1.5, function()
					addBtn.Text = T("Thêm báo thức")
				end)
				return
			end
			alarms[#alarms + 1] = {
				h = alarmHour.Get(),
				m = alarmMinute.Get(),
				daily = dailyPill.Get(),
				on = true,
				last = ""
			}
			table.sort(alarms, function(x, y)
				return x.h * 60 + x.m < y.h * 60 + y.m
			end)
			SaveAlarms()
			RefreshAlarmList()
		end)
		Reg(addBtn, "Thêm báo thức")

		Section(paneAlarm, "Danh sách báo thức")
		alarmHolder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = Next()
		}, paneAlarm)
		New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, alarmHolder)

		RefreshAlarmList = function()
			for _, child in ipairs(alarmHolder:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end
			if #alarms == 0 then
				Label(alarmHolder, {
					Size = UDim2.new(1, 0, 0, 36),
					Text = T("Chưa có báo thức nào"),
					TextColor3 = Theme.Sub
				})
				return
			end
			for index, a in ipairs(alarms) do
				local row = New("Frame", {
					Size = UDim2.new(1, 0, 0, 50),
					BackgroundColor3 = Theme.Card,
					BorderSizePixel = 0,
					LayoutOrder = index
				}, alarmHolder)
				Corner(row, 12)
				local timeText = Label(row, {
					Position = UDim2.fromOffset(12, 5),
					Size = UDim2.new(1, -140, 0, 26),
					Font = Enum.Font.GothamBlack,
					TextSize = 18,
					TextColor3 = a.on and Theme.Cyan or Theme.Sub,
					Text = ClockHM(a.h, a.m),
					TextXAlignment = Enum.TextXAlignment.Left
				})
				Label(row, {
					Position = UDim2.fromOffset(12, 31),
					Size = UDim2.new(1, -140, 0, 14),
					TextSize = 10,
					TextColor3 = Theme.Sub,
					Text = a.daily and T("Hàng ngày") or T("Một lần"),
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local pill = Pill(row, a.on, function(v)
					a.on = v
					timeText.TextColor3 = v and Theme.Cyan or Theme.Sub
					SaveAlarms()
				end)
				pill.Button.AnchorPoint = Vector2.new(1, 0.5)
				pill.Button.Position = UDim2.new(1, -66, 0.5, 0)
				local del = New("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(48, 26),
					BackgroundColor3 = Theme.Red,
					BackgroundTransparency = 0.15,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Font = Enum.Font.GothamBold,
					Text = T("Xóa"),
					TextColor3 = Theme.Text,
					TextSize = 10
				}, row)
				Corner(del, 8)
				del.MouseButton1Click:Connect(function()
					table.remove(alarms, index)
					SaveAlarms()
					RefreshAlarmList()
				end)
			end
		end
		RefreshAlarmList()

		local Tm = { total = 300, remaining = 300, running = false, endAt = 0, paused = false }

		Section(paneTimer, "Bộ đếm giờ")
		local timerCard = Panel(paneTimer, 112)
		New("UIGradient", { Color = ColorSequence.new(Theme.Panel, Color3.fromRGB(40, 28, 92)), Rotation = 45 }, timerCard)
		timerCard.BackgroundColor3 = Color3.new(1, 1, 1)
		Stroke(timerCard, Theme.Accent, 1.5, 0.45)
		local timerState = Label(timerCard, {
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 14),
			TextColor3 = Theme.Sub,
			TextSize = 10
		})
		local timerDisplay = Label(timerCard, {
			Position = UDim2.fromOffset(10, 24),
			Size = UDim2.new(1, -20, 0, 56),
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1)
		})
		New("UITextSizeConstraint", { MaxTextSize = 44, MinTextSize = 14 }, timerDisplay)
		New("UIGradient", { Color = ColorSequence.new(Theme.Cyan, Theme.Accent) }, timerDisplay)
		local timerBar = Bar(timerCard, 92, 8)

		local timerSteppers = Row(paneTimer, 94, 4)
		local tmHour, tmMinute, tmSecond
		local function SyncTimer()
			if not Tm.running then
				Tm.total = tmHour.Get() * 3600 + tmMinute.Get() * 60 + tmSecond.Get()
				Tm.remaining = Tm.total
				Tm.paused = false
			end
		end
		tmHour = Stepper(timerSteppers, "Giờ", 0, 99, 0, false, 3, SyncTimer)
		tmMinute = Stepper(timerSteppers, "Phút", 0, 59, 5, true, 3, SyncTimer)
		tmSecond = Stepper(timerSteppers, "Giây", 0, 59, 0, true, 3, SyncTimer)

		Section(paneTimer, "Cài nhanh")
		local presetRow = Row(paneTimer, 32, 4)
		for _, minutes in ipairs({ 1, 5, 10, 15, 30 }) do
			local chip = Action(presetRow, "", Theme.Card, UDim2.new(0.2, -4, 1, 0), function()
				Tm.running = false
				tmHour.Set(0, false)
				tmMinute.Set(minutes, false)
				tmSecond.Set(0, false)
				Tm.total = minutes * 60
				Tm.remaining = Tm.total
				Tm.paused = false
			end)
			Reg(chip, function()
				return minutes .. " " .. T("phút")
			end)
		end

		local timerActions = Row(paneTimer, 40, 6)
		local timerToggle = Action(timerActions, "Bắt đầu", Theme.On, UDim2.new(0.5, -3, 1, 0), function()
			if Tm.running then
				Tm.remaining = math.max(0, Tm.endAt - os.clock())
				Tm.running = false
				Tm.paused = true
			else
				if Tm.remaining <= 0 then
					return
				end
				Tm.endAt = os.clock() + Tm.remaining
				Tm.running = true
				Tm.paused = false
			end
		end)
		timerToggle.TextColor3 = Color3.fromRGB(8, 30, 20)
		Action(timerActions, "Đặt lại", Theme.CardHover, UDim2.new(0.5, -3, 1, 0), function()
			Tm.running = false
			Tm.paused = false
			Tm.remaining = Tm.total
		end)

		local Sw = { running = false, base = 0, startAt = 0, laps = {} }

		local function SwElapsed()
			return Sw.base + (Sw.running and (os.clock() - Sw.startAt) or 0)
		end

		local function SwFormat(sec)
			local hundredths = math.floor(sec * 100) % 100
			local whole = math.floor(sec)
			if whole >= 3600 then
				return string.format("%d:%02d:%02d.%02d", math.floor(whole / 3600), math.floor((whole % 3600) / 60), whole % 60, hundredths)
			end
			return string.format("%02d:%02d.%02d", math.floor(whole / 60), whole % 60, hundredths)
		end

		Section(paneStop, "Bấm giờ")
		local swCard = Panel(paneStop, 96)
		New("UIGradient", { Color = ColorSequence.new(Theme.Panel, Color3.fromRGB(40, 28, 92)), Rotation = 45 }, swCard)
		swCard.BackgroundColor3 = Color3.new(1, 1, 1)
		Stroke(swCard, Theme.Accent, 1.5, 0.45)
		local swDisplay = Label(swCard, {
			Position = UDim2.fromOffset(10, 14),
			Size = UDim2.new(1, -20, 0, 68),
			Font = Enum.Font.GothamBlack,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1)
		})
		New("UITextSizeConstraint", { MaxTextSize = 44, MinTextSize = 14 }, swDisplay)
		New("UIGradient", { Color = ColorSequence.new(Theme.Cyan, Theme.Accent) }, swDisplay)

		local swActions = Row(paneStop, 40, 6)
		local lapHolder = nil
		local RefreshLaps = nil
		local swToggle = Action(swActions, "Bắt đầu", Theme.On, UDim2.new(1 / 3, -4, 1, 0), function()
			if Sw.running then
				Sw.base = SwElapsed()
				Sw.running = false
			else
				Sw.startAt = os.clock()
				Sw.running = true
			end
		end)
		swToggle.TextColor3 = Color3.fromRGB(8, 30, 20)
		Action(swActions, "Ghi vòng", Theme.Accent, UDim2.new(1 / 3, -4, 1, 0), function()
			local total = SwElapsed()
			if total <= 0 then
				return
			end
			local previous = Sw.laps[1] and Sw.laps[1].total or 0
			table.insert(Sw.laps, 1, { n = #Sw.laps + 1, split = total - previous, total = total })
			if #Sw.laps > 30 then
				table.remove(Sw.laps)
			end
			RefreshLaps()
		end)
		Action(swActions, "Đặt lại", Theme.CardHover, UDim2.new(1 / 3, -4, 1, 0), function()
			Sw.running = false
			Sw.base = 0
			Sw.laps = {}
			RefreshLaps()
		end)

		lapHolder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = Next()
		}, paneStop)
		New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, lapHolder)
		RefreshLaps = function()
			for _, child in ipairs(lapHolder:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end
			if #Sw.laps == 0 then
				Label(lapHolder, {
					Size = UDim2.new(1, 0, 0, 30),
					Text = T("Chưa có vòng nào"),
					TextColor3 = Theme.Sub
				})
				return
			end
			for index, lap in ipairs(Sw.laps) do
				local row = New("Frame", {
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = Theme.Card,
					BorderSizePixel = 0,
					LayoutOrder = index
				}, lapHolder)
				Corner(row, 8)
				Label(row, {
					Position = UDim2.fromOffset(10, 0),
					Size = UDim2.new(0.28, 0, 1, 0),
					Font = Enum.Font.GothamBold,
					Text = string.format(T("Vòng %d"), lap.n),
					TextColor3 = Theme.Sub,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				Label(row, {
					Position = UDim2.new(0.28, 0, 0, 0),
					Size = UDim2.new(0.36, 0, 1, 0),
					Font = Enum.Font.GothamBold,
					Text = SwFormat(lap.split),
					TextColor3 = Theme.Cyan,
					TextSize = 12
				})
				Label(row, {
					Position = UDim2.new(0.64, 0, 0, 0),
					Size = UDim2.new(0.36, -10, 1, 0),
					Text = SwFormat(lap.total),
					TextColor3 = Theme.Text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right
				})
			end
		end
		RefreshLaps()

		Section(paneHealth, "Chăm sóc sức khỏe")
		local statusCard = Panel(paneHealth, 62)
		New("UIGradient", { Color = ColorSequence.new(Theme.Panel, Color3.fromRGB(26, 64, 60)), Rotation = 45 }, statusCard)
		statusCard.BackgroundColor3 = Color3.new(1, 1, 1)
		Stroke(statusCard, Theme.On, 1.5, 0.4)
		Label(statusCard, {
			Position = UDim2.fromOffset(12, 10),
			Size = UDim2.new(1, -70, 0, 20),
			Font = Enum.Font.GothamBlack,
			TextSize = 14,
			Text = "Chăm sóc sức khỏe",
			TextXAlignment = Enum.TextXAlignment.Left
		})
		Label(statusCard, {
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -70, 0, 20),
			Text = "Luôn bật  •  Không thể tắt",
			TextColor3 = Theme.On,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		})
		local lockPill = Pill(statusCard, true, nil, true)
		lockPill.Button.AnchorPoint = Vector2.new(1, 0.5)
		lockPill.Button.Position = UDim2.new(1, -12, 0.5, 0)

		local waterCard = Panel(paneHealth, 66)
		Label(waterCard, {
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -90, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "Uống nước mát",
			TextXAlignment = Enum.TextXAlignment.Left
		})
		Label(waterCard, {
			Position = UDim2.fromOffset(12, 26),
			Size = UDim2.new(1, -90, 0, 14),
			Text = "Nhắc uống nước mỗi 30 phút",
			TextColor3 = Theme.Sub,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		})
		local waterTime = Label(waterCard, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 10),
			Size = UDim2.fromOffset(76, 24),
			Font = Enum.Font.GothamBlack,
			TextSize = 16,
			TextColor3 = Theme.Cyan,
			TextXAlignment = Enum.TextXAlignment.Right
		})
		local waterBar = Bar(waterCard, 50, 6)

		local breakCard = Panel(paneHealth, 66)
		Label(breakCard, {
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -100, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "Tạm nghỉ 30 phút",
			TextXAlignment = Enum.TextXAlignment.Left
		})
		Label(breakCard, {
			Position = UDim2.fromOffset(12, 26),
			Size = UDim2.new(1, -100, 0, 14),
			Text = "Sau mỗi 2 giờ online sẽ bắt nghỉ 30 phút",
			TextColor3 = Theme.Sub,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		})
		local breakTime = Label(breakCard, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 10),
			Size = UDim2.fromOffset(86, 24),
			Font = Enum.Font.GothamBlack,
			TextSize = 14,
			TextColor3 = Theme.Gold,
			TextXAlignment = Enum.TextXAlignment.Right
		})
		local breakBar = Bar(breakCard, 50, 6)

		local mealCard = Panel(paneHealth, 82)
		Label(mealCard, {
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "Giờ ăn cơm",
			TextXAlignment = Enum.TextXAlignment.Left
		})
		local mealRow = New("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 32),
			Size = UDim2.new(1, -24, 0, 40)
		}, mealCard)
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, mealRow)
		local mealChips = {}
		for index, meal in ipairs(MEALS) do
			local chip = New("Frame", {
				Size = UDim2.new(1 / 3, -4, 1, 0),
				BackgroundColor3 = Theme.Bg,
				BorderSizePixel = 0,
				LayoutOrder = index
			}, mealRow)
			Corner(chip, 10)
			local chipStroke = Stroke(chip, Theme.Off, 1.5, 0)
			Label(chip, {
				Position = UDim2.fromOffset(0, 3),
				Size = UDim2.new(1, 0, 0, 14),
				Text = meal.short,
				TextColor3 = Theme.Sub,
				TextSize = 10
			})
			Label(chip, {
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.GothamBlack,
				Text = string.format("%02d:00", meal.h),
				TextSize = 14
			})
			mealChips[index] = chipStroke
		end

		Note(paneHealth, "Các nhắc nhở sẽ che toàn màn hình cho đến khi bạn bấm xác nhận.", Theme.Sub)

		local function UpdateUI()
			local now = os.time()
			local t = os.date("*t")
			timeLabel.Text = ClockHMS(t.hour, t.min, t.sec)
			dateLabel.Text = DateText(t)
			secondHand.Rotation = t.sec * 6
			minuteHand.Rotation = (t.min + t.sec / 60) * 6
			hourHand.Rotation = ((t.hour % 12) + t.min / 60) * 30
			onlineValue.Text = FormatHMS(now - startedAt)

			local breakText, breakRatio
			if breakUntil > 0 then
				local left = breakUntil - now
				breakText = FormatHMS(left)
				breakRatio = 1 - left / BREAK_LENGTH
				playLabel.Text = string.format(T("Đang tạm nghỉ: còn %s"), breakText)
				playBar(breakRatio)
			else
				local played = now - lastBreakEnd
				breakText = FormatHMS(PLAY_LIMIT - played)
				breakRatio = played / PLAY_LIMIT
				playLabel.Text = string.format(T("Tạm nghỉ sau: %s"), breakText)
				playBar(breakRatio)
			end

			if paneHealth.Visible then
				local waterLeft = waterPending and 0 or math.max(0, nextWater - now)
				waterTime.Text = string.format("%02d:%02d", math.floor(waterLeft / 60), waterLeft % 60)
				waterBar(1 - waterLeft / WATER_EVERY)
				breakTime.Text = breakText
				breakBar(breakRatio)
				local nextIndex = nil
				for index, meal in ipairs(MEALS) do
					local key = t.year .. ":" .. t.yday .. ":" .. meal.h
					if firedMeals[key] then
						mealChips[index].Color = Theme.On
					elseif not nextIndex and (t.hour < meal.h) then
						nextIndex = index
						mealChips[index].Color = Theme.Cyan
					else
						mealChips[index].Color = Theme.Off
					end
				end
			end
		end

		local function UpdateFast()
			if paneTimer.Visible then
				local remaining = Tm.running and math.max(0, Tm.endAt - os.clock()) or Tm.remaining
				timerDisplay.Text = FormatHMS(math.ceil(remaining))
				timerBar(Tm.total > 0 and remaining / Tm.total or 0)
				local key = Tm.running and "Đang chạy" or (Tm.paused and "Tạm dừng" or "Sẵn sàng")
				timerState.Text = T(key)
				timerToggle.Text = T(Tm.running and "Tạm dừng" or (Tm.paused and "Tiếp tục" or "Bắt đầu"))
			end
			if paneStop.Visible then
				swDisplay.Text = SwFormat(SwElapsed())
				swToggle.Text = T(Sw.running and "Tạm dừng" or (Sw.base > 0 and "Tiếp tục" or "Bắt đầu"))
			end
		end

		local function TickOverlay()
			local ev = current
			if not ev then
				return
			end
			local now = os.time()
			local t = os.date("*t")
			local left
			if ev.kind == "break" then
				left = breakUntil - now
				infoLabel.Text = FormatHMS(math.max(0, left))
				captionLabel.Text = T("Thời gian còn chờ")
			else
				left = ev.shownAt + CONFIRM_DELAY - now
				infoLabel.Text = ClockHMS(t.hour, t.min, t.sec)
				captionLabel.Text = T("Giờ hiện tại")
			end
			local ready = left <= 0
			if ready then
				confirmBtn.Text = T(ev.button)
			elseif ev.kind == "break" then
				confirmBtn.Text = string.format(T("Còn %s mới được chơi tiếp"), FormatHMS(left))
			else
				confirmBtn.Text = string.format(T("Xác nhận sau %ds"), left)
			end
			confirmBtn.BackgroundColor3 = ready and Theme.On or Theme.Off
			confirmBtn.TextColor3 = ready and Color3.fromRGB(8, 30, 20) or Theme.Sub
			if not Shield.Visible then
				Shield.Visible = true
			end
		end

		local function CheckTriggers()
			local now = os.time()
			if breakUntil == 0 and now - lastBreakEnd >= PLAY_LIMIT then
				breakUntil = now + BREAK_LENGTH
				FileWrite(BREAK_FILE, tostring(breakUntil))
				Enqueue(BreakEvent(), true)
			end
			if not waterPending and now >= nextWater then
				waterPending = true
				Enqueue(WaterEvent(), false)
			end
			local t = os.date("*t")
			for _, meal in ipairs(MEALS) do
				local key = t.year .. ":" .. t.yday .. ":" .. meal.h
				if t.hour == meal.h and t.min <= 2 and not firedMeals[key] then
					firedMeals[key] = true
					Enqueue(MealEvent(meal, key), false)
				end
			end
			local stamp = t.yday .. ":" .. t.hour .. ":" .. t.min
			for _, a in ipairs(alarms) do
				if a.on and t.hour == a.h and t.min == a.m and a.last ~= stamp then
					a.last = stamp
					if not a.daily then
						a.on = false
						SaveAlarms()
						RefreshAlarmList()
					end
					RingAlarm(a)
				end
			end
			for i = #snoozes, 1, -1 do
				if now >= snoozes[i].at then
					local snoozed = table.remove(snoozes, i)
					RingAlarm(snoozed.a)
				end
			end
			if Tm.running and Tm.endAt - os.clock() <= 0 then
				Tm.running = false
				Tm.paused = false
				Tm.remaining = Tm.total
				local finished = Tm.total
				PushRing({
					title = "Bộ đếm đã hết giờ",
					dismiss = "Đóng",
					snooze = false,
					text = function() return FormatHMS(finished) end
				})
			end
			Pump()
		end

		table.insert(LocHooks, function()
			RefreshAlarmList()
			RefreshLaps()
			RefreshBanner()
		end)

		SelectSub(1)

		task.spawn(function()
			while true do
				pcall(CheckTriggers)
				pcall(TickOverlay)
				if tClock.Visible and menuOpen then
					pcall(UpdateUI)
				end
				task.wait(0.25)
			end
		end)

		task.spawn(function()
			while true do
				if tClock.Visible and menuOpen then
					pcall(UpdateFast)
				end
				task.wait(0.05)
			end
		end)
	end

	local clockOk, clockErr = pcall(BuildClock)
	if not clockOk then
		warn("SieuToc clock loi: " .. tostring(clockErr))
	end

	local function RunIntro()
		local introGui = New("ScreenGui", {
			Name = "SieuToc_Intro",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 50,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		}, GuiParent)
		local cover = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Bg,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Active = true
		}, introGui)
		New("UIGradient", {
			Color = ColorSequence.new(Theme.Bg, Color3.fromRGB(40, 26, 86)),
			Rotation = 90
		}, cover)
		local center = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(260, 190),
			BackgroundTransparency = 1
		}, cover)
		local logo = New("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromOffset(96, 96),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Image = iconAsset or "",
			ScaleType = Enum.ScaleType.Crop
		}, center)
		Corner(logo, 48)
		local logoStroke = Stroke(logo, Theme.Cyan, 4, 0)
		TweenService:Create(
			logoStroke,
			TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.7, Thickness = 8 }
		):Play()
		if not iconAsset then
			New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Font = Enum.Font.GothamBold,
				Text = "S",
				TextColor3 = Theme.Text,
				TextSize = 44
			}, logo)
		end
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 108),
			Size = UDim2.new(1, 0, 0, 26),
			Font = Enum.Font.GothamBlack,
			Text = "SIÊU TỐC PRO",
			TextColor3 = Theme.Text,
			TextSize = 20
		}, center)
		local status = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 138),
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.GothamMedium,
			Text = T("Đang khởi động..."),
			TextColor3 = Theme.Sub,
			TextSize = 12
		}, center)
		local track = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 168),
			Size = UDim2.new(1, 0, 0, 6),
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0
		}, center)
		Corner(track, 3)
		local fill = New("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0
		}, track)
		Corner(fill, 3)
		New("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Cyan) }, fill)
		local total = 2.5
		Tween(fill, total, { Size = UDim2.new(1, 0, 1, 0) }, Enum.EasingStyle.Linear)
		local startTime = tick()
		while true do
			local left = total - (tick() - startTime)
			if left <= 0 then
				break
			end
			status.Text = string.format(T("Đang khởi động... %.1fs"), left)
			task.wait(0.1)
		end
		introGui:Destroy()
	end

	MenuIcon.Visible = false
	task.spawn(function()
		pcall(RunIntro)
		MenuIcon.Visible = true
		SelectTab("Di Chuyển")
		SetMenuOpen(true)
	end)
end)

if not bootOk then
	warn("SieuToc loi: " .. tostring(bootErr))
	ShowFatal("Lỗi menu: " .. tostring(bootErr))
end
