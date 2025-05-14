package se;

class FSM {
	public var state:State;

	public function new(state:State) {
		this.state = state;
	}

	public function goto(state:State) {
		if (state != null) {
			final old = this.state;
			if (old != null) {
				if (old.hasTransition(state)) {
					this.state = state;
					old.getTransition(state)();
				}
			} else
				this.state = state;
		}
	}
}

@:forward()
@:forward.new
abstract State(StateData) from StateData to StateData {
	@:from
	static inline function fromMap(value:Map<State, Void->Void>):State {
		return new State(value);
	}

	@:op([])
	public function addTransition(to:State, ?transition:Void->Void) {
		this.transitions.set(to, transition ?? () -> {});
	}

	@:op([])
	public function getTransition(to:State) {
		return this.transitions.get(to);
	}

	public function hasTransition(to:State) {
		return this.transitions.exists(to);
	}

	public function removeTransition(to:State) {
		this.transitions.remove(to);
	}
}

class StateData {
	public var transitions:Map<StateData, Void->Void>;

	public function new(?transitions:Map<StateData, Void->Void>) {
		this.transitions = transitions ?? [];
	}
}
