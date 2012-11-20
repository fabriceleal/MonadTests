/* 
	http://igstan.ro/posts/2011-05-02-understanding-monads-with-javascript.html
	
	In Javascript
*/

// This mutates state
var stack = [];

stack.push(4);
stack.push(5);
stack.pop();
stack.pop();

// ** A Stack With Explicit Handling of State **

var push = function(e, stack) {
	return {
		value : null,
		stack : [element].concat(stack);
	};
}

var pop = function(stack) {
	return {
		value : stack[0],
		stack : stack.slice(1)
	};
}

// Better, but lots of explicit state
var s1 = push(4, []);
var s2 = push(4, s1.stack);
var r0 = pop(s2.stack);
var r1 = pop(r0.stack);

// ** Transforming to Continuation-Passing Style **
var bind = function(value, continuation) {
	return continuation(value);
};

var stack0 = [];
var fr = bind(push(4, stack0),
	function(r0){
		return bind(push(5, r0.stack),
			function(r1) {
				return bind(pop(r1.stack),
					function(r2) {
						return bind(pop(r2.stack),
							function(r3) {
								var v = r2.value + ":" + r3.value;
								return {
									value: v,
									stack : r3.stack
								};
							}
						);
					}
				);
			}
		);
	}
);

var push = function(e) {
	return function(stack){
		return {
			value : null,
			stack : [element].concat(stack);
		};
	};
};

var pop = function() {
	return function(stack) {
		return {
			value : stack[0],
			stack : stack.slice(1)
		};
	};
};

// ** Preparing bind to Handle Intermediate Stacks **

var bind = function(stackOperation, continuation) {
	return function(stack) {
		return continuation(stackOperation(stack))
	};
};

var r = bind(push(4), function(r0) {
	return bind(push(5), function(r1) {
		return bind(pop(), function(r2) {
			return bind(pop(), function(r3) {
				var v = r2.value + " : " + r3.value;
				return { value:v, stack:r3.stack };
			})(r2.stack);
		})(r1.stack);
	})(r0.stack);
})(stack0);

// ** Removing Trailing Stacks **

var bind = function(stackOperation, continuation) {
	return function(stack) {
		var r = stackOperation(stack);
		var n = result.stack;
		return continuation(r)(n);
	};
};

var computation = bind(push(4), function(r0) {
	return bind(push(5), function(r1) {
		return bind(pop(), function(r2) {
			return bind(pop(), function(r3) {
				var v = r2.value + ":" + r3.value;
				return function(stack) {
					return {value:v, stack:stack};
				};
			});
		});		
	});
});
computation([]);

// ** Hiding the Final Residual Stack **

var result = function(value) {
	return function(stack) {
		return { value: value, stack: stack };
	};
};

var computation = bind(push(4), function(r0) {
	return bind(push(5), function(r1) {
		return bind(pop(), function(r2) {
			return bind(pop(), function(r3) {
				return result(r2.value + ":" + r3.value);
			});
		});
	});
});

computation([]);

// ** Keeping State Internal **

var bind = function(stackOperation, continuation) {
	return function(stack) {
		var result = stackOperation(stack);
		return continuation(result.value)(result.stack);
	};
};

var computation = bind(push(4), function() {
	return bind(push(5), function() {
		return bind(pop(), function(r1) {
			return bind(pop(), function(r2) {
				return result(r1 + ":" + r2);
			});
		});
	});
});
computation([]);

// ** Evaluating The Stack Computation **
var runStack = function(stackOperation, initialStack) {
	return stackOperation(initialStack);
};

var evalStack = function(stackOperation, initialStack) {
	return stackOperation(initialStack).value;
};

var execStack = function(stackOperation, initialStack) {
	return stackOperation(initialStack).stack;
};

runStack(computation, []);
evalStack(computation, []);
execStack(computation, []);

// ** Sequence **

var sequence = function() {
	var args = [].slice.call(arguments);
	var monadicActions = args.slice(0, -1);
	var continuation = args.slice(-1)[0];
	
	return function(stack) {
		var initialState = { values:[], stack: stack };
		
		var state = monadicActions.reduce(function (state, action) {
			var result = action(state.stack);
			var values = state.values.concat(result.value);
			var stack = result.stack;
			
			return {values: values, stack: stack};
		}, initialState);
		
		var values = state.values.filter(function (value) {
			return value !== undefined;
		});
		return continuation.apply(this, values)(state.stack);
	};
};

var computation = sequence(push(4), push(5), pop(), pop(), 
	function(pop1, pop2) {
		return result(pop1 + ":" + pop2);
	});
	
computation([]);

// ** Monads As Suspended Computations **

