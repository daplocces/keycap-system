export type AnimationData = {
	TWEEN_INFO: TweenInfo,
	-- TWEEN_PROPERTIES: {[string]: any}
}

return {
	NORMAL = {
		TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		-- TWEEN_PROPERTIES = {Size = Vector3.new(nil, 0.1, nil), Position = Vector3.new(nil, -0.1, nil)}
	},
	
	-- Add more here if you'd like
}