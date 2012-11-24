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

typedef Maybe<Tuple<T, string>> ParserFunc<T>(string a);

class Parser<T> {
	ParserFunc<T> value;

	Parser(this.value);

	Parser<U> bind(Parser<U> func(T a)) {
		 ParserFunc<T> pp = this.value;
		 return new Parser((string s) {
		 	 var aMaybe = pp(s);
			 //print("executed myself");
			 if(aMaybe is Just<Tuple<T,string>>) {
			    var aResult = aMaybe as Just<Tuple<T,string>>;
				 var aValue = aResult.value.value1;
				 var sString = aResult.value.value2;
				 //print(func);
				 var bParser = func(aValue);
				 //print(aValue);
				 //print(bParser);
				 var r = bParser.value(sString);
				 //print(r);
				 return r;
			 } else {
			    return new Nothing(); //<Tuple<U, string>>();
			 }
		 });
	}

	/*
		  ParserFunc.
	*/
	static Parser<T> retm(T value) {
		 return new Parser(Find(value));
	}

   /*
		  Dummy return. So I can return stuff from within the lambdas
	*/
	static Parser<T> ret(T value) {
	    return new Parser((s){
		 	  return new Just(value);
		 });
	}

}


class Tuple<A, B> {
   A value1;
   B value2;
   Tuple(this.value1, this.value2);

	string toString(){
		 var s1 = value1.toString();
		 var s2 = value2.toString();
	    return "('$s1', '$s2')";
	}
}

Maybe<Tuple<string, string>> Find(string s) {
   return (i) {
	   if(i.startsWith(s)) {
		   return new Just(new Tuple(s, i.substring(s.length)));
		}
	   return new Nothing();
	};
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

	var p = Parser.retm('Hello').bind((hello) {
		return Parser.retm('World').bind((world) {
				 //print(hello);
				 //print(world);
				 return Parser.ret({'hello' : hello, 'world' : world});
		});
	});

	print(p.value('HelloWorld'));

   return 0;
}