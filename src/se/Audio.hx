package se;

import kha.Sound;
import aura.Aura;
import aura.dsp.panner.StereoPanner;
import se.Assets;

@:forward()
abstract Audio(AudioData) from AudioData to AudioData {
	@:from
	public static inline function fromSound(value:Sound):Audio {
		return new AudioData(value);
	}

	@:from
	public static inline function fromString(value:String):Audio {
		return AudioAsset.load(value);
	}
}

#if !macro
@:build(se.macro.SMacro.build())
#end
private class AudioData {
	@:isVar var sound(default, set):Sound;
	@:isVar var handle(default, set):BaseChannelHandle;

	@:isVar public var panner(default, null):AudioPanner;

	public function new(sound:Sound) {
		this.sound = sound;
	}

	public inline function play(retrigger:Bool = false) {
		handle?.play(retrigger);
	}

	public inline function pause() {
		handle?.pause();
	}

	public inline function stop() {
		handle?.stop();
	}

	public function unload() {
		sound?.unload();
	}

	function set_sound(value:Sound):Sound {
		sound = value;
		if (sound?.uncompressedData != null)
			handle = Aura.createUncompBufferChannel(sound);
		else
			handle = Aura.createCompBufferChannel(sound);
		return sound;
	}

	function set_handle(value:BaseChannelHandle):BaseChannelHandle {
		handle = value;
		if (handle != null)
			panner = new StereoPanner(handle);
		return handle;
	}
}

@:forward(maxDistance, dopplerStrength, attenuationMode, attenuationFactor, update3D, reset3D)
private extern abstract AudioPanner(StereoPanner) from StereoPanner {
	public var balance(get, set):Float;

	private inline function get_balance():Float {
		return this.getBalance();
	}

	private inline function set_balance(value:Float) {
		this.setBalance(value);
		return value;
	}
}
