package se;

import kha.AssetError;

class Asset {
	public static inline function syncLoad<T>(asset:String, f:(String, T->Void, AssetError->Void) -> Void) {
		var value:T = null;
		var error:AssetError = null;
		f(asset, v -> value = v, err -> error = err);
		while (true) 
			if (asset != null || error != null)
				break;
		return value;
	}
}
