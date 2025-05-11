package se;

import kha.Sound;
import kha.math.FastVector3;
import aura.Aura;
import aura.dsp.panner.Panner;
import aura.dsp.panner.StereoPanner;
import se.Assets;
import se.math.Vec3;

@:forward()
@:forward.new
abstract Audio(AudioData) from AudioData to AudioData {
	@:from
	public static inline function fromString(value:String):Audio {
		return new Audio(value);
	}
}

private class AudioData {
	@:isVar public var asset(default, null):SoundAsset;
	@:isVar public var panner(default, null):AudioPanner = new AudioPanner();

	public function new(?source:String, uncomressed:Bool = true) {
		asset = new SoundAsset(uncomressed);
		asset.onAssetLoaded(__syncAsset__);
		asset.source = source;
	}

	public inline function play(retrigger:Bool = false) @:privateAccess {
		this.panner?.handle.play(retrigger);
	}

	public inline function pause() @:privateAccess {
		this.panner?.handle.pause();
	}

	public inline function stop() @:privateAccess {
		this.panner?.handle.stop();
	}

	function __syncAsset__(sound:Sound):Sound @:privateAccess {
		if (sound.uncompressedData != null)
			this.panner.handle = Aura.createUncompBufferChannel(sound);
		else
			this.panner.handle = Aura.createCompBufferChannel(sound);
		return sound;
	}
}

@:allow(se.Audio.AudioPanner)
private class AudioPanner {
	@:isVar private var handle(default, set):BaseChannelHandle;
	@:isVar private var panner(default, set):StereoPanner;

	@:isVar public var balance(default, set):Float = 0.0;
	@:isVar public var location(default, set):Vec3 = new Vec3(0, 0, 0);
	@:isVar public var maxDistance(default, set):Float = 10.0;
	@:isVar public var dopplerStrength(default, set):Float = 1.0;
	@:isVar public var attenuationMode(default, set):AttenuationMode = AttenuationMode.Inverse;
	@:isVar public var attenuationFactor(default, set):Float = 1.0;

	public function new() {}

	private inline function set_handle(value:BaseChannelHandle):BaseChannelHandle {
		handle = value;
		if (handle != null)
			if (panner != null)
				panner.setHandle(handle);
			else
				panner = new StereoPanner(handle);
		return handle;
	}

	private inline function set_panner(value:StereoPanner):StereoPanner {
		panner = value;
		if (panner != null) {
			panner.setBalance(balance);
			panner.setLocation((location : FastVector3));
			panner.update3D();
			panner.maxDistance = maxDistance;
			panner.dopplerStrength = dopplerStrength;
			panner.attenuationMode = attenuationMode;
			panner.attenuationFactor = attenuationFactor;
		}
		return panner;
	}

	private inline function set_balance(value:Float):Float {
		balance = value;
		if (panner != null)
			panner.setBalance(value);
		return balance;
	}

	private inline function set_location(value:Vec3):Vec3 {
		location = value;
		if (panner != null) {
			panner.setLocation((value : FastVector3));
			panner.update3D();
		}
		return location;
	}

	private inline function set_dopplerStrength(value:Float):Float {
		dopplerStrength = value;
		if (panner != null)
			panner.dopplerStrength = value;
		return balance;
	}

	private inline function set_attenuationMode(value:AttenuationMode):AttenuationMode {
		attenuationMode = value;
		if (panner != null)
			panner.attenuationMode = value;
		return attenuationMode;
	}

	private inline function set_attenuationFactor(value:Float):Float {
		attenuationFactor = value;
		if (panner != null)
			panner.attenuationFactor = value;
		return attenuationFactor;
	}

	private inline function set_maxDistance(value:Float):Float {
		maxDistance = value;
		if (panner != null)
			panner.maxDistance = value;
		return maxDistance;
	}
}
