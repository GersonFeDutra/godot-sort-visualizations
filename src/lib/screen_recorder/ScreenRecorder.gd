extends Node
class_name ScreenRecorder

## Project based in Godot video rendering demo https://github.com/Calinou/godot-video-rendering-demo
## See `LICENSE.md` included in the source distribution for details.

signal process_completed(output_path)

enum Formats {
	H264, # Needs a GdNative plugin to be played in Godot.
	OGV,
	WEBM, # Default - recommended for transparent videos.
}
enum Transparency {
	VIEWPORT = -1, # Ativa a transparência com base em `transparent_bg` do viewport.
	FALSE = 0,
	TRUE = 1,
}

const RENDER_DIR: String = "render"
const FRAMES_DIR: String = "%s/frames" % RENDER_DIR

var is_transparency_enabled: bool
var renders: int = 0
var first_frame: int = 0
var current_folder: String
var capture_viewport: Viewport

#### 

# Copyright © 2019 Hugo Locurcio and contributors - MIT License
# Modified by GersonFeDutra © 2021.

func _ready() -> void:
	set_process(false)
	
	var directory: = Directory.new()
	var path: String = "user://%s" % RENDER_DIR
	
	if not directory.dir_exists(path) and directory.make_dir(path) != OK:
		push_error("Wouldn't able to create render folder.")
		get_tree().quit(ERR_CANT_CREATE)


func _process(_delta: float) -> void:
	
	print(
			"Rendering frame {frame}...".format({
				frame = Engine.get_frames_drawn(),
			})
	)
	capture_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	var image := capture_viewport.get_texture().get_data()
	
	#if image.generate_mipmaps() != OK:
	#	push_warning("Woldn't able to generate mipmaps")
	
	# The viewport must be flipped to match the rendered window
	image.flip_y()
	
	if image.save_png("%s/%d.png" % [current_folder, Engine.get_frames_drawn()]) != OK:
		push_warning("Woldn't able to save frame %d." % Engine.get_frames_drawn())

####


func start(
		viewport: Viewport = get_viewport(), use_transparency: int = Transparency.VIEWPORT) -> void:
	var directory := Directory.new()
	var path: String = "user://%s" % FRAMES_DIR
	
	match use_transparency:
		Transparency.VIEWPORT:
			is_transparency_enabled = viewport.transparent_bg
		_:
			is_transparency_enabled = use_transparency == Transparency.TRUE
	
	capture_viewport = viewport
	capture_viewport.msaa = Viewport.MSAA_2X
	current_folder = "%s%d" % [path, renders]
	
	while directory.dir_exists(current_folder):
		renders += 1
		current_folder = "%s%d" % [path, renders]
	
	if directory.make_dir(current_folder) != OK:
		push_error("Wouldn't able to create frames folder.")
		get_tree().quit(ERR_CANT_CREATE)
	
	first_frame = Engine.get_frames_drawn()
	
	if first_frame == 0:
		# If, for some reason, we start recording from start, we skip the first frame that
		# is always empty.
		yield(get_tree() ,"idle_frame")
	
	if not OS.has_feature("standalone"):
		push_warning("FPS may be wrong on export, be sure to export and run the project " +
				"with the `--fixed-fps 60` flag.")
	
	set_process(true)


func stop(format: int = Formats.WEBM) -> void:
	set_process(false)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	# Allows displaying eventual messages to the user while processing.
	
	if not OS.is_debug_build():
		return
	
	var exit_code: int
	var user_dir: String = OS.get_user_data_dir()
	var output_path: String = "{output_dir}/video{renders}".format({
			output_dir = user_dir + "/" + RENDER_DIR,
			renders = renders,
		})
	var args := PoolStringArray([
		"-start_number", str(first_frame), "-r", "60", "-f", "image2", "-s", "2560x1440", "-i",
		"{frames_dir}/%d.png".format({
				frames_dir = user_dir + "/" + FRAMES_DIR + str(renders)}),
	])
	
	if is_transparency_enabled:
		args.append_array(["-vf", "colorkey=black"])
		
		if format != Formats.WEBM:
			push_warning("WebM format is the only that fully support transparency. " +
				"Prefer it for alpha-channel-enabled videos instead.")
	
	match format:
		Formats.H264:
			output_path += ".mp4"
			args.append_array(["-vcodec", "libx264"])
		Formats.OGV:
			output_path += ".ogv"
			args.append_array(["-codec:a", "libtheora", "-qscale:v", "6"])
		Formats.WEBM:
			output_path += ".webm"
			args.append_array(["-c:v", "libvpx-vp9"])
			
			if is_transparency_enabled:
				args.append_array(["-pix_fmt", "yuva420p"])
	
	args.append_array(["-crf", "15", output_path])
	exit_code = OS.execute("ffmpeg", args)
	
	if exit_code != OK:
		output_path = ""
		push_error("Wouldn't able to complete the rendering")
	
	emit_signal("process_completed", output_path)
