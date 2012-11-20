/*
	http://blogs.msdn.com/b/wesdyer/archive/2008/01/11/the-marvels-of-monads.aspx
	
	Translated from C#/Linq to Javascript
*/

// The identity monad simply wraps a value.
var IdentityMonad = function(scalarValue){
	this.value = function(){
		return scalarValue;
	};
	Object.freeze(this);
};

// The maybe monad might hold a value, or not
var MaybeMonad = function() {
	var _args = Array.prototype.slice.call(arguments);
	if(this.hasValue = (_args.length > 0)){
		this.value = function(){
			return _args[0];
		};
	} else {
		//console.log('nothing!');
		
		if(! MaybeMonad.Nothing) {
			MaybeMonad.Nothing = this;
		} else {
			return MaybeMonad.Nothing;
		}
		console.log('value()');
		// Only hit if initing
		this.value = function(){
			// return undefined;
		};
	}	
	Object.freeze(this);
}

MaybeMonad.Nothing = new MaybeMonad();

// The list monad
var ListMonad = function(scalarValue){
	
	if(scalarValue instanceof Array) {
		//console.log('is array!');
		
		this.value = function(){
			return scalarValue;
		};
	} else {
		//console.log('is not array!');
		
		this.value = function(){
			return [scalarValue];
		};
	}
	
	Object.freeze(this);
};

var ContinuationMonad = function(transformFunction) {
	this.value = function(){
		return transformFunction;
	};
	Object.freeze(this);
};

// *** Bind ***
IdentityMonad.prototype.bind = function(arrowOfTreturnsIdentityOfU, getsTwoValuesEval) {
	if(getsTwoValuesEval) {
		return getsTwoValuesEval(this.value(), 
								arrowOfTreturnsIdentityOfU(this.value()).value()
								).toIdentity();
	} else {
		return arrowOfTreturnsIdentityOfU(this.value());
	}
};

MaybeMonad.prototype.bind = function(arrowOfTreturnsMaybeOfU){
	if(! this.hasValue){
		return MaybeMonad.Nothing;
	}
	return arrowOfTreturnsMaybeOfU(this.value());
};

ListMonad.prototype.bind = function(arrowOfTreturnsListOfU){
	var tmp = [];
	var thisValue = this.value();
	
	for(var x = 0; x < thisValue.length ; ++x) {
		(function(x){			
			// x is the element
			var resValue = arrowOfTreturnsListOfU(x).value();
			for(var y = 0; y < resValue.length; ++y) {
					(function(y){
						tmp.push(y);
					})(resValue[y]);
			}			
		})(thisValue[x]);
	}
	return tmp.toList();
};

ContinuationMonad.prototype.bind = function(arrowOfTreturnsContinuationOfUAnswer){	
	return new ContinuationMonad(function(c) {
		return this.value()(function(x){
			return arrowOfTreturnsContinuationOfUAnswer(x);
		})(c);
	});
};

// *** Unit ***

Object.prototype.toMaybe = function(){
	return new MaybeMonad(this);
};

Object.prototype.toIdentity = function(){
	return new IdentityMonad(this);
};

Object.prototype.toList = function(){
	return new ListMonad(this);
};

Object.prototype.toContinuation = function(){
	var _this = this;
	return function(c){
		return c(_this);
	};
};

// **** Tests ****
var r;

r = (5).toIdentity().bind(
	function(){
		return (6).toIdentity();
	}, function(x,y){
		return x+y
	});

// This needs to be like this because r.value() 
// will return an instance to a Number
// Otherwise, will print '{}'
console.log('id test =', JSON.stringify(r.value()));

r = (5).toMaybe().bind(
	function(x){ 
		var mm; 
		mm = (7).toMaybe();
		//mm = MaybeMonad.Nothing;
		return mm.bind(function(y){
			return (x+y).toMaybe();
		});
	});

console.log('maybe test =', JSON.stringify(r.value()));

r = [0,1,2].toList().bind(
		function(x){
			return [0,1,2].toList().bind(
				function(y) {
					return (x+y).toList(); //(x+y).toList();
				}
			);
		});

console.log('list test =', JSON.stringify(r.value()));

r = (7).toContinuation().bind(
	function(x){
		return (8).toContinuation().bind(
			function(y){
				return (x+y);
			});
	});

r(function(val){
	console.log('continuation test =', JSON.stringify(val));
});