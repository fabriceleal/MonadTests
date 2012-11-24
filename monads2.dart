/*
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c1-introduction.html
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c2-whats-point.html
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c-3-creating-our-first-monad.html
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c-4-linq-loves-monads.html
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c-5-maybe.html
    http://mikehadlow.blogspot.pt/2011/01/monads-in-c-6-introducing-simple-parser.html
    http://mikehadlow.blogspot.pt/2011/02/monads-in-c-7-turning-our-parser-into.html
    http://mikehadlow.blogspot.pt/2011/02/monads-in-c-8-video-of-my-ddd9-monad.html
*/

abstract class Maybe<T> {
   static Maybe<T> unit(T value) {
      return new Just(value);
   }

   Maybe<U> bind(Maybe<U> func(T a));
}

class Nothing<T> extends Maybe<T> {
   String toString() {
      return "<Maybe:Nothing>";
   }
   
   Maybe<U> bind(Maybe<U> func(T a)) {
      return new Nothing();
   }
}

class Just<T> extends Maybe<T> {
   T value;
   Just(this.value);
   String toString() {
      return this.value.toString();
   }

   Maybe<U> bind(Maybe<U> func(T a)) {
      return func(this.value);
   }
}

class Identity <T> {
   T value;

   Identity(this.value); 
	  
   Identity<U> bind(Identity<U> func(T a)) {
      return func(this.value);
   }

   static Identity<T> ret(T value) {
      return new Identity(value);
   }
}

class Tuple<A, B> {
   A value1;
   B value2;
   Tuple(this.value1, this.value2);
}

Maybe<Tuple<string, string>> matchHello(string input) {
    if(input.startsWith('Hello')) {
	    return new Just(
			   new Tuple('Hello',
			   	   input.substring('Hello'.length)));
	}
   return new Nothing();
}

Identity<num> add2(num x) {
   return new Identity(x + 2);
}

Identity<num> mult2(num x) {
   return new Identity(x * 2);
}

main() {
   // Tests
   Identity<num> x = add2(5);
   x = mult2(x.value);
   print(x.value);

   Identity<num> y = new Identity(1);
   Identity<num> w = y.bind(add2).bind(mult2);
   print(w.value);

   var z = Identity.
   	 ret("hello world").bind(function(string a) {
      return Identity.ret(7).bind(function(num b) {
	     return Identity.ret(1.3).bind(function(c) {
		    var s = "$a, $b, $c";
			return Identity.ret(s);
		 });
	  });
   });
   print(z.value);

   // Safe division
   var div = function (num numerator, num denominator) {
   	   return denominator == 0 ? 
	   		  new Nothing<num>() : 
			  new Just<num>(numerator/denominator);
   };

   var doSomeDivision = function(num denominator) {
   	   return div(12, denominator).bind(function(num x){
	       return div(x, 2).bind(function(num b) {
		       return Maybe.unit(b);
		   });
	   });
   };
   print(doSomeDivision(0));
   print(doSomeDivision(1));

   var parsed = matchHello('Hello World!');
	print(parsed.value.value1);

	parsed = matchHello('Goodbye');
	print(parsed);

	//print('Hello World!'.substring(2));

   return 0;
}