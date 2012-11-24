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

   return 0;
}